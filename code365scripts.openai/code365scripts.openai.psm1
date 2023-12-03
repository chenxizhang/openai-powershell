Import-LocalizedData -FileName "resources.psd1" -BindingVariable "resources"

foreach ($directory in @('Public', 'Private')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" | ForEach-Object { . $_.FullName }
}

# check if the "$home\.openai-powershell\profile.ps1" exists, if so, source it, otherwise create it and append some code
$profilePath = "$home\.openai-powershell\profile.ps1"
if (Test-Path $profilePath) {
    . $profilePath
}
else {
    New-Item -Path $profilePath -ItemType File -Force
    Add-Content -Path $profilePath -Value (Get-Content "$PSScriptRoot\private\profile.ps1" -Raw)
}