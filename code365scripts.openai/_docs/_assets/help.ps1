
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
    gpt -azure -system code365scripts.openai\_docs\_assets\prompt.md `
        -prompt $_.FullName `
        -outFile $newPath `
        -model gpt-4-turbo
}

# generate external help file in zh-cn
New-ExternalHelp -Path .\code365scripts.openai\_docs\zh-cn -OutputPath .\code365scripts.openai\zh-cn -Force