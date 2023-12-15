function Get-PromptContent($prompt) {
    # if the prompt is a file path, read the file as prompt
    if (Test-Path $prompt -PathType Leaf) {
        Write-Verbose "Prompt is a file path, read the file as prompt"
        $prompt = Get-Content $prompt -Raw -Encoding UTF8
    }

    # if the prompt is a url, start with http or https , read the url as prompt
    if ($prompt -match "^https?://") {
        Write-Verbose "Prompt is a url, read the url as prompt"
        $prompt = Invoke-RestMethod $prompt
    }
    
    Write-Output $prompt
}