function New-AssistantInstance {
    # https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/file-search?tabs=python

    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "openai")]
        [Parameter(ParameterSetName = "azure")]
        [string]$api_key,
        [Parameter(ParameterSetName = "azure")]
        [string]$endpoint,
        [Parameter(ParameterSetName = "azure")]
        [string]$api_version = "2024-05-01-preview",
        [Parameter(ParameterSetName = "openai")]
        [Parameter(ParameterSetName = "azure")]
        [string]$name,
        [Parameter(ParameterSetName = "openai")]
        [Parameter(ParameterSetName = "azure")]
        [string]$instruction,
        [Parameter(ParameterSetName = "openai")]
        [Parameter(ParameterSetName = "azure")]
        [string]$model,
        [Parameter(ParameterSetName = "openai")]
        [Parameter(ParameterSetName = "azure")]
        [string[]]$files,
        [Parameter(ParameterSetName = "azure", Mandatory = $true)]
        [switch]$azure
    )

    if (!$azure) {
        $endpoint = 'https://api.openai.com/v1/assistants'
    }

    if (!$api_key) {
        $api_key = [System.Environment]::GetEnvironmentVariable('OPENAI_API_KEY')
    }
    if (!$endpoint) {
        $endpoint = [System.Environment]::GetEnvironmentVariable('OPENAI_API_ENDPOINT')
    }
    

    if (!$api_key -or !$endpoint) {
        Write-Error "Please provide the API key and endpoint"
        return
    }

    if ($azure) {
        $endpoint = "${endpoint}openai/assistants?api-version=$api_version"
    }

    $headers = @{
        'api-key'      = $api_key
        'Content-Type' = 'application/json;charset=utf-8'
        'OpenAI-Beta'  = "assistants=v2"
    }

    if (!$azure) {
        $headers.'Authorization' = "Bearer $api_key"
    }


    $params = @{
        Uri         = $endpoint
        Method      = 'GET'
        Headers     = $headers
        ContentType = "application/json;charset=utf-8"
    }
    
    
    # $assistants = Invoke-UniWebRequestForContent -params $params

    # if ($assistants -and $assistants.data -and ($assistants.data | Where-Object { $_.name -eq $name })) {
    #     Write-Error "Assistant $name already exists, please try another name."
    #     return
    # }

    # Write-Host $assistants.data


    # vector_store api,  https://api.openai.com/v1/vector_stores or {endpoint}/openai/vector_stores?api-version=2024-02-01

    $endpoint = if ($azure) { ($endpoint -replace "assistants","vector_stores") } else { 'https://api.openai.com/v1/vector_stores' }

    $params.Uri = $endpoint
    Invoke-UniWebRequestForContent -params $params

    # if ($files -and ($files.Count -gt 0)) {
    #     # upload files
    #     # https://api.openai.com/v1/files or {endpoint}/openai/files?api-version=2024-02-01
    #     $endpoint = if ($azure) { "${endpoint}openai/files?api-version=$api_version" } else { 'https://api.openai.com/v1/files' }

    #     foreach ($file in $files) {
    #         $params = @{
    #             Uri         = $endpoint
    #             Method      = 'POST'
    #             Headers     = $headers
    #             InFile     = $file
    #         }

    #         $file_upload_result = Invoke-WebRequest @params
    #         if ($file_upload_result -and $file_upload_result.data) {
    #             $file_upload_result.data
    #         }
    #     }
    # }
}