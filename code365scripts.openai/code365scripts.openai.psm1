Import-LocalizedData -FileName "resources.psd1" -BindingVariable "resources"

foreach ($directory in @('Public', 'Private')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" | ForEach-Object { . $_.FullName }
}

# check if the "$home\.openai-powershell\profile.ps1" exists, if so, source it, otherwise create it and append some code
# $profilePath = "$home\.openai-powershell\profile.ps1"
# if (Test-Path $profilePath) {
#     . $profilePath
# }
# else {
#     New-Item -Path $profilePath -ItemType File -Force
#     Add-Content -Path $profilePath -Value (Get-Content "$PSScriptRoot\private\profile.ps1" -Raw)
# }

# check if the "$home\.openai-powershell\profile.json" exists, if so, read the file, and register a ArgumentCompleter for New-ChatCompletions, and New-ChatGPTConversation functions, the parameter name is environment

$profilePath = "$($env:USERPROFILE)\.openai-powershell\profile.json"

if (Test-Path $profilePath) {
    $names = (Get-Content -Path $profilePath -Raw | ConvertFrom-Json).profiles.name
    $scriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        $names | Where-Object {
            $_ -like "$wordToComplete*"
        } | ForEach-Object {
            "'$_'"
        }
    }

    Register-ArgumentCompleter -CommandName New-ChatCompletions -ParameterName environment -ScriptBlock $scriptBlock

    Register-ArgumentCompleter -CommandName New-ChatGPTConversation -ParameterName environment -ScriptBlock $scriptBlock
}
