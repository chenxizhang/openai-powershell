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
        .PARAMETER functions
            The predefined functions to use for the assistant.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$name,
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [string]$instructions = "You are the assistant, you answer users's questions based on the existing knowledge.",
        [string]$model = $env:OPENAI_API_MODEL,
        [hashtable]$config,
        [Parameter(ParameterSetName = "vector_store", Mandatory = $true)]
        [string[]]$vector_store_ids,
        [string[]]$functions,
        [Parameter(ParameterSetName = "files", Mandatory = $true)]
        [string[]]$files
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
        $target_endpoint = "https://api.openai.com/v1/assistants"
    }

    $headers = @{
        "Content-Type" = "application/json"
        "OpenAI-Beta"  = "assistants=v2"
    }

    if ($endpoint -match "azure") {
        $headers.Add("api-key", $apiKey)
        $target_endpoint = $endpoint + "openai/assistants?api-version=2024-05-01-preview"
    }
    else {
        $headers.Add("Authorization", "Bearer $apiKey")
    }

    $body = @{
        "name"         = $name
        "instructions" = $instructions
        "model"        = $model
    } 


    # if the pamameterset name is "files", then add the files to the body
    if ($PSCmdlet.ParameterSetName -eq "files") {
        # upload the files and create new vector store 
        $uploaded = (Add-FileToOpenAI -fullname $files -apiKey $apiKey -endpoint $endpoint | ConvertFrom-Json)
        $vc = New-VectorStore -name "$name - vc" -file_ids $uploaded.id -apiKey $apiKey -endpoint $endpoint

        New-Assistant -apiKey $apiKey -endpoint $endpoint -name $name -model $model -config $config -vector_store_ids $vc.id -functions $functions
        return
    }

    if ($vector_store_ids -and $vector_store_ids.Count -gt 0) {
        $body.Add("tool_resources", @{
                "file_search" = @{
                    "vector_store_ids" = @($vector_store_ids)
                }
            })

        $body.Add("tools", @(
                @{
                    "type" = "file_search"
                }))
    }

    if ($functions -and $functions.Count -gt 0) {
        
        if ($null -eq $body.tools) {
            $body.Add("tools", @())
        }

        $functions | ForEach-Object {
            $func = Get-FunctionJson -functionName $_
            $body.tools += $func
        }
    }


    # if config is provided, merge it with the body
    if ($config) {
        Merge-Hashtable -table1 $body -table2 $config
    }

    Invoke-RestMethod -Uri $target_endpoint -Headers $headers -Method Post -Body ($body | ConvertTo-Json -Depth 10)
}