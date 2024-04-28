function Get-PromptContent($prompt) {
    
    # ignore error and continue
    $ErrorActionPreference = "SilentlyContinue"

    $type = "userinput"
    $content = $prompt
    $lib = ""

    if ($prompt) {
        try {
            # if the prompt is a file path, read the file as prompt
            if (Test-Path $prompt -PathType Leaf) {
                # in linux, if the prompt is too long, it will fail
                $type = "file"

                Write-Verbose "Prompt is a file path, read the file as prompt"
                $content = Get-Content $prompt -Raw -Encoding UTF8
            }

            # if the prompt is a url, start with http or https , read the url as prompt
            if ($prompt -match "^https?://") {
                $type = "url"
                Write-Verbose "Prompt is a url, read the url as prompt"
                $content = Invoke-RestMethod $prompt
            }

            # if the prompt startwith lib:, read the prompt from prompt library
            if ($prompt -match "^lib:") {
                $type = "promptlibrary"
                $lib = $prompt.Replace("lib:", "")
                Write-Verbose "Prompt is a prompt library name, read the prompt from prompt library"
                $content = Get-PromptLibraryContent -Name $prompt.Replace("lib:", "")
            }
        }
        catch {
            <#Do this if a terminating exception happens#>
            # ignore the error and just return the prompt
        }
    }

    # restore error action preference
    $ErrorActionPreference = "Continue"
    
    Write-Output @{
        type    = $type
        content = $content
        lib     = $lib
    }
}


function Get-PromptLibraryContent($Name) {

    # if environment variable OPENAI_PROMPT_LIBRARY is set to gitee, use gitee as prompt library
    $promptLibrary = "https://api.github.com/repos/code365opensource/promptlibrary/contents/final/$Name.md"

    if ($env:OPENAI_PROMPT_LIBRARY -eq "gitee") {
        Write-Verbose "Prompt library is gitee"
        $promptLibrary = "https://gitee.com/api/v5/repos/code365opensource/promptlibrary/contents/final/$Name.md"
    }

    $result = Invoke-RestMethod $promptLibrary
    if ($result.content) {
        $prompt = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($result.content))
    }
    else {
        Write-Error "Prompt library $Name not found"
    }

    Write-Output $prompt
}