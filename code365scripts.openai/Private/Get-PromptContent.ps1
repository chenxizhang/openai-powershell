function Get-PromptContent {
    param(
        [string]$prompt,
        [hashtable]$context
    )
    
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

                Write-Verbose $resources.verbose_prompt_local_file
                $content = Get-Content $prompt -Raw -Encoding UTF8
            }

            # if the prompt is a url, start with http or https , read the url as prompt
            if ($prompt -match "^https?://") {
                $type = "url"
                Write-Verbose $resources.verbose_prompt_url
                $content = Invoke-RestMethod $prompt
            }

            # if the prompt startwith lib:, read the prompt from prompt library
            if ($prompt -match "^lib:") {
                $type = "promptlibrary"
                $lib = $prompt.Replace("lib:", "")
                Write-Verbose $resources.verbose_prompt_lib
                $content = Get-PromptLibraryContent -Name $prompt.Replace("lib:", "")
            }
        }
        catch {
            <#Do this if a terminating exception happens#>
            # ignore the error and just return the prompt
        }
    }



    # system variable
    $systemVariables = @{
        "username"       = $env:USERNAME
        "computername"   = $env:COMPUTERNAME
        "os"             = $env:OS
        "osarch"         = $env:PROCESSOR_ARCHITECTURE
        "currentTimeutc" = [System.DateTime]::UtcNow
        "currentTime"    = [System.DateTime]::Now
    }

    if (!$context) {
        $context = @{}
    }

    #merge system variables with context
    Merge-Hashtable -table1 $systemVariables -table2 $context
    $context = $systemVariables
    # if user provide the context, inject the data into the prompt by replace the context key with the context value
    if ($context) {
        foreach ($key in $context.keys) {
            $content = $content -replace "{{$key}}", $context[$key]
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
        Write-Verbose $resources.verbose_prompt_lib_gitee
        $promptLibrary = "https://gitee.com/api/v5/repos/code365opensource/promptlibrary/contents/final/$Name.md"
    }

    $result = Invoke-RestMethod $promptLibrary
    if ($result.content) {
        $prompt = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($result.content))
    }
    else {
        Write-Error ($resources.verbose_prompt_lib_notfound -f $Name)
    }

    Write-Output $prompt
}