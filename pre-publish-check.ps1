# Pre-publish check script
# Validates module integrity and best practices before publishing

$ModulePath = ".\code365scripts.openai"
$ModuleName = "code365scripts.openai"

Write-Host "🔍 PowerShell Module Pre-publish Check" -ForegroundColor Green
Write-Host "Module path: $ModulePath" -ForegroundColor Cyan
Write-Host ""

$issues = @()
$warnings = @()

# 1. Check module manifest
Write-Host "1️⃣ Checking module manifest (.psd1)" -ForegroundColor Yellow
try {
    $manifest = Test-ModuleManifest -Path "$ModulePath\$ModuleName.psd1" -ErrorAction Stop
    Write-Host "   ✅ Module manifest syntax is correct" -ForegroundColor Green
    Write-Host "   📊 Module version: $($manifest.Version)" -ForegroundColor Cyan
    Write-Host "   📊 PowerShell version requirement: $($manifest.PowerShellVersion)" -ForegroundColor Cyan
    Write-Host "   📊 Compatible editions: $($manifest.CompatiblePSEditions -join ', ')" -ForegroundColor Cyan
}
catch {
    $issues += "Module manifest validation failed: $_"
    Write-Host "   ❌ Module manifest validation failed" -ForegroundColor Red
}

# 2. Check required files
Write-Host "`n2️⃣ Checking required files" -ForegroundColor Yellow
$requiredFiles = @(
    "$ModulePath\$ModuleName.psd1",
    "$ModulePath\$ModuleName.psm1"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $($file | Split-Path -Leaf) exists" -ForegroundColor Green
    }
    else {
        $issues += "Missing required file: $file"
        Write-Host "   ❌ $($file | Split-Path -Leaf) missing" -ForegroundColor Red
    }
}

# 3. Check public functions
Write-Host "`n3️⃣ Checking public functions" -ForegroundColor Yellow
$publicFunctions = Get-ChildItem -Path "$ModulePath\Public" -Filter "*.ps1" | ForEach-Object { $_.BaseName }
$exportedFunctions = $manifest.ExportedFunctions.Keys

Write-Host "   📁 Functions in Public folder: $($publicFunctions -join ', ')" -ForegroundColor Cyan
Write-Host "   📋 Functions exported in manifest: $($exportedFunctions -join ', ')" -ForegroundColor Cyan

$missingExports = $publicFunctions | Where-Object { $_ -notin $exportedFunctions }
$extraExports = $exportedFunctions | Where-Object { $_ -notin $publicFunctions }

if ($missingExports) {
    $warnings += "The following functions are in Public folder but not exported in manifest: $($missingExports -join ', ')"
    Write-Host "   ⚠️  Not exported: $($missingExports -join ', ')" -ForegroundColor Yellow
}

if ($extraExports) {
    $warnings += "The following functions are exported in manifest but not in Public folder: $($extraExports -join ', ')"
    Write-Host "   ⚠️  Extra exports: $($extraExports -join ', ')" -ForegroundColor Yellow
}

if (-not $missingExports -and -not $extraExports) {
    Write-Host "   ✅ Function export configuration is correct" -ForegroundColor Green
}

# 4. Check documentation
Write-Host "`n4️⃣ Checking documentation" -ForegroundColor Yellow
$docFiles = @("README.md", "CHANGELOG.md", "LICENSE")
foreach ($doc in $docFiles) {
    if (Test-Path $doc) {
        Write-Host "   ✅ $doc exists" -ForegroundColor Green
    }
    else {
        $warnings += "Recommend adding $doc file"
        Write-Host "   ⚠️  $doc missing" -ForegroundColor Yellow
    }
}

# 5. Check version information
Write-Host "`n5️⃣ Checking version management" -ForegroundColor Yellow
try {
    $onlineModule = Find-Module -Name $ModuleName -ErrorAction Stop
    if ($manifest.Version -gt $onlineModule.Version) {
        Write-Host "   ✅ Version number correctly incremented ($($onlineModule.Version) → $($manifest.Version))" -ForegroundColor Green
    }
    elseif ($manifest.Version -eq $onlineModule.Version) {
        $issues += "Version number not updated, current version $($manifest.Version) is same as online version"
        Write-Host "   ❌ Version number not updated" -ForegroundColor Red
    }
    else {
        $issues += "Version number rolled back, current version $($manifest.Version) is lower than online version $($onlineModule.Version)"
        Write-Host "   ❌ Version number rolled back" -ForegroundColor Red
    }
}
catch {
    Write-Host "   📦 New module, no need to check online version" -ForegroundColor Cyan
}

# 6. Syntax check
Write-Host "`n6️⃣ PowerShell syntax check" -ForegroundColor Yellow
$psFiles = Get-ChildItem -Path $ModulePath -Filter "*.ps1" -Recurse
$syntaxErrors = @()

foreach ($file in $psFiles) {
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $file.FullName -Raw), [ref]$null)
        Write-Host "   ✅ $($file.Name) syntax correct" -ForegroundColor Green
    }
    catch {
        $syntaxErrors += "$($file.Name): $_"
        Write-Host "   ❌ $($file.Name) syntax error" -ForegroundColor Red
    }
}

if ($syntaxErrors) {
    $issues += $syntaxErrors
}

# Summary
Write-Host "`n📋 Check Summary" -ForegroundColor Green
Write-Host "=" * 50

if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "🎉 Congratulations! Module is ready for publishing!" -ForegroundColor Green
}
else {
    if ($issues.Count -gt 0) {
        Write-Host "❌ Found $($issues.Count) issues that must be fixed:" -ForegroundColor Red
        $issues | ForEach-Object { Write-Host "   • $_" -ForegroundColor Red }
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host "⚠️  Found $($warnings.Count) recommendations for improvement:" -ForegroundColor Yellow
        $warnings | ForEach-Object { Write-Host "   • $_" -ForegroundColor Yellow }
    }
}

if ($issues.Count -eq 0) {
    Write-Host "`n🚀 You can publish the module using:" -ForegroundColor Cyan
    Write-Host "   .\publish.ps1 -NuGetApiKey 'your-api-key'" -ForegroundColor White
    Write-Host "   .\publish.ps1 -NuGetApiKey 'your-api-key' -WhatIf  # Preview mode" -ForegroundColor White
}
