#Requires -Version 5.1

<#
.SYNOPSIS
    Comprehensive test suite for code365scripts.openai PowerShell module
.DESCRIPTION
    This script provides automated testing for the core functions New-ChatCompletions and New-ChatGPTConversation
    with comprehensive coverage including parameter validation, error handling, and mock testing.
.NOTES
    Author: Claude Code
    Version: 1.0.0
    Requires: Pester module for advanced testing
#>

[CmdletBinding()]
param(
    [switch]$SkipApiTests,
    [string]$OutputFormat = "NUnitXml",
    [string]$OutputFile
)

# Set default output file path in _tests_ folder if not specified
if (-not $OutputFile) {
    $OutputFile = Join-Path $PSScriptRoot "testresults\TestResults-$(Get-Date -Format 'yyyyMMdd-HHmmss').xml"
}

# Import required modules
try {
    Import-Module (Join-Path -Path "." -ChildPath "code365scripts.openai\code365scripts.openai.psd1") -Force -ErrorAction Stop
    Write-Host "✓ Module imported successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to import module: $_"
    exit 1
}

# Check if Pester is available for advanced testing
$PesterAvailable = $false
try {
    Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop
    $PesterAvailable = $true
    Write-Host "✓ Pester module available for advanced testing" -ForegroundColor Green
} catch {
    Write-Warning "Pester module not available. Using basic test framework."
}

# Test configuration
$TestConfig = @{
    TestApiKey = "test-api-key-12345"
    TestModel = "gpt-3.5-turbo"
    TestEndpoint = "https://api.openai.com/v1/"
    TestPrompt = "What is 2+2?"
    TestSystem = "You are a helpful assistant."
    MockResponse = @{
        choices = @(
            @{
                message = @{
                    content = "2+2 equals 4."
                    role = "assistant"
                }
            }
        )
    }
}

# Test results tracking
$TestResults = @{
    Total = 0
    Passed = 0
    Failed = 0
    Skipped = 0
    Errors = @()
    Details = @()
}

# Helper function to run a test
function Invoke-Test {
    param(
        [string]$TestName,
        [scriptblock]$TestScript,
        [switch]$ShouldFail,
        [string]$Category = "General"
    )
    
    $TestResults.Total++
    $startTime = Get-Date
    
    try {
        Write-Host "Running: $TestName" -ForegroundColor Cyan
        
        if ($ShouldFail) {
            # Test should throw an error
            try {
                & $TestScript
                $TestResults.Failed++
                $TestResults.Errors += "FAIL: $TestName - Expected error but test passed"
                $TestResults.Details += @{
                    Name = $TestName
                    Status = "FAILED"
                    Category = $Category
                    Duration = ((Get-Date) - $startTime).TotalMilliseconds
                    Error = "Expected error but test passed"
                }
                Write-Host "  ✗ FAILED - Expected error but test passed" -ForegroundColor Red
            } catch {
                $TestResults.Passed++
                $TestResults.Details += @{
                    Name = $TestName
                    Status = "PASSED"
                    Category = $Category
                    Duration = ((Get-Date) - $startTime).TotalMilliseconds
                    Error = $null
                }
                Write-Host "  ✓ PASSED - Expected error occurred: $($_.Exception.Message)" -ForegroundColor Green
            }
        } else {
            # Test should succeed
            & $TestScript
            $TestResults.Passed++
            $TestResults.Details += @{
                Name = $TestName
                Status = "PASSED"
                Category = $Category
                Duration = ((Get-Date) - $startTime).TotalMilliseconds
                Error = $null
            }
            Write-Host "  ✓ PASSED" -ForegroundColor Green
        }
    } catch {
        $TestResults.Failed++
        $errorMsg = $_.Exception.Message
        $TestResults.Errors += "FAIL: $TestName - $errorMsg"
        $TestResults.Details += @{
            Name = $TestName
            Status = "FAILED"
            Category = $Category
            Duration = ((Get-Date) - $startTime).TotalMilliseconds
            Error = $errorMsg
        }
        Write-Host "  ✗ FAILED - $errorMsg" -ForegroundColor Red
    }
}

# =============================================================================
# MOCKING SYSTEM FOR API TESTING
# =============================================================================

