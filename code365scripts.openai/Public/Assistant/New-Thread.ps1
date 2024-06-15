function New-Thread {
    <#
        .SYNOPSIS
            Create a new thread.
        .DESCRIPTION
            Create a new thread.
        .PARAMETER apiKey
            The OpenAI API key.
        .PARAMETER endpoint
            The OpenAI API endpoint.
        .Notes
            The threadId should be stored in a secure location as it is required for all subsequent API calls.
    #>
    [CmdletBinding()]
    param(
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT
    )

    if (-not $apiKey) {
        Write-Error "API Key is required. Please provide the API key using -apiKey parameter or set the OPENAI_API_KEY environment variable."
        return
    }
    if (-not $endpoint) {
        $endpoint = "https://api.openai.com/v1/threads"
    }

    $headers = @{
        "Content-Type" = "application/json"
        "OpenAI-Beta"  = "assistants=v2"
    }

    if ($endpoint -match "azure") {
        $headers.Add("api-key", $apiKey)
        $endpoint = $endpoint + "openai/threads?api-version=2024-05-01-preview"
    }
    else {
        $headers.Add("Authorization", "Bearer $apiKey")
    }

    $result = Invoke-RestMethod -Uri $endpoint -Headers $headers -Method Post
    return $result
}