function Get-AssistantResources {
    <#
        .SYNOPSIS
            List all the available OpenAI assistants.
        .DESCRIPTION
            List all the available OpenAI assistants.
        .PARAMETER apiKey
            The OpenAI API key.
        .PARAMETER endpoint
            The OpenAI API endpoint.
    #>
    [CmdletBinding()]
    param(
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [ValidateSet("assistants", "files", "vector_stores")]
        [string]$kind = "assistants"
    )

    if (-not $apiKey) {
        Write-Error "API Key is required. Please provide the API key using -apiKey parameter or set the OPENAI_API_KEY environment variable."
        return
    }

    if (-not $endpoint) {
        $endpoint = "https://api.openai.com/v1/$kind"
    }

    $headers = @{
        "Content-Type" = "application/json"
        "OpenAI-Beta"  = "assistants=v2"
    }

    if ($endpoint -match "azure") {
        $headers.Add("api-key", $apiKey)
        $endpoint = $endpoint + "openai/${kind}?api-version=2024-05-01-preview"
    }
    else {
        $headers.Add("Authorization", "Bearer $apiKey")
    }



    Invoke-RestMethod -Uri $endpoint -Headers $headers -Method Get | Select-Object -ExpandProperty data
}

function Remove-AssistantResources {
    <#
        .SYNOPSIS
            Remove an OpenAI assistant.
        .DESCRIPTION
            Remove an OpenAI assistant.
        .PARAMETER assistantId
            The ID of the assistant to remove.  
        .PARAMETER apiKey
            The OpenAI API key.
        .PARAMETER endpoint
            The OpenAI API endpoint.  
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$id,
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [ValidateSet("assistants", "files", "vector_stores")]
        [string]$kind = "assistants"
    )

    BEGIN {
        if (-not $apiKey) {
            Write-Error "API Key is required. Please provide the API key using -apiKey parameter or set the OPENAI_API_KEY environment variable."
            return
        }
        if (-not $endpoint) {
            $endpoint = "https://api.openai.com/v1/${kind}/{0}"
        }

        $headers = @{
            "Content-Type" = "application/json"
            "OpenAI-Beta"  = "assistants=v2"
        }

        if ($endpoint -match "azure") {
            $headers.Add("api-key", $apiKey)
            $endpoint = $endpoint + "openai/${kind}/{0}?api-version=2024-05-01-preview"
        }
        else {
            $headers.Add("Authorization", "Bearer $apiKey")
        }
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess("$id")) {
            $url = $endpoint -f $id
            Invoke-RestMethod -Uri $url -Headers $headers -Method Delete
        }
    }
}


function New-Assistant {
    <#
        .SYNOPSIS
            Create a new OpenAI assistant.
        .DESCRIPTION
            Create a new OpenAI assistant.
        .PARAMETER name
            The name of the assistant.
        .PARAMETER apiKey
            The OpenAI API key.
        .PARAMETER endpoint
            The OpenAI API endpoint.
        .PARAMETER instructions
            The instructions for the assistant.
        .PARAMETER model
            The model to use for the assistant.
        .PARAMETER config
            The configuration for the assistant.You can refer to https://platform.openai.com/docs/api-reference/assistants/modifyAssistant to learn more about the optional parameters.
        .PARAMETER vector_store_ids
            The vector store IDs to use for the assistant.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$name,
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [string]$instructions = "Please help me with the following:",
        [string]$model = $env:OPENAI_API_MODEL,
        [hashtable]$config,
        [string[]]$vector_store_ids
    )

    if (-not $apiKey) {
        Write-Error "API Key is required. Please provide the API key using -apiKey parameter or set the OPENAI_API_KEY environment variable."
        return
    }

    if (-not $model) {
        Write-Error "Model is required. Please provide the model using -model parameter or set the OPENAI_API_MODEL environment variable."
        return
    }

    if (-not $endpoint) {
        $endpoint = "https://api.openai.com/v1/assistants"
    }

    $headers = @{
        "Content-Type" = "application/json"
        "OpenAI-Beta"  = "assistants=v2"
    }

    if ($endpoint -match "azure") {
        $headers.Add("api-key", $apiKey)
        $endpoint = $endpoint + "openai/assistants?api-version=2024-05-01-preview"
    }
    else {
        $headers.Add("Authorization", "Bearer $apiKey")
    }

    $body = @{
        "name"         = $name
        "instructions" = $instructions
        "model"        = $model
    } 

    if ($vector_store_ids -and $vector_store_ids.Count -gt 0) {
        $body.Add("tool_resources", @{
                "file_search" = @{
                    "vector_store_ids" = @($vector_store_ids)
                }
            })

        $body.Add("tools", @{
                "type" = "file_search"
            })
    }

    # if config is provided, merge it with the body
    if ($config) {
        Merge-Hashtable -table1 $body -table2 $config
    }

    Invoke-RestMethod -Uri $endpoint -Headers $headers -Method Post -Body ($body | ConvertTo-Json -Depth 10)
}


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
        [Parameter(Mandatory = $true, Position = 0 , ValueFromPipeline = $true)]
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

        # Define the file path
        $filePath = $fullname

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

        $name = "{0}-{1}" -f (Get-FileHash $fullname).Hash, (Get-Item $fullname).Name

        # Create the request body
        $body = @"
--$boundary
Content-Disposition: form-data; name="file"; filename="$name"
Content-Type: application/octet-stream

$(Get-Content $filePath)

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