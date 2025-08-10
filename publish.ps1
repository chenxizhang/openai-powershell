# PowerShell Gallery Publishing Script
# Author: chenxizhang

param(
    [string]$NuGetApiKey,
    [switch]$WhatIf
)

# Module path and name
$ModulePath = ".\code365scripts.openai"
$ModuleName = "code365scripts.openai"

Write-Host "🚀 Starting PowerShell module publishing: $ModuleName" -ForegroundColor Green

# 1. Validate module manifest
Write-Host "📋 Validating module manifest..." -ForegroundColor Yellow
try {
    $manifest = Test-ModuleManifest -Path "$ModulePath\$ModuleName.psd1"
    Write-Host "✅ Module manifest validation successful" -ForegroundColor Green
    Write-Host "   Module version: $($manifest.Version)" -ForegroundColor Cyan
    Write-Host "   Exported functions: $($manifest.ExportedFunctions.Keys -join ', ')" -ForegroundColor Cyan
}
catch {
    Write-Error "❌ Module manifest validation failed: $_"
    return
}

# 2. Check if PowerShellGet is installed
if (-not (Get-Module -ListAvailable -Name PowerShellGet)) {
    Write-Host "📦 Installing PowerShellGet..." -ForegroundColor Yellow
    Install-Module -Name PowerShellGet -Force -AllowClobber
}

# 3. Set PowerShell Gallery as trusted repository
Write-Host "🔒 Configuring PowerShell Gallery..." -ForegroundColor Yellow
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# 4. Check if module already exists
Write-Host "🔍 Checking if module exists in PowerShell Gallery..." -ForegroundColor Yellow
try {
    $existingModule = Find-Module -Name $ModuleName -ErrorAction Stop
    Write-Host "📦 Found existing module version: $($existingModule.Version)" -ForegroundColor Cyan
    
    if ($manifest.Version -le $existingModule.Version) {
        Write-Warning "⚠️  Current module version ($($manifest.Version)) is not higher than published version ($($existingModule.Version))"
        Write-Host "Please update module version number before publishing" -ForegroundColor Red
        return
    }
}
catch {
    Write-Host "📦 This is a new module, proceeding with first-time publishing" -ForegroundColor Green
}

# 5. Publish module
if (-not $NuGetApiKey) {
    Write-Host "⚠️  Please provide NuGet API Key" -ForegroundColor Yellow
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "  .\publish.ps1 -NuGetApiKey 'your-api-key-here'" -ForegroundColor White
    Write-Host ""
    Write-Host "To get API Key:" -ForegroundColor Cyan
    Write-Host "  1. Visit https://www.powershellgallery.com/" -ForegroundColor White
    Write-Host "  2. Sign in and go to Account Settings" -ForegroundColor White
    Write-Host "  3. Create API Key" -ForegroundColor White
    return
}

Write-Host "🚀 Publishing module to PowerShell Gallery..." -ForegroundColor Yellow
try {
    if ($WhatIf) {
        Write-Host "🔍 Simulation mode (WhatIf)" -ForegroundColor Cyan
        Publish-Module -Path $ModulePath -NuGetApiKey $NuGetApiKey -WhatIf
    }
    else {
        Publish-Module -Path $ModulePath -NuGetApiKey $NuGetApiKey -Verbose
        Write-Host "🎉 Module published successfully!" -ForegroundColor Green
        Write-Host "📦 Module link: https://www.powershellgallery.com/packages/$ModuleName" -ForegroundColor Cyan
    }
}
catch {
    Write-Error "❌ Module publishing failed: $_"
    return
}

Write-Host "✅ Publishing process completed!" -ForegroundColor Green
