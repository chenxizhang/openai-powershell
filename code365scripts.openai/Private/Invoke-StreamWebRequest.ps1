function Invoke-StreamWebRequest {
    param(
        [Parameter(Mandatory = $true)][string]$uri,
        [Parameter(Mandatory = $true)][string]$body,
        [hashtable]$header
    )

    # define a result variable
    $result = @{
        status  = "ok"
        message = ""
        reader  = $null
    }

    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    $client = New-Object System.Net.Http.HttpClient
    $request = [System.Net.Http.HttpRequestMessage]::new()
    $request.Method = "POST"
    $request.RequestUri = $uri
    $request.Headers.Clear()
    $request.Content = [System.Net.Http.StringContent]::new(($body), [System.Text.Encoding]::UTF8)
    $request.Content.Headers.Clear()
    $request.Content.Headers.Add("Content-Type", "application/json;chatset=utf-8")

    foreach ($k in $header.Keys) {
        $request.Headers.Add($k, $header[$k])
    }

    try {
        $response = [System.Net.Http.HttpResponseMessage]$client.Send($request)

        # if statuscode return OK, then return the reader
        if ($response.StatusCode -eq [System.Net.HttpStatusCode]::OK) {
            $stream = $response.Content.ReadAsStream()
            $reader = [System.IO.StreamReader]::new($stream)
            $result.reader = $reader
        }
        else {
            $result.status = $response.StatusCode
            try {
                $temp = $response.Content.ReadAsStringAsync().Result | ConvertFrom-Json
                if ($temp.error -and $temp.error.message) {
                    $result.message = "API Error: $($temp.error.message)"
                    if ($temp.error.type) {
                        $result.message += " (Type: $($temp.error.type))"
                    }
                } elseif ($temp.message) {
                    $result.message = "Error: $($temp.message)"
                    if ($temp.details) {
                        $result.message += " Details: $($temp.details)"
                    }
                } else {
                    $result.message = "HTTP Error $($response.StatusCode): $($response.ReasonPhrase)"
                }
            }
            catch {
                $result.message = "HTTP Error $($response.StatusCode): $($response.ReasonPhrase). Unable to parse error details."
            }
        }
    }
    catch {
        $result.status = "error"
        $errorMessage = if ($_.Exception.Message) { 
            $_.Exception.Message 
        } else { 
            "Unknown error occurred during streaming request" 
        }
        $result.message = "Stream request failed: $errorMessage"
    }
    finally {
        if ($client) { $client.Dispose() }
        if ($request) { $request.Dispose() }
    }

    return $result

}