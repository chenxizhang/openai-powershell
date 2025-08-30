function Get-OpenAIClient {
    param(
        [string]$apikey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [string]$model = $env:OPENAI_API_MODEL,
        [string]$apiVersion = $env:OPENAI_API_VERSION
    )

    if (!$apikey) {
        throw "OpenAI API Key is required. Please set the OPENAI_API_KEY environment variable or provide the -apikey parameter."
    }

    if (!$endpoint) {
        throw "OpenAI API Endpoint is required. Please set the OPENAI_API_ENDPOINT environment variable or provide the -endpoint parameter."
    }

    if (!$model) {
        $model = "gpt-4o"
    }

    if (($endpoint -match "azure") -and !$apiVersion) {
        $apiVersion = "2024-05-01-preview"
    }

    return [OpenAIClient]::new($apikey, $endpoint, $model, $apiVersion)
}