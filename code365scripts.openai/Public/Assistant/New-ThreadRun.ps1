function New-ThreadRun {
    <#
        .SYNOPSIS
            Create a new thread.
        .DESCRIPTION
            Create a new thread.
        .PARAMETER apiKey
            The OpenAI API key.
        .PARAMETER endpoint
            The OpenAI API endpoint.
    #>
    [CmdletBinding()]
    param(
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [string]$threadId,
        [string]$assistantId
    )

    if (-not $apiKey) {
        Write-Error "API Key is required. Please provide the API key using -apiKey parameter or set the OPENAI_API_KEY environment variable."
        return
    }
    if (-not $endpoint) {
        $endpoint = "https://api.openai.com/v1/threads/${threadId}/runs"
    }

    $headers = @{
        "Content-Type" = "application/json"
        "OpenAI-Beta"  = "assistants=v2"
    }

    if ($endpoint -match "azure") {
        $headers.Add("api-key", $apiKey)
        $endpoint = $endpoint + "openai/threads/${threadId}/runs?api-version=2024-05-01-preview"
    }
    else {
        $headers.Add("Authorization", "Bearer $apiKey")
    }

    $result = Invoke-RestMethod -Uri $endpoint -Headers $headers -Method Post -Body (@{assistant_id = $assistantId} | ConvertTo-Json)

    return $result
}