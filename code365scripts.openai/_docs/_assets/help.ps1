
# generate help file, run in PowerShell 5
# Install-Module -Name platyPS -Scope CurrentUser

Import-Module platyPS
import-Module  (Join-Path -Path "." -ChildPath "code365scripts.openai\code365scripts.openai.psd1") -Force

# generate the new markdown help files
New-MarkdownHelp -Module code365scripts.openai -OutputFolder .\code365scripts.openai\_docs\ -Force 
# generate the new external help files
New-ExternalHelp -Path .\code365scripts.openai\_docs\ -OutputPath .\code365scripts.openai\ -Force

# translate markdown file to zh-cn
Get-ChildItem -Filter *.md -Path code365scripts.openai\_docs | ForEach-Object {
    Write-Host "Translating $($_.FullName)"
    $newPath = $_.FullName.Replace("code365scripts.openai\_docs", "code365scripts.openai\_docs\zh-cn")
    Write-Host ([DateTime]::Now.ToString())
    gpt -system code365scripts.openai\_docs\_assets\prompt.md `
        -prompt $_.FullName `
        -outFile $newPath `
        -model moonshot-v1-128k `
        -endpoint "https://api.moonshot.cn/v1/chat/completions" `
        -api_key $env:KIMI_API_KEY `
        -config @{max_tokens = 20000 }
    Write-Host ([DateTime]::Now.ToString())
}

# generate external help file in zh-cn
New-ExternalHelp -Path .\code365scripts.openai\_docs\zh-cn -OutputPath .\code365scripts.openai\zh-cn -Force


# translate resources files
$system = @'

    You help me to translate the resources file, thank you very much. The input file is a psd1 file, and it contains a "ConvertFrom-StringData" method, and it has a parameter named "StringData". You just translate the value of the "StringData" parameter, and then save it to a new psd1 file.

    ## Rules

        - Each row is a key-value pair, you don't translate the key (for example: error_missing_api_key, or error_missing_engine), just translate the value to Chinese.        
        - You mustn't change the content structure, just translate the value of the "StringData" parameter.
        - You mustn't change the meaning of the content, just translate it to Chinese.
        - You mustn't translate those environment variable name (for example: OPENAI_API_KEY) and the parameter name (for example: -api_key).
'@


gpt -system $system `
    -prompt code365scripts.openai\resources.psd1 `
    -outFile code365scripts.openai\zh-CN\resources.psd1 `
    -model moonshot-v1-32k `
    -endpoint "https://api.moonshot.cn/v1/chat/completions" `
    -api_key $env:KIMI_API_KEY `
    -config @{max_tokens = 20000 }


# polish the readme file and then translate it to zh-cn

$params = @{
    "model" = "moonshot-v1-32k"
    "endpoint" = "https://api.moonshot.cn/v1/chat/completions"
    "api_key" = $env:KIMI_API_KEY
    "config" = @{max_tokens = 20000 }
}
$polish ="You are a English native speaker, you understand the markdown syntax very well,  you help me to polish the content, thank you very much. You just need to correct the grammar, spelling, and punctuatio. You don't need to change the content structure, just polish it."
$translate = "You are a Chinese native speaker, you understand the markdown syntax very well, you help me to translate the content, thank you very much. You just need to translate the content to Chinese, you don't need to change the content structure, just translate it."

gpt -system $polish -prompt .\README.md @params | gpt -system $translate @params -outFile .\README.zh.md