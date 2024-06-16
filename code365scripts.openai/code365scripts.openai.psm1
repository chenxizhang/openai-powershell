Import-LocalizedData -FileName "resources.psd1" -BindingVariable "resources"


foreach ($directory in @('Types','Public', 'Private')) {

    $path = Join-Path -Path $PSScriptRoot -ChildPath $directory
    if (Test-Path $path) {
        Get-ChildItem -Path $path -Filter "*.ps1" -File -Recurse | ForEach-Object { . $_.FullName }
    }
}

# check if the "$home\.openai-powershell\profile.json" exists, if so, read the file, and register a ArgumentCompleter for New-ChatCompletions, and New-ChatGPTConversation functions, the parameter name is environment

$profilePath = "$($env:USERPROFILE)\.openai-powershell\profile.json"

if (Test-Path $profilePath) {
    $names = (Get-Content -Path $profilePath -Raw | ConvertFrom-Json).profiles.name
    Register-ArgumentCompleter -CommandName New-ChatCompletions, New-ChatGPTConversation -ParameterName environment -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        $names | Where-Object {
            $_ -like "$wordToComplete*"
        } | ForEach-Object {
            "'$_'"
        }
    }
}


# register argumentcompleter for the functions parameter of new-chatcompletinos, and new-chatgptconversation functions, we will provide all the functions from get-command -CommandType Function
$commandNames = Get-Command -CommandType Function | Select-Object -ExpandProperty Name
Register-ArgumentCompleter -CommandName New-ChatCompletions, New-ChatGPTConversation -ParameterName functions -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $commandNames | Where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
        "'$_'"
    }
}

# check the module version and notify the user if an update is available, this will run in background

Start-Job -ScriptBlock {
    $module = "code365scripts.openai"
    $latestVersion = (Find-Module $module).Version
    $currentVersion = (Get-Module $module -ListAvailable | Select-Object -First 1).Version
    if ($latestVersion -gt $currentVersion) {
        $notification = "An update to the module ($module) is available. Current version: $currentVersion. Latest version: $latestVersion. Run 'Update-Module $module' to update the module."
        $Host.UI.RawUI.WindowTitle = "Update Available - $module"
        Write-Host $notification
    }
} -Name "check_openai_UpdateNotification"