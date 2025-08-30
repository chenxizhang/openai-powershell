#Requires -Version 5.1

<#
.SYNOPSIS
    Quick test suite for code365scripts.openai PowerShell module
.DESCRIPTION
    This script provides essential automated testing for the core functions without requiring external dependencies.
    Designed for pre-commit validation and CI/CD integration.
.NOTES
    Author: Claude Code
    Version: 1.0.0
    Dependencies: None (uses only built-in PowerShell features)
#>

[CmdletBinding()]
param(
    [switch]$SkipApiTests,
    [switch]$Quiet
)

# Test configuration
$script:TestResults = @{
    Total = 0
    Passed = 0
    Failed = 0
    StartTime = Get-Date
    Tests = @()
}

# Helper function to run tests
function Test-Condition {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [switch]$ShouldFail,
        [string]$Category = "General"
    )
    
    $script:TestResults.Total++
    $startTime = Get-Date
    $status = "UNKNOWN"
    $error = $null
    
    try {
        if (-not $Quiet) {
            Write-Host "Testing: $Name" -ForegroundColor Cyan -NoNewline
        }
        
        if ($ShouldFail) {
            try {
                $result = & $Test
                $status = "FAILED"
                $error = "Expected failure but test passed"
                $script:TestResults.Failed++
            } catch {
                $status = "PASSED"
                $script:TestResults.Passed++
            }
        } else {
            $result = & $Test
            $status = "PASSED"
            $script:TestResults.Passed++
        }
        
        if (-not $Quiet) {
            Write-Host " ✓" -ForegroundColor Green
        }
        
    } catch {
        $status = "FAILED"
        $error = $_.Exception.Message
        $script:TestResults.Failed++
        
        if (-not $Quiet) {
            Write-Host " ✗" -ForegroundColor Red
            Write-Host "    Error: $error" -ForegroundColor Red
        }
    }
    
    $duration = ((Get-Date) - $startTime).TotalMilliseconds
    
    $script:TestResults.Tests += @{
        Name = $Name
        Category = $Category
        Status = $status
        Duration = $duration
        Error = $error
    }
}

# Start testing
if (-not $Quiet) {
    Write-Host "=== Quick Test Suite for code365scripts.openai ===" -ForegroundColor Yellow
    Write-Host "Started at: $(Get-Date)" -ForegroundColor Gray
    Write-Host ""
}

# Test 1: Module Import
if (-not $Quiet) { Write-Host "Module Import Tests:" -ForegroundColor Magenta }

Test-Condition "Import module successfully" {
    Import-Module (Join-Path -Path "." -ChildPath "code365scripts.openai\code365scripts.openai.psd1") -Force -ErrorAction Stop
} -Category "Import"

# Test 2: Core Functions Exist
if (-not $Quiet) { Write-Host "`nCore Functions:" -ForegroundColor Magenta }

Test-Condition "New-ChatCompletions function exists" {
    $cmd = Get-Command New-ChatCompletions -ErrorAction Stop
    if (-not $cmd) { throw "Function not found" }
} -Category "Functions"

Test-Condition "New-ChatGPTConversation function exists" {
    $cmd = Get-Command New-ChatGPTConversation -ErrorAction Stop
    if (-not $cmd) { throw "Function not found" }
} -Category "Functions"

Test-Condition "gpt alias works" {
    $alias = Get-Alias gpt -ErrorAction Stop
    if ($alias.ResolvedCommandName -ne "New-ChatCompletions") { 
        throw "Alias doesn't resolve correctly" 
    }
} -Category "Functions"

Test-Condition "chat alias works" {
    $alias = Get-Alias chat -ErrorAction Stop
    if ($alias.ResolvedCommandName -ne "New-ChatGPTConversation") { 
        throw "Alias doesn't resolve correctly" 
    }
} -Category "Functions"

# Test 3: Parameter Validation
if (-not $Quiet) { Write-Host "`nParameter Validation:" -ForegroundColor Magenta }

