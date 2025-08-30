#Requires -Version 5.1

<#
.SYNOPSIS
    Interactive test suite for code365scripts.openai PowerShell module
.DESCRIPTION
    This script provides comprehensive interactive testing for the OpenAI PowerShell module.
    It includes both automated validation tests and manual API testing scenarios.
.NOTES
    Author: Enhanced by Claude Code
    Version: 2.0.0
    
    Before running API tests, ensure you have set the following environment variables:
    - OPENAI_API_KEY: Your OpenAI API key
    - OPENAI_API_MODEL: Model to use (optional, defaults to gpt-3.5-turbo)
    - OPENAI_API_ENDPOINT: API endpoint (optional, defaults to OpenAI)
    
    For testing other services, you may also set:
    - KIMI_API_KEY: For Moonshot AI testing
    - AZURE_OPENAI_* variables for Azure OpenAI testing
#>

[CmdletBinding()]
param(
    [switch]$SkipValidation,
    [switch]$SkipApiTests,
    [switch]$Interactive,
    [string]$TestCategory = "All"
)

# Initialize test tracking
$script:TestSession = @{
    StartTime = Get-Date
    ValidationResults = @()
    ApiTestResults = @()
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
}

function Write-TestHeader {
    param([string]$Title)
    Write-Host "`n" + "="*60 -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host "="*60 -ForegroundColor Cyan
}

function Write-TestSection {
    param([string]$Section)
    Write-Host "`n--- $Section ---" -ForegroundColor Yellow
}

function Test-ValidationStep {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [switch]$ShouldFail
    )
    
    $script:TestSession.TotalTests++
    Write-Host "Validating: $Name" -ForegroundColor Cyan -NoNewline
    
    try {
        if ($ShouldFail) {
            try {
                & $Test
                Write-Host " ❌ FAILED (Expected error but passed)" -ForegroundColor Red
                $script:TestSession.FailedTests++
                $script:TestSession.ValidationResults += @{Name = $Name; Status = "FAILED"; Error = "Expected failure but passed"}
            } catch {
                Write-Host " ✅ PASSED (Expected error occurred)" -ForegroundColor Green
                $script:TestSession.PassedTests++
                $script:TestSession.ValidationResults += @{Name = $Name; Status = "PASSED"; Error = $null}
            }
        } else {
            & $Test
            Write-Host " ✅ PASSED" -ForegroundColor Green
            $script:TestSession.PassedTests++
            $script:TestSession.ValidationResults += @{Name = $Name; Status = "PASSED"; Error = $null}
        }
    } catch {
        Write-Host " ❌ FAILED - $($_.Exception.Message)" -ForegroundColor Red
        $script:TestSession.FailedTests++
        $script:TestSession.ValidationResults += @{Name = $Name; Status = "FAILED"; Error = $_.Exception.Message}
    }
}

# Start testing
Write-TestHeader "OpenAI PowerShell Module Test Suite"
Write-Host "Started at: $(Get-Date)" -ForegroundColor Gray
Write-Host "Test Categories: $TestCategory" -ForegroundColor Gray

# Step 1: Module Validation Tests
if (-not $SkipValidation -and ($TestCategory -eq "All" -or $TestCategory -eq "Validation")) {
    Write-TestSection "Module Validation Tests"
    
    Test-ValidationStep "Import module successfully" {
        Import-Module (Join-Path -Path "." -ChildPath "code365scripts.openai\code365scripts.openai.psd1") -Force -ErrorAction Stop
    }
    
    Test-ValidationStep "New-ChatCompletions function exists" {
        $cmd = Get-Command New-ChatCompletions -ErrorAction Stop
        if (-not $cmd) { throw "Function not found" }
    }
    
    Test-ValidationStep "New-ChatGPTConversation function exists" {
        $cmd = Get-Command New-ChatGPTConversation -ErrorAction Stop
        if (-not $cmd) { throw "Function not found" }
    }
    
    Test-ValidationStep "gpt alias works" {
        $alias = Get-Alias gpt -ErrorAction Stop
        if ($alias.ResolvedCommandName -ne "New-ChatCompletions") { throw "Incorrect alias target" }
    }
    
    Test-ValidationStep "chat alias works" {
        $alias = Get-Alias chat -ErrorAction Stop
        if ($alias.ResolvedCommandName -ne "New-ChatGPTConversation") { throw "Incorrect alias target" }
    }
    
    Test-ValidationStep "New-ChatCompletions requires prompt parameter" {
        New-ChatCompletions -ErrorAction Stop
    } -ShouldFail
    
    Test-ValidationStep "Functions have help documentation" {
        $help1 = Get-Help New-ChatCompletions -ErrorAction Stop
        $help2 = Get-Help New-ChatGPTConversation -ErrorAction Stop
        if (-not $help1.Synopsis -or -not $help2.Synopsis) { throw "Missing help documentation" }
    }
    
    Test-ValidationStep "Module manifest is valid" {
        Test-ModuleManifest ".\code365scripts.openai\code365scripts.openai.psd1" -ErrorAction Stop | Out-Null
    }
}

# Step 2: Prepare test data for API tests
if (-not $SkipApiTests -and ($TestCategory -eq "All" -or $TestCategory -eq "API")) {
    Write-TestSection "Preparing Test Data"
    
    # Test data variables
    New-Variable -Name "prompt" -Value "能否用小学生听得懂的方式讲解一下量子力学?" -Option ReadOnly -Scope Script -Force
    New-Variable -Name "imageprompt" -Value "A photo of a cat sitting on a couch." -Option ReadOnly -Scope Script -Force
    New-Variable -Name "outputFolder" -Value ([System.IO.Path]::GetTempPath()) -Scope Script -Force
    
    # Create temporary test files
    $systemPromptFile = New-TemporaryFile
    $promptFile = New-TemporaryFile
    $dallFile = New-TemporaryFile
    
    "Please use multiple languages (简体中文,English,French) to answer my question." | Out-File $systemPromptFile.FullName -Encoding utf8
    "What's the capital of China?" | Out-File $promptFile.FullName -Encoding utf8
    "A photo of a cat sitting on a couch. The above photo is a photo of a cat sitting on a couch. The above photo is a photo of a cat sitting on a couch." | Out-File $dallFile.FullName -Encoding utf8
    
    Write-Host "✅ Test data prepared" -ForegroundColor Green
    Write-Host "  - System prompt file: $($systemPromptFile.FullName)" -ForegroundColor Gray
    Write-Host "  - User prompt file: $($promptFile.FullName)" -ForegroundColor Gray
    Write-Host "  - Image prompt file: $($dallFile.FullName)" -ForegroundColor Gray
    
    # Check environment variables
    Write-TestSection "Environment Configuration Check"
    
    $envVars = @{
        "OPENAI_API_KEY" = $env:OPENAI_API_KEY
        "OPENAI_API_MODEL" = $env:OPENAI_API_MODEL
        "OPENAI_API_ENDPOINT" = $env:OPENAI_API_ENDPOINT
        "KIMI_API_KEY" = $env:KIMI_API_KEY
    }
    
    foreach ($var in $envVars.GetEnumerator()) {
        if ($var.Value) {
            $displayValue = if ($var.Key -like "*KEY*") { 
                $var.Value.Substring(0, [Math]::Min(8, $var.Value.Length)) + "..." 
            } else { 
                $var.Value 
            }
            Write-Host "✅ $($var.Key): $displayValue" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $($var.Key): Not set" -ForegroundColor Yellow
        }
    }
    
    # Step 3: Interactive API Tests
    Write-TestSection "API Test Scenarios"
    
    if (-not $env:OPENAI_API_KEY -and -not $env:KIMI_API_KEY) {
        Write-Host "⚠️  No API keys found. Skipping API tests." -ForegroundColor Yellow
        Write-Host "   Set OPENAI_API_KEY or KIMI_API_KEY environment variables to run API tests." -ForegroundColor Gray
    } else {
        Write-Host "The following test scenarios will be executed:" -ForegroundColor Cyan
        Write-Host "Each test will pause for your review unless you specify -Interactive:`$false" -ForegroundColor Gray
        
        # Define test scenarios
        $testScenarios = @(
            @{
                Name = "Basic GPT completion"
                Command = 'gpt "What is 2+2? Please answer briefly."'
                Description = "Tests basic completion functionality with gpt alias"
            },
            @{
                Name = "Chat with custom system prompt"
                Command = 'New-ChatCompletions -system "You are a helpful math tutor" -prompt "Explain what 2+2 equals"'
                Description = "Tests system prompt functionality"
            },
            @{
                Name = "Chinese prompt test"
                Command = 'gpt -prompt $prompt'
                Description = "Tests Unicode/Chinese character handling"
            },
            @{
                Name = "File-based system prompt"
                Command = 'gpt -system $systemPromptFile.FullName -prompt "What is the capital of France?"'
                Description = "Tests reading system prompt from file"
            },
            @{
                Name = "JSON output format"
                Command = 'gpt -prompt "List 3 colors in JSON format" -json'
                Description = "Tests JSON response format"
            }
        )
        
        # Add KIMI test if API key is available
        if ($env:KIMI_API_KEY) {
            $testScenarios += @{
                Name = "KIMI API test"
                Command = 'gpt -prompt "Hello, how are you?" -api_key $env:KIMI_API_KEY -endpoint kimi -model moonshot-v1-32k'
                Description = "Tests KIMI/Moonshot AI integration"
            }
        }
        
        # Execute test scenarios
        foreach ($scenario in $testScenarios) {
            Write-Host "`n🧪 Test: $($scenario.Name)" -ForegroundColor Magenta
            Write-Host "   Description: $($scenario.Description)" -ForegroundColor Gray
            Write-Host "   Command: $($scenario.Command)" -ForegroundColor Gray
            
            if ($Interactive -ne $false) {
                $continue = Read-Host "   Press Enter to run this test, 's' to skip, or 'q' to quit"
                if ($continue -eq 'q') { 
                    Write-Host "Testing stopped by user." -ForegroundColor Yellow
                    break 
                }
                if ($continue -eq 's') { 
                    Write-Host "   ⏭️  Skipped" -ForegroundColor Yellow
                    continue 
                }
            }
            
            Write-Host "   🚀 Running..." -ForegroundColor Cyan
            
            try {
                $startTime = Get-Date
                $result = Invoke-Expression $scenario.Command
                $duration = ((Get-Date) - $startTime).TotalSeconds
                
                Write-Host "   ✅ Completed in $([math]::Round($duration, 2)) seconds" -ForegroundColor Green
                Write-Host "   📝 Response preview: $($result.ToString().Substring(0, [Math]::Min(100, $result.ToString().Length)))..." -ForegroundColor Gray
                
                $script:TestSession.ApiTestResults += @{
                    Name = $scenario.Name
                    Status = "SUCCESS"
                    Duration = $duration
                    Command = $scenario.Command
                    Error = $null
                }
                
            } catch {
                Write-Host "   ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
                
                $script:TestSession.ApiTestResults += @{
                    Name = $scenario.Name
                    Status = "FAILED"
                    Duration = 0
                    Command = $scenario.Command
                    Error = $_.Exception.Message
                }
            }
            
            Write-Host "   " + "-"*50 -ForegroundColor Gray
        }
    }
    
    # Cleanup temporary files
    Write-TestSection "Cleanup"
    try {
        Remove-Item $systemPromptFile.FullName -Force -ErrorAction SilentlyContinue
        Remove-Item $promptFile.FullName -Force -ErrorAction SilentlyContinue
        Remove-Item $dallFile.FullName -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Temporary files cleaned up" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Could not clean up all temporary files" -ForegroundColor Yellow
    }
}

# Step 4: Generate Test Report
Write-TestHeader "Test Session Summary"

$totalDuration = ((Get-Date) - $script:TestSession.StartTime).TotalSeconds
$validationPassed = ($script:TestSession.ValidationResults | Where-Object Status -eq "PASSED").Count
$validationFailed = ($script:TestSession.ValidationResults | Where-Object Status -eq "FAILED").Count
$apiPassed = ($script:TestSession.ApiTestResults | Where-Object Status -eq "SUCCESS").Count
$apiFailed = ($script:TestSession.ApiTestResults | Where-Object Status -eq "FAILED").Count

Write-Host "📊 Session Statistics:" -ForegroundColor Cyan
Write-Host "   Duration: $([math]::Round($totalDuration, 2)) seconds" -ForegroundColor White
Write-Host "   Validation Tests: $validationPassed passed, $validationFailed failed" -ForegroundColor White
Write-Host "   API Tests: $apiPassed passed, $apiFailed failed" -ForegroundColor White

if ($validationFailed -gt 0) {
    Write-Host "`n❌ Validation Issues:" -ForegroundColor Red
    $script:TestSession.ValidationResults | Where-Object Status -eq "FAILED" | ForEach-Object {
        Write-Host "   • $($_.Name): $($_.Error)" -ForegroundColor Red
    }
}

if ($apiFailed -gt 0) {
    Write-Host "`n❌ API Test Issues:" -ForegroundColor Red
    $script:TestSession.ApiTestResults | Where-Object Status -eq "FAILED" | ForEach-Object {
        Write-Host "   • $($_.Name): $($_.Error)" -ForegroundColor Red
    }
}

# Export detailed results
$reportData = @{
    SessionInfo = @{
        StartTime = $script:TestSession.StartTime
        EndTime = Get-Date
        Duration = $totalDuration
        TestCategory = $TestCategory
        Parameters = @{
            SkipValidation = $SkipValidation
            SkipApiTests = $SkipApiTests
            Interactive = $Interactive
        }
    }
    ValidationResults = $script:TestSession.ValidationResults
    ApiTestResults = $script:TestSession.ApiTestResults
    Summary = @{
        ValidationPassed = $validationPassed
        ValidationFailed = $validationFailed
        ApiPassed = $apiPassed
        ApiFailed = $apiFailed
        TotalIssues = $validationFailed + $apiFailed
    }
}

$reportPath = Join-Path $PSScriptRoot "testresults\TestSession-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$reportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`n📄 Detailed report saved to: $reportPath" -ForegroundColor Cyan

# Final status
if (($validationFailed + $apiFailed) -eq 0) {
    Write-Host "`n🎉 ALL TESTS COMPLETED SUCCESSFULLY!" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  SOME TESTS HAD ISSUES - Review the report above" -ForegroundColor Yellow
}

Write-Host "`n💡 Next Steps:" -ForegroundColor Yellow
Write-Host "   • Run quick validation: .\code365scripts.openai\_tests_\quick-test.ps1" -ForegroundColor White
Write-Host "   • Run comprehensive tests: .\code365scripts.openai\_tests_\comprehensive-test.ps1" -ForegroundColor White
Write-Host "   • Run pre-commit validation: .\code365scripts.openai\_tests_\pre-commit-test.ps1" -ForegroundColor White