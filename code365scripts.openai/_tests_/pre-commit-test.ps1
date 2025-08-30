#Requires -Version 5.1

<#
.SYNOPSIS
    Pre-commit test runner for code365scripts.openai PowerShell module
.DESCRIPTION
    This script runs essential tests before code commits to ensure module integrity.
    Designed to be fast and reliable for development workflow integration.
.NOTES
    Author: Claude Code
    Version: 1.0.0
    Usage: Run this script before committing changes to validate module functionality
#>

[CmdletBinding()]
param(
    [switch]$Fix
)

$ErrorActionPreference = "Stop"

Write-Host "🔍 Pre-commit validation for code365scripts.openai" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$startTime = Get-Date
$issues = @()

# Test 1: Module Manifest Validation
Write-Host "`n📋 Validating module manifest..." -ForegroundColor Yellow
try {
    $manifestPath = ".\code365scripts.openai\code365scripts.openai.psd1"
    Test-ModuleManifest $manifestPath -ErrorAction Stop | Out-Null
    Write-Host "✅ Module manifest is valid" -ForegroundColor Green
} catch {
    $issues += "❌ Module manifest validation failed: $($_.Exception.Message)"
    Write-Host "❌ Module manifest validation failed" -ForegroundColor Red
}

# Test 2: PowerShell Syntax Check
Write-Host "`n🔍 Checking PowerShell syntax..." -ForegroundColor Yellow
$psFiles = Get-ChildItem -Path ".\code365scripts.openai" -Filter "*.ps1" -Recurse
$syntaxErrors = 0

foreach ($file in $psFiles) {
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $file.FullName -Raw), [ref]$null)
        if ($VerbosePreference -eq 'Continue') {
            Write-Host "  SUCCESS: $($file.Name)" -ForegroundColor Green
        }
    } catch {
        $syntaxErrors++
        $issues += "❌ Syntax error in $($file.Name): $($_.Exception.Message)"
        Write-Host "  ❌ $($file.Name): Syntax error" -ForegroundColor Red
    }
}

if ($syntaxErrors -eq 0) {
    Write-Host "✅ All PowerShell files have valid syntax ($($psFiles.Count) files checked)" -ForegroundColor Green
}

# Test 3: Module Import Test
Write-Host "`n📦 Testing module import..." -ForegroundColor Yellow
try {
    Import-Module ".\code365scripts.openai\code365scripts.openai.psd1" -Force -ErrorAction Stop
    Write-Host "✅ Module imports successfully" -ForegroundColor Green
} catch {
    $issues += "❌ Module import failed: $($_.Exception.Message)"
    Write-Host "❌ Module import failed" -ForegroundColor Red
}

# Test 4: Core Functions Test
Write-Host "`n🔧 Testing core functions..." -ForegroundColor Yellow
$coreFunctions = @("New-ChatCompletions", "New-ChatGPTConversation")
$functionIssues = 0

foreach ($function in $coreFunctions) {
    try {
        $cmd = Get-Command $function -ErrorAction Stop
        if ($VerbosePreference -eq 'Continue') {
            Write-Host "  SUCCESS: $function exists" -ForegroundColor Green
        }
        
        # Check if function has help
        $help = Get-Help $function -ErrorAction SilentlyContinue
        if (-not $help -or -not $help.Synopsis -or $help.Synopsis.Trim() -eq "") {
            $functionIssues++
            $issues += "⚠️  $function missing or incomplete help documentation"
            Write-Host "  WARNING $function`: Missing help documentation" -ForegroundColor Yellow
        }
    } catch {
        $functionIssues++
        $issues += "❌ Core function $function not found or not working"
        Write-Host "  ERROR $function`: Not found" -ForegroundColor Red
    }
}

if ($functionIssues -eq 0) {
    Write-Host "SUCCESS: All core functions are available and documented" -ForegroundColor Green
}

# Test 5: Alias Test
Write-Host "`n🔗 Testing aliases..." -ForegroundColor Yellow
$aliases = @(
    @{Name = "gpt"; Target = "New-ChatCompletions"},
    @{Name = "chat"; Target = "New-ChatGPTConversation"}
)
$aliasIssues = 0