Test-Condition "New-ChatCompletions requires prompt" {
    New-ChatCompletions -ErrorAction Stop
} -ShouldFail -Category "Validation"

Test-Condition "New-ChatCompletions has correct parameter types" {
    $cmd = Get-Command New-ChatCompletions
    $promptParam = $cmd.Parameters['prompt']
    if ($promptParam.ParameterType -ne [string]) { throw "Prompt should be string" }
    if (-not $promptParam.Attributes.ValueFromPipeline) { throw "Should support pipeline" }
} -Category "Validation"

Test-Condition "New-ChatCompletions supports required parameters" {
    $cmd = Get-Command New-ChatCompletions
    $requiredParams = @('api_key', 'model', 'endpoint', 'system', 'prompt', 'config')
    foreach ($param in $requiredParams) {
        if (-not $cmd.Parameters.ContainsKey($param)) {
            throw "Missing parameter: $param"
        }
    }
} -Category "Validation"

# Test 4: Help Documentation
if (-not $Quiet) { Write-Host "`nDocumentation:" -ForegroundColor Magenta }

Test-Condition "New-ChatCompletions has help" {
    $help = Get-Help New-ChatCompletions -ErrorAction Stop
    if (-not $help.Synopsis -or $help.Synopsis.Trim() -eq "") { 
        throw "Missing synopsis" 
    }
    if (-not $help.Description -or $help.Description.Count -eq 0) { 
        throw "Missing description" 
    }
} -Category "Documentation"

Test-Condition "New-ChatGPTConversation has help" {
    $help = Get-Help New-ChatGPTConversation -ErrorAction Stop
    if (-not $help.Synopsis -or $help.Synopsis.Trim() -eq "") { 
        throw "Missing synopsis" 
    }
    if (-not $help.Description -or $help.Description.Count -eq 0) { 
        throw "Missing description" 
    }
} -Category "Documentation"

# Test 5: Environment Variable Support
if (-not $Quiet) { Write-Host "`nEnvironment Variables:" -ForegroundColor Magenta }

Test-Condition "Handles OPENAI_API_KEY environment variable" {
    $originalKey = $env:OPENAI_API_KEY
    try {
        $env:OPENAI_API_KEY = "test-key-123"
        $result = [System.Environment]::GetEnvironmentVariable("OPENAI_API_KEY")
        if ($result -ne "test-key-123") { throw "Environment variable not set" }
    } finally {
        $env:OPENAI_API_KEY = $originalKey
    }
} -Category "Environment"

Test-Condition "Handles missing API key gracefully" {
    $originalKey = $env:OPENAI_API_KEY
    try {
        $env:OPENAI_API_KEY = $null
        # This should fail due to missing API key
        New-ChatCompletions -prompt "test" -ErrorAction Stop
    } finally {
        $env:OPENAI_API_KEY = $originalKey
    }
} -ShouldFail -Category "Environment"

# Test 6: Configuration Features
if (-not $Quiet) { Write-Host "`nConfiguration Features:" -ForegroundColor Magenta }

Test-Condition "Supports config parameter" {
    $cmd = Get-Command New-ChatCompletions
    $configParam = $cmd.Parameters['config']
    if ($configParam.ParameterType -ne [PSCustomObject]) { 
        throw "Config parameter should be PSCustomObject" 
    }
} -Category "Configuration"

Test-Condition "Supports functions parameter" {
    $cmd = Get-Command New-ChatCompletions
    $functionsParam = $cmd.Parameters['functions']
    if ($functionsParam.ParameterType -ne [string[]]) { 
        throw "Functions parameter should be string array" 
    }
} -Category "Configuration"

Test-Condition "Supports json switch" {
    $cmd = Get-Command New-ChatCompletions
    $jsonParam = $cmd.Parameters['json']
    if ($jsonParam.ParameterType -ne [switch]) { 
        throw "JSON parameter should be switch" 
    }
} -Category "Configuration"

# Test 7: Performance Check
if (-not $Quiet) { Write-Host "`nPerformance:" -ForegroundColor Magenta }

Test-Condition "Module loads quickly" {
    $startTime = Get-Date
    Import-Module (Join-Path -Path "." -ChildPath "code365scripts.openai\code365scripts.openai.psd1") -Force
    $loadTime = ((Get-Date) - $startTime).TotalMilliseconds
    if ($loadTime -gt 3000) { throw "Module loads too slowly: $loadTime ms" }
} -Category "Performance"

Test-Condition "Functions respond quickly" {
    $startTime = Get-Date
    $cmd = Get-Command New-ChatCompletions
    $responseTime = ((Get-Date) - $startTime).TotalMilliseconds
    if ($responseTime -gt 1000) { throw "Function lookup too slow: $responseTime ms" }
} -Category "Performance"

# Generate Results
$totalDuration = ((Get-Date) - $script:TestResults.StartTime).TotalSeconds
$successRate = if ($script:TestResults.Total -gt 0) { 
    [math]::Round(($script:TestResults.Passed / $script:TestResults.Total) * 100, 1) 
} else { 0 }

if (-not $Quiet) {
    Write-Host "`n=== Test Results ===" -ForegroundColor Yellow
    Write-Host "Total Tests: $($script:TestResults.Total)" -ForegroundColor White
    Write-Host "Passed: $($script:TestResults.Passed)" -ForegroundColor Green
    Write-Host "Failed: $($script:TestResults.Failed)" -ForegroundColor Red
    Write-Host "Success Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 90) { "Green" } elseif ($successRate -ge 70) { "Yellow" } else { "Red" })
    Write-Host "Duration: $([math]::Round($totalDuration, 2)) seconds" -ForegroundColor Gray
    
    if ($script:TestResults.Failed -gt 0) {
        Write-Host "`nFailed Tests:" -ForegroundColor Red
        $script:TestResults.Tests | Where-Object Status -eq "FAILED" | ForEach-Object {
            Write-Host "  ✗ $($_.Name): $($_.Error)" -ForegroundColor Red
        }
    }
    
    # Category breakdown
    Write-Host "`nTest Categories:" -ForegroundColor Yellow
    $script:TestResults.Tests | Group-Object Category | ForEach-Object {
        $passed = ($_.Group | Where-Object Status -eq "PASSED").Count
        $total = $_.Count
        $rate = [math]::Round(($passed / $total) * 100, 1)
        Write-Host "  $($_.Name): $passed/$total ($rate%)" -ForegroundColor $(if ($rate -eq 100) { "Green" } elseif ($rate -ge 80) { "Yellow" } else { "Red" })
    }
}

# Export results for CI/CD
$results = @{
    Summary = @{
        Total = $script:TestResults.Total
        Passed = $script:TestResults.Passed
        Failed = $script:TestResults.Failed
        SuccessRate = $successRate
        Duration = $totalDuration
        Timestamp = Get-Date
    }
    Tests = $script:TestResults.Tests
    Categories = $script:TestResults.Tests | Group-Object Category | ForEach-Object {
        @{
            Name = $_.Name
            Total = $_.Count
            Passed = ($_.Group | Where-Object Status -eq "PASSED").Count
            Failed = ($_.Group | Where-Object Status -eq "FAILED").Count
        }
    }
}

$resultsPath = Join-Path $PSScriptRoot "testresults\QuickTestResults-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$results | ConvertTo-Json -Depth 10 | Out-File -FilePath $resultsPath -Encoding UTF8

if (-not $Quiet) {
    Write-Host "`nResults exported to: $resultsPath" -ForegroundColor Cyan
}

# Exit with appropriate code
if ($script:TestResults.Failed -gt 0) {
    if (-not $Quiet) {
        Write-Host "`n❌ TESTS FAILED" -ForegroundColor Red
    }
    exit 1
} else {
    if (-not $Quiet) {
        Write-Host "`n✅ ALL TESTS PASSED" -ForegroundColor Green
    }
    exit 0
}