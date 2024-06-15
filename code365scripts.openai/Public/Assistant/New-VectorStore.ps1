function New-VectorStore {
    [CmdletBinding()]
    param(
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [Parameter(Mandatory = $true)]
        [string]$name,
        [string[]]$file_ids,
        [int]$days_to_expire = 7
    )

    if (-not $apiKey) {
        Write-Error "API Key is required. Please provide the API key using -apiKey parameter or set the OPENAI_API_KEY environment variable."
        return
    }
    if (-not $endpoint) {
        $endpoint = "https://api.openai.com/v1/vector_stores"
    }

    $headers = @{
        "Content-Type" = "application/json"
        "OpenAI-Beta"  = "assistants=v2"
    }

    if ($endpoint -match "azure") {
        $headers.Add("api-key", $apiKey)
        $endpoint = $endpoint + "openai/vector_stores?api-version=2024-05-01-preview"
    }
    else {
        $headers.Add("Authorization", "Bearer $apiKey")
    }


    $body = @{
        "name"          = $name
        "file_ids"      = @($file_ids)
        "expires_after" = @{
            "days"   = $days_to_expire
            "anchor" = "last_active_at"
        }
    }

    Invoke-RestMethod -Uri $endpoint -Headers $headers -Method Post -Body ($body | ConvertTo-Json -Depth 10)
}