foreach ($alias in $aliases) {
    try {
        $aliasCmd = Get-Alias $alias.Name -ErrorAction Stop
        if ($aliasCmd.ResolvedCommandName -eq $alias.Target) {
            if ($VerbosePreference -eq 'Continue') {
                Write-Host "  SUCCESS: $($alias.Name) -> $($alias.Target)" -ForegroundColor Green
            }
        } else {
            $aliasIssues++
            $issues += "❌ Alias $($alias.Name) points to wrong function: $($aliasCmd.ResolvedCommandName)"
            Write-Host "  ❌ $($alias.Name): Points to wrong function" -ForegroundColor Red
        }
    } catch {
        $aliasIssues++
        $issues += "❌ Alias $($alias.Name) not found"
        Write-Host "  ❌ $($alias.Name): Not found" -ForegroundColor Red
    }
}

if ($aliasIssues -eq 0) {
    Write-Host "✅ All aliases are correctly configured" -ForegroundColor Green
}

# Test 6: Quick Functional Test
Write-Host "`n⚡ Running quick functional tests..." -ForegroundColor Yellow
try {
    # Run the quick test suite
    $testResult = & ".\code365scripts.openai\_tests_\quick-test.ps1" -Quiet -SkipApiTests
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Quick functional tests passed" -ForegroundColor Green
    } else {
        $issues += "❌ Quick functional tests failed"
        Write-Host "❌ Quick functional tests failed" -ForegroundColor Red
    }
} catch {
    $issues += "❌ Could not run quick functional tests: $($_.Exception.Message)"
    Write-Host "❌ Could not run quick functional tests" -ForegroundColor Red
}

# Test 7: Version Consistency Check
Write-Host "`n🔢 Checking version consistency..." -ForegroundColor Yellow
try {
    $manifest = Import-PowerShellDataFile ".\code365scripts.openai\code365scripts.openai.psd1"
    $version = $manifest.ModuleVersion
    
    # Check if version follows semantic versioning
    if ($version -match '^\d+\.\d+\.\d+(\.\d+)?$') {
        Write-Host "✅ Version format is valid: $version" -ForegroundColor Green
    } else {
        $issues += "⚠️  Version format should follow semantic versioning: $version"
        Write-Host "⚠️  Version format should follow semantic versioning: $version" -ForegroundColor Yellow
    }
} catch {
    $issues += "❌ Could not validate version: $($_.Exception.Message)"
    Write-Host "❌ Could not validate version" -ForegroundColor Red
}

# Test 8: File Structure Check
Write-Host "`n📁 Checking file structure..." -ForegroundColor Yellow
$requiredPaths = @(
    ".\code365scripts.openai\code365scripts.openai.psd1",
    ".\code365scripts.openai\code365scripts.openai.psm1",
    ".\code365scripts.openai\Public\New-ChatCompletions.ps1",
    ".\code365scripts.openai\Public\New-ChatGPTConversation.ps1"
)

$structureIssues = 0
foreach ($path in $requiredPaths) {
    if (Test-Path $path) {
        if ($VerbosePreference -eq 'Continue') {
            Write-Host "  SUCCESS: $path" -ForegroundColor Green
        }
    } else {
        $structureIssues++
        $issues += "❌ Missing required file: $path"
        Write-Host "  ❌ Missing: $path" -ForegroundColor Red
    }
}

if ($structureIssues -eq 0) {
    Write-Host "✅ All required files are present" -ForegroundColor Green
}

# Summary
$duration = ((Get-Date) - $startTime).TotalSeconds
Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "📊 PRE-COMMIT VALIDATION SUMMARY" -ForegroundColor Cyan
Write-Host "="*50 -ForegroundColor Cyan
Write-Host "Duration: $([math]::Round($duration, 2)) seconds" -ForegroundColor Gray
Write-Host "Issues found: $($issues.Count)" -ForegroundColor $(if ($issues.Count -eq 0) { "Green" } else { "Red" })

if ($issues.Count -gt 0) {
    Write-Host "`n🚨 ISSUES FOUND:" -ForegroundColor Red
    $issues | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    
    Write-Host "`n💡 RECOMMENDATIONS:" -ForegroundColor Yellow
    Write-Host "  1. Fix the issues listed above" -ForegroundColor White
    Write-Host "  2. Run the comprehensive test suite: .\code365scripts.openai\_tests_\comprehensive-test.ps1" -ForegroundColor White
    Write-Host "  3. Update documentation if needed" -ForegroundColor White
    Write-Host "  4. Test with actual API calls before release" -ForegroundColor White
    
    Write-Host "`n❌ PRE-COMMIT VALIDATION FAILED" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n🎉 ALL CHECKS PASSED!" -ForegroundColor Green
    Write-Host "✅ Ready for commit" -ForegroundColor Green
    exit 0
}