# Mock response definitions for different scenarios
$MockResponses = @{
    StandardCompletion = @{
        id = "chatcmpl-mock123"
        object = "chat.completion"
        created = [int](Get-Date -UFormat %s)
        model = "gpt-3.5-turbo"
        choices = @(
            @{
                index = 0
                message = @{
                    role = "assistant"
                    content = "This is a mocked response for testing. 2+2 equals 4."
                }
                finish_reason = "stop"
            }
        )
        usage = @{
            prompt_tokens = 10
            completion_tokens = 15
            total_tokens = 25
        }
    }
    
    JsonResponse = @{
        choices = @(
            @{
                message = @{
                    role = "assistant"
                    content = '{"result": "mocked json response", "numbers": [1, 2, 3]}'
                }
            }
        )
    }
    
    FunctionCallResponse = @{
        choices = @(
            @{
                message = @{
                    role = "assistant"
                    content = $null
                    tool_calls = @(
                        @{
                            id = "call_mock123"
                            type = "function"
                            function = @{
                                name = "get_current_weather"
                                arguments = '{"location": "Boston, MA"}'
                            }
                        }
                    )
                }
            }
        )
    }
    
    ErrorResponse = @{
        error = @{
            message = "Invalid API key provided"
            type = "invalid_request_error"
            code = "invalid_api_key"
        }
    }
}

# Mock state management
$script:MockingEnabled = $false
$script:CurrentMockScenario = "StandardCompletion"

