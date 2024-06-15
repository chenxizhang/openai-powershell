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
        [string]$kind
    )

    if (-not $kind) {
        Get-AssistantResources -apiKey $apiKey -endpoint $endpoint -kind "assistants"
        Get-AssistantResources -apiKey $apiKey -endpoint $endpoint -kind "files"
        Get-AssistantResources -apiKey $apiKey -endpoint $endpoint -kind "vector_stores"
        return
    }

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