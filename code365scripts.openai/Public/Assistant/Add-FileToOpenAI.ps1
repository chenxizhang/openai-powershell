function Add-FileToOpenAI {
    <#
        .SYNOPSIS
            Upload a file to OpenAI.
        .DESCRIPTION
            Upload a file to OpenAI.
        .PARAMETER apiKey
            The OpenAI API key.
        .PARAMETER endpoint
            The OpenAI API endpoint.
        .PARAMETER fullname
            The full path of the file to upload. currently only supports pdf, docx, txt, and md files.
    #>
    [CmdletBinding()]
    param(
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [Parameter(Mandatory = $true, Position = 0 , ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$fullname 
    )

    BEGIN {
        if (-not $apiKey) {
            Write-Error "API Key is required. Please provide the API key using -apiKey parameter or set the OPENAI_API_KEY environment variable."
            return
        }
        if (-not $endpoint) {
            $endpoint = "https://api.openai.com/v1/files"
        }

        $headers = @{
            "OpenAI-Beta" = "assistants=v2"
        }

        if ($endpoint -match "azure") {
            $headers.Add("api-key", $apiKey)
            $endpoint = $endpoint + "openai/files?api-version=2024-05-01-preview"
        }
        else {
            $headers.Add("Authorization", "Bearer $apiKey")
        }

    }

    PROCESS {

        foreach ($file in $fullname) {
            Write-Host "process file: $file"

            # Define the purpose (e.g., "assistants", "vision", "batch", or "fine-tune")
            $purpose = "assistants"

            # Create a new web request
            $request = [System.Net.WebRequest]::Create($endpoint)

            $request.Method = "POST"

            # add the item of headers to request.Headers
            $headers.GetEnumerator() | ForEach-Object {
                $request.Headers.Add($_.Key, $_.Value)
            }

            # Create a boundary for the multipart/form-data content
            $boundary = [System.Guid]::NewGuid().ToString()

            # Set the content type and boundary
            $request.ContentType = "multipart/form-data; boundary=$boundary"

            $name = "{0}-{1}" -f (Get-FileHash $file).Hash, (Split-Path $file -Leaf)

            # Create the request body
            $body = @"
--$boundary
Content-Disposition: form-data; name="file"; filename="$name"
Content-Type: application/octet-stream

$(Get-Content -Path $file)

--$boundary
Content-Disposition: form-data; name="purpose"

$purpose
--$boundary--
"@

            # Convert the body to bytes
            $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)

            # Set the content length
            $request.ContentLength = $bodyBytes.Length

            # Get the request stream and write the body
            $requestStream = $request.GetRequestStream()
            $requestStream.Write($bodyBytes, 0, $bodyBytes.Length)
            $requestStream.Close()

            # Get the response
            $response = $request.GetResponse()

            # Read the response content
            $responseStream = $response.GetResponseStream()
            $reader = [System.IO.StreamReader]::new($responseStream)
            $responseContent = $reader.ReadToEnd()
            $reader.Close()

            # Print the response content
            $responseContent
        }


    }
}