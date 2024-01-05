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

    # if the prompt startwith lib:, read the prompt from prompt library
    if ($prompt -match "^lib:") {
        Write-Verbose "Prompt is a prompt library name, read the prompt from prompt library"
        $prompt = Get-PromptLibraryContent -Name $prompt.Replace("lib:", "")
    }
    
    Write-Output $prompt
}


function Get-PromptLibraryContent($Name) {
    $promptLibrary = "https://api.github.com/repos/code365opensource/promptlibrary/contents/final/$Name.md"
    $result = Invoke-RestMethod $promptLibrary
    if($result.content) {
        $prompt = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($result.content))
    }
    else {
        Write-Error "Prompt library $Name not found"
    }

    Write-Output $prompt
}