function Invoke-UniWebRequest {
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [hashtable]$params
    )

    try {
        $ProgressPreference = 'SilentlyContinue'
        $response = Invoke-WebRequest @params -ContentType "application/json;charset=utf-8"
        $ProgressPreference = 'Continue'

        if (($PSVersionTable['PSVersion'].Major -ge 6) -or ($response.Headers['Content-Type'] -match 'charset=utf-8')) {
            return $response.Content | ConvertFrom-Json
        }
        else {
            $response = $response.Content | ConvertFrom-Json
            $result = $response.choices[0].message.content
            if ($null -eq $result) {
                return $response
            }
            else {
                $dstEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
                $srcEncoding = [System.Text.Encoding]::UTF8
                $result = $srcEncoding.GetString([System.Text.Encoding]::Convert($srcEncoding, $dstEncoding, $srcEncoding.GetBytes($result)))
                $response.choices[0].message.content = $result
                return $response
            }
        }
    }
    catch {
        $errorMessage = if ($_.ErrorDetails) { 
            $_.ErrorDetails 
        } elseif ($_.Exception.Message) { 
            $_.Exception.Message 
        } else { 
            "Unknown error occurred during web request" 
        }
        
        # Try to parse error details from API response
        if ($_.ErrorDetails) {
            try {
                $errorObj = $_.ErrorDetails | ConvertFrom-Json
                if ($errorObj.error.message) {
                    $errorMessage = "API Error: $($errorObj.error.message)"
                    if ($errorObj.error.type) {
                        $errorMessage += " (Type: $($errorObj.error.type))"
                    }
                }
            }
            catch {
                # If parsing fails, use the original error details
            }
        }
        
        throw "Web request failed: $errorMessage"
    }
}
