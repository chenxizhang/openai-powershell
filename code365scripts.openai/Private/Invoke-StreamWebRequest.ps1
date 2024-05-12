function Invoke-StreamWebRequest {
    param(
        [Parameter(Mandatory = $true)][string]$uri,
        [Parameter(Mandatory = $true)][string]$body,
        [hashtable]$header
    )
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
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
                                        
    $task = $client.Send($request)
    $response = $task.Content.ReadAsStream()
    $reader = [System.IO.StreamReader]::new($response)
    return $reader
}