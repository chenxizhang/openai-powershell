function Invoke-UniWebRequest {
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [hashtable]$params
    )

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