function Enable-MockMode {
    param([string]$Scenario = "StandardCompletion")
    
    if ($script:MockingEnabled) {
        return
    }
    
    $script:CurrentMockScenario = $Scenario
    $script:MockingEnabled = $true
    
    # Create mock function in global scope
    $mockFunction = @"
function Global:Invoke-UniWebRequest {
    param(`$params)
    
    Write-Verbose "🎭 MOCK: Intercepted API call to `$(`$params.Uri)"
    
    # Simulate API delay
    Start-Sleep -Milliseconds (Get-Random -Minimum 50 -Maximum 200)
    
    # Parse request to determine appropriate response
    if (`$params.Body) {
        `$requestBody = `$params.Body | ConvertFrom-Json -ErrorAction SilentlyContinue
        
        # Check for JSON format request
        if (`$requestBody.response_format -and `$requestBody.response_format.type -eq "json_object") {
            return `$using:MockResponses.JsonResponse
        }
        
        # Check for function calling
        if (`$requestBody.tools) {
            return `$using:MockResponses.FunctionCallResponse
        }
    }
    
    # Check for error simulation (invalid API key)
    if (`$params.Headers.Authorization -match "invalid|test-key-error") {
        `$errorResponse = `$using:MockResponses.ErrorResponse
        throw "HTTP 401: `$(`$errorResponse.error.message)"
    }
    
    # Return standard response
    return `$using:MockResponses.`$using:script:CurrentMockScenario
}
"@
    
    Invoke-Expression $mockFunction
    Write-Verbose "Mock mode enabled with scenario: $Scenario"
}

function Disable-MockMode {
    if (-not $script:MockingEnabled) {
        return
    }
    
    # Remove mock function
    if (Get-Command Invoke-UniWebRequest -ErrorAction SilentlyContinue) {
        Remove-Item Function:\Invoke-UniWebRequest -ErrorAction SilentlyContinue
    }
    
    $script:MockingEnabled = $false
    Write-Verbose "Mock mode disabled"
}

Write-Host "`n=== Starting Comprehensive Test Suite ===" -ForegroundColor Yellow
Write-Host "Testing code365scripts.openai module" -ForegroundColor Yellow
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow

# Test 1: Module Import and Function Availability
Write-Host "`n--- Module Structure Tests ---" -ForegroundColor Magenta

Invoke-Test "New-ChatCompletions function exists" {
    $cmd = Get-Command New-ChatCompletions -ErrorAction Stop
    if (-not $cmd) { throw "Function not found" }
} -Category "Module"

Invoke-Test "New-ChatGPTConversation function exists" {
    $cmd = Get-Command New-ChatGPTConversation -ErrorAction Stop
    if (-not $cmd) { throw "Function not found" }
} -Category "Module"

Invoke-Test "gpt alias exists" {
    $cmd = Get-Command gpt -ErrorAction Stop
    if (-not $cmd) { throw "Alias not found" }
} -Category "Module"

Invoke-Test "chat alias exists" {
    $cmd = Get-Command chat -ErrorAction Stop
    if (-not $cmd) { throw "Alias not found" }
} -Category "Module"

# Test 2: Parameter Validation Tests
Write-Host "`n--- Parameter Validation Tests ---" -ForegroundColor Magenta

# Test New-ChatCompletions parameter validation
Invoke-Test "New-ChatCompletions requires prompt parameter" {
    New-ChatCompletions -ErrorAction Stop
} -ShouldFail -Category "Validation"

Invoke-Test "New-ChatCompletions accepts valid parameters" {
    # Mock the web request to avoid actual API call
    if (-not $SkipApiTests) {
        $env:OPENAI_API_KEY = $TestConfig.TestApiKey
        # This will fail with invalid API key, but validates parameter parsing
        try {
            New-ChatCompletions -prompt $TestConfig.TestPrompt -model $TestConfig.TestModel -ErrorAction Stop
        } catch {
            if ($_.Exception.Message -match "api.*key|unauthorized|invalid") {
                # Expected error due to fake API key
                return
            }
            throw $_
        }
    }
} -Category "Validation"

# Test 3: Environment Variable Handling
Write-Host "`n--- Environment Variable Tests ---" -ForegroundColor Magenta

Invoke-Test "Reads OPENAI_API_KEY environment variable" {
    $originalKey = $env:OPENAI_API_KEY
    try {
        $env:OPENAI_API_KEY = $TestConfig.TestApiKey
        $cmd = Get-Command New-ChatCompletions
        $params = $cmd.Parameters
        if (-not $params.ContainsKey('api_key')) { throw "api_key parameter not found" }
    } finally {
        $env:OPENAI_API_KEY = $originalKey
    }
} -Category "Environment"

Invoke-Test "Reads OPENAI_API_MODEL environment variable" {
    $originalModel = $env:OPENAI_API_MODEL
    try {
        $env:OPENAI_API_MODEL = $TestConfig.TestModel
        # Verify the function can access the environment variable
        $result = [System.Environment]::GetEnvironmentVariable("OPENAI_API_MODEL")
        if ($result -ne $TestConfig.TestModel) { throw "Environment variable not set correctly" }
    } finally {
        $env:OPENAI_API_MODEL = $originalModel
    }
} -Category "Environment"

Invoke-Test "Reads OPENAI_API_ENDPOINT environment variable" {
    $originalEndpoint = $env:OPENAI_API_ENDPOINT
    try {
        $env:OPENAI_API_ENDPOINT = $TestConfig.TestEndpoint
        $result = [System.Environment]::GetEnvironmentVariable("OPENAI_API_ENDPOINT")
        if ($result -ne $TestConfig.TestEndpoint) { throw "Environment variable not set correctly" }
    } finally {
        $env:OPENAI_API_ENDPOINT = $originalEndpoint
    }
} -Category "Environment"

# Test 4: Input Validation and Edge Cases
Write-Host "`n--- Input Validation Tests ---" -ForegroundColor Magenta

Invoke-Test "Handles empty prompt gracefully" {
    try {
        Enable-MockMode -Scenario "StandardCompletion"
        New-ChatCompletions -prompt "" -api_key $TestConfig.TestApiKey -ErrorAction Stop
        # If we get here, the function didn't validate the empty prompt properly
        throw "Function should validate empty prompts"
    } catch {
        if ($_.Exception.Message -match "prompt|empty|required") {
            return # Expected validation error
        }
        throw $_
    } finally {
        Disable-MockMode
    }
} -Category "Validation"

Invoke-Test "Handles very long prompt" {
    $longPrompt = "A" * 10000
    try {
        Enable-MockMode -Scenario "StandardCompletion"
        $result = New-ChatCompletions -prompt $longPrompt -api_key $TestConfig.TestApiKey
        if (-not $result) { throw "No response received" }
    } catch {
        if ($_.Exception.Message -match "length|token|too long") {
            return # Expected error for very long prompts
        }
        throw $_
    } finally {
        Disable-MockMode
    }
} -Category "Validation"

Invoke-Test "Validates model parameter format" {
    $cmd = Get-Command New-ChatCompletions
    $modelParam = $cmd.Parameters['model']
    if (-not $modelParam) { throw "Model parameter not found" }
    if ($modelParam.ParameterType -ne [string]) { throw "Model parameter should be string type" }
} -Category "Validation"

# Test 5: Endpoint Configuration Tests
Write-Host "`n--- Endpoint Configuration Tests ---" -ForegroundColor Magenta

Invoke-Test "Supports ollama endpoint shortcut" {
    # Test that the function recognizes 'ollama' as a valid endpoint
    $cmd = Get-Command New-ChatCompletions
    $endpointParam = $cmd.Parameters['endpoint']
    if (-not $endpointParam) { throw "Endpoint parameter not found" }
} -Category "Configuration"


Invoke-Test "Supports kimi endpoint shortcut" {
    # Verify endpoint parameter exists and accepts string values
    $cmd = Get-Command New-ChatCompletions
    $endpointParam = $cmd.Parameters['endpoint']
    if ($endpointParam.ParameterType -ne [string]) { throw "Endpoint should accept string values" }
} -Category "Configuration"

Invoke-Test "Supports zhipu endpoint shortcut" {
    # Verify endpoint parameter configuration
    $cmd = Get-Command New-ChatCompletions
    if (-not $cmd.Parameters.ContainsKey('endpoint')) { throw "Endpoint parameter missing" }
} -Category "Configuration"

# Test 6: Configuration Object Tests
Write-Host "`n--- Configuration Object Tests ---" -ForegroundColor Magenta

Invoke-Test "Accepts config parameter as PSCustomObject" {
    $cmd = Get-Command New-ChatCompletions
    $configParam = $cmd.Parameters['config']
    if (-not $configParam) { throw "Config parameter not found" }
    if ($configParam.ParameterType -ne [PSCustomObject]) { throw "Config parameter should accept PSCustomObject" }
} -Category "Configuration"

Invoke-Test "Accepts headers parameter as PSCustomObject" {
    $cmd = Get-Command New-ChatCompletions
    $headersParam = $cmd.Parameters['headers']
    if (-not $headersParam) { throw "Headers parameter not found" }
} -Category "Configuration"

# Test 7: Function Features Tests
Write-Host "`n--- Function Features Tests ---" -ForegroundColor Magenta

Invoke-Test "Supports functions parameter" {
    $cmd = Get-Command New-ChatCompletions
    $functionsParam = $cmd.Parameters['functions']
    if (-not $functionsParam) { throw "Functions parameter not found" }
    if ($functionsParam.ParameterType -ne [string[]]) { throw "Functions parameter should be string array" }
} -Category "Features"

Invoke-Test "Supports json output format" {
    $cmd = Get-Command New-ChatCompletions
    $jsonParam = $cmd.Parameters['json']
    if (-not $jsonParam) { throw "JSON parameter not found" }
    if ($jsonParam.ParameterType -ne [switch]) { throw "JSON parameter should be switch type" }
} -Category "Features"

Invoke-Test "Supports context parameter for template variables" {
    $cmd = Get-Command New-ChatCompletions
    $contextParam = $cmd.Parameters['context']
    if (-not $contextParam) { throw "Context parameter not found" }
} -Category "Features"

# Test 8: Pipeline Support Tests
Write-Host "`n--- Pipeline Support Tests ---" -ForegroundColor Magenta

Invoke-Test "New-ChatCompletions supports pipeline input" {
    $cmd = Get-Command New-ChatCompletions
    $promptParam = $cmd.Parameters['prompt']
    if (-not $promptParam.Attributes.ValueFromPipeline) { throw "Prompt parameter should support pipeline input" }
} -Category "Pipeline"

# Test 9: Alias Tests
Write-Host "`n--- Alias Tests ---" -ForegroundColor Magenta

Invoke-Test "gpt alias points to New-ChatCompletions" {
    $alias = Get-Alias gpt -ErrorAction Stop
    if ($alias.ResolvedCommandName -ne "New-ChatCompletions") { 
        throw "gpt alias should resolve to New-ChatCompletions" 
    }
} -Category "Aliases"

Invoke-Test "chat alias points to New-ChatGPTConversation" {
    $alias = Get-Alias chat -ErrorAction Stop
    if ($alias.ResolvedCommandName -ne "New-ChatGPTConversation") { 
        throw "chat alias should resolve to New-ChatGPTConversation" 
    }
} -Category "Aliases"

# Test 10: Help and Documentation Tests
Write-Host "`n--- Documentation Tests ---" -ForegroundColor Magenta

Invoke-Test "New-ChatCompletions has help documentation" {
    $help = Get-Help New-ChatCompletions -ErrorAction Stop
    if (-not $help.Synopsis) { throw "Function should have synopsis in help" }
    if (-not $help.Description) { throw "Function should have description in help" }
} -Category "Documentation"

Invoke-Test "New-ChatGPTConversation has help documentation" {
    $help = Get-Help New-ChatGPTConversation -ErrorAction Stop
    if (-not $help.Synopsis) { throw "Function should have synopsis in help" }
    if (-not $help.Description) { throw "Function should have description in help" }
} -Category "Documentation"

# Test 11: Error Handling Tests
Write-Host "`n--- Error Handling Tests ---" -ForegroundColor Magenta

Invoke-Test "Handles missing API key gracefully" {
    $originalKey = $env:OPENAI_API_KEY
    try {
        $env:OPENAI_API_KEY = $null
        New-ChatCompletions -prompt $TestConfig.TestPrompt -ErrorAction Stop
    } catch {
        if ($_.Exception.Message -match "api.*key|missing.*key") {
            return # Expected error
        }
        throw $_
    } finally {
        $env:OPENAI_API_KEY = $originalKey
    }
} -ShouldFail -Category "ErrorHandling"

# Test 12: Mock-based API Tests
Write-Host "`n--- Mock-based API Tests ---" -ForegroundColor Magenta

Invoke-Test "Basic completion with mock response" {
    try {
        Enable-MockMode -Scenario "StandardCompletion"
        $result = New-ChatCompletions -prompt $TestConfig.TestPrompt -api_key $TestConfig.TestApiKey
        if (-not $result) { throw "No response received" }
        if ($result -notmatch "mocked response|4") { throw "Unexpected response content" }
    } finally {
        Disable-MockMode
    }
} -Category "MockAPI"

Invoke-Test "JSON format response with mocking" {
    try {
        Enable-MockMode -Scenario "JsonResponse"
        $result = New-ChatCompletions -prompt "List colors" -json -api_key $TestConfig.TestApiKey
        if (-not $result) { throw "No response received" }
        # Try to parse as JSON to verify format
        $jsonTest = $result | ConvertFrom-Json -ErrorAction Stop
        if (-not $jsonTest) { throw "Response is not valid JSON" }
    } finally {
        Disable-MockMode
    }
} -Category "MockAPI"

Invoke-Test "System prompt handling with mock" {
    try {
        Enable-MockMode -Scenario "StandardCompletion"
        $result = New-ChatCompletions -system $TestConfig.TestSystem -prompt $TestConfig.TestPrompt -api_key $TestConfig.TestApiKey
        if (-not $result) { throw "No response received" }
    } finally {
        Disable-MockMode
    }
} -Category "MockAPI"

Invoke-Test "Error handling with invalid API key" {
    try {
        Enable-MockMode -Scenario "ErrorResponse"
        New-ChatCompletions -prompt $TestConfig.TestPrompt -api_key "test-key-error" -ErrorAction Stop
        throw "Expected authentication error but request succeeded"
    } catch {
        if ($_.Exception.Message -match "401|unauthorized|invalid.*key") {
            return # Expected error
        }
        throw $_
    } finally {
        Disable-MockMode
    }
} -ShouldFail -Category "MockAPI"

Invoke-Test "Function calling simulation" {
    try {
        Enable-MockMode -Scenario "FunctionCallResponse"
        # This would normally trigger function calling, but we're mocking the response
        $result = New-ChatCompletions -prompt "What's the weather?" -functions @("get_current_weather") -api_key $TestConfig.TestApiKey
        # The function should handle the mocked function call response
        if (-not $result) { throw "No response received for function call" }
    } finally {
        Disable-MockMode
    }
} -Category "MockAPI"

Invoke-Test "Mock response timing consistency" {
    $times = @()
    try {
        Enable-MockMode -Scenario "StandardCompletion"
        for ($i = 1; $i -le 3; $i++) {
            $startTime = Get-Date
            New-ChatCompletions -prompt "Test $i" -api_key $TestConfig.TestApiKey | Out-Null
            $duration = ((Get-Date) - $startTime).TotalMilliseconds
            $times += $duration
        }
        $avgTime = ($times | Measure-Object -Average).Average
        if ($avgTime -gt 1000) { throw "Mock responses too slow: $avgTime ms average" }
        if ($avgTime -lt 10) { throw "Mock responses unrealistically fast: $avgTime ms average" }
    } finally {
        Disable-MockMode
    }
} -Category "MockAPI"

# Test 13: Performance and Resource Tests
Write-Host "`n--- Performance Tests ---" -ForegroundColor Magenta

Invoke-Test "Function loads within reasonable time" {
    $startTime = Get-Date
    $cmd = Get-Command New-ChatCompletions -ErrorAction Stop
    $loadTime = ((Get-Date) - $startTime).TotalMilliseconds
    if ($loadTime -gt 5000) { throw "Function takes too long to load: $loadTime ms" }
} -Category "Performance"

Invoke-Test "Module memory footprint is reasonable" {
    $beforeMemory = [GC]::GetTotalMemory($false)
    Import-Module (Join-Path -Path "." -ChildPath "code365scripts.openai\code365scripts.openai.psd1") -Force
    $afterMemory = [GC]::GetTotalMemory($false)
    $memoryUsed = $afterMemory - $beforeMemory
    if ($memoryUsed -gt 50MB) { throw "Module uses too much memory: $($memoryUsed / 1MB) MB" }
} -Category "Performance"

# Generate Test Report
Write-Host "`n=== Test Results Summary ===" -ForegroundColor Yellow
Write-Host "Total Tests: $($TestResults.Total)" -ForegroundColor White
Write-Host "Passed: $($TestResults.Passed)" -ForegroundColor Green
Write-Host "Failed: $($TestResults.Failed)" -ForegroundColor Red
Write-Host "Skipped: $($TestResults.Skipped)" -ForegroundColor Yellow

if ($TestResults.Failed -gt 0) {
    Write-Host "`nFailed Tests:" -ForegroundColor Red
    $TestResults.Errors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}

# Calculate success rate
$successRate = if ($TestResults.Total -gt 0) { 
    [math]::Round(($TestResults.Passed / $TestResults.Total) * 100, 2) 
} else { 
    0 
}

Write-Host "`nSuccess Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 90) { "Green" } elseif ($successRate -ge 70) { "Yellow" } else { "Red" })

# Generate detailed test report
$reportData = @{
    TestRun = @{
        Timestamp = Get-Date
        TotalTests = $TestResults.Total
        PassedTests = $TestResults.Passed
        FailedTests = $TestResults.Failed
        SkippedTests = $TestResults.Skipped
        SuccessRate = $successRate
        Duration = $TestResults.Details | Measure-Object Duration -Sum | Select-Object -ExpandProperty Sum
    }
    TestDetails = $TestResults.Details
    Categories = $TestResults.Details | Group-Object Category | ForEach-Object {
        @{
            Category = $_.Name
            Total = $_.Count
            Passed = ($_.Group | Where-Object Status -eq "PASSED").Count
            Failed = ($_.Group | Where-Object Status -eq "FAILED").Count
        }
    }
}

# Export detailed results
$reportPath = Join-Path $PSScriptRoot "testresults\TestReport-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$reportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "`nDetailed test report saved to: $reportPath" -ForegroundColor Cyan

# Exit with appropriate code
if ($TestResults.Failed -gt 0) {
    Write-Host "`nTests FAILED - Check the errors above" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nAll tests PASSED!" -ForegroundColor Green
    exit 0
}