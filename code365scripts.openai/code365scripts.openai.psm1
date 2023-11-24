Import-LocalizedData -FileName "resources.psd1" -BindingVariable "resources"

foreach ($directory in @('Public', 'Private')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" | ForEach-Object { . $_.FullName }
}