function Get-OpenAIClient {
    param(
        [string]$apikey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [string]$model = $env:OPENAI_API_MODEL,
        [string]$apiVersion = $env:OPENAI_API_VERSION
    )

    if (!$apikey) {
        throw "OpenAI API Key is required"
    }

    if (!$endpoint) {
        throw "OpenAI API Endpoint is required"
    }

    if (!$model) {
        $model = "gpt-4o"
    }

    if (($endpoint -match "azure") -and !$apiVersion) {
        $apiVersion = "2024-05-01-preview"
    }

    return [OpenAIClient]::new($apikey, $endpoint, $model, $apiVersion)
}