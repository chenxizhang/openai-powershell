# Test Suite for code365scripts.openai PowerShell Module

This directory contains a comprehensive test suite for the code365scripts.openai PowerShell module, designed to ensure module quality and reliability before commits and releases.

## 📁 Test Files Overview

### Core Test Scripts

| Script | Purpose | Usage | Dependencies |
|--------|---------|-------|--------------|
| `test.ps1` | Interactive test suite with API testing | Manual testing and validation | None |
| `quick-test.ps1` | Fast validation tests for CI/CD | Automated validation | None |
| `comprehensive-test.ps1` | Full test suite with mocking | Thorough automated testing | None |
| `pre-commit-test.ps1` | Pre-commit validation | Git hooks, development workflow | None |

### Test Categories

#### 1. **Validation Tests** (No API calls required)
- ✅ Module import and structure
- ✅ Function existence and signatures  
- ✅ Parameter validation
- ✅ Help documentation
- ✅ Alias configuration
- ✅ PowerShell syntax validation
- ✅ Module manifest validation

#### 2. **API Tests** (Requires API keys)
- 🔑 Basic completion functionality
- 🔑 System prompt handling
- 🔑 Multi-language support
- 🔑 File-based prompts
- 🔑 JSON output format
- 🔑 Multiple endpoint support (OpenAI, KIMI, Azure)
- 🔑 Function calling features

## 🚀 Quick Start

### Prerequisites

1. **PowerShell 5.1+** (Windows PowerShell or PowerShell Core)
2. **Module Source Code** in the current directory
3. **API Keys** (optional, for API tests):
   ```powershell
   $env:OPENAI_API_KEY = "your-openai-api-key"
   $env:KIMI_API_KEY = "your-kimi-api-key"  # Optional
   ```

### Running Tests

#### For Development (Quick Validation)
```powershell
# Fast validation without API calls
.\code365scripts.openai\_tests_\quick-test.ps1

# Pre-commit validation
.\code365scripts.openai\_tests_\pre-commit-test.ps1
```

#### For Comprehensive Testing
```powershell
# Interactive testing with API calls
.\code365scripts.openai\_tests_\test.ps1

# Full automated test suite
.\code365scripts.openai\_tests_\comprehensive-test.ps1
```

#### For CI/CD Integration
```powershell
# Validation only (no API calls)
.\code365scripts.openai\_tests_\quick-test.ps1 -Quiet

# Skip API tests in CI
.\code365scripts.openai\_tests_\test.ps1 -SkipApiTests -Interactive:$false
```

## 🔧 Test Configuration

### Environment Variables

| Variable | Required | Purpose | Example |
|----------|----------|---------|---------|
| `OPENAI_API_KEY` | For API tests | OpenAI authentication | `sk-...` |
| `OPENAI_API_MODEL` | Optional | Default model | `gpt-4` |
| `OPENAI_API_ENDPOINT` | Optional | Custom endpoint | `https://api.openai.com/v1/` |
| `KIMI_API_KEY` | Optional | KIMI/Moonshot testing | `kimi-...` |

### Test Parameters

#### test.ps1 Parameters
```powershell
-SkipValidation    # Skip module validation tests
-SkipApiTests      # Skip API-dependent tests  
-Interactive       # Enable/disable interactive prompts
-TestCategory      # Run specific category: "All", "Validation", "API"
```

#### quick-test.ps1 Parameters
```powershell
-SkipApiTests      # Skip API-dependent tests
-Quiet             # Minimal output for CI/CD
```

#### comprehensive-test.ps1 Parameters
```powershell
-SkipApiTests      # Skip API-dependent tests
-Verbose           # Detailed output
-OutputFormat      # Report format: "NUnitXml", "JSON"
-OutputFile        # Report file path
```

## 📊 Test Reports

All test scripts generate detailed reports:

### Report Files (Stored in `_tests_/testresults/` folder)
- **JSON Reports**: `TestSession-YYYYMMDD-HHMMSS.json`
- **Quick Test Reports**: `QuickTestResults-YYYYMMDD-HHMMSS.json`
- **Comprehensive Reports**: `TestResults-YYYYMMDD-HHMMSS.xml` (NUnit format)

**Note**: All test result files are automatically stored in the `_tests_/testresults/` folder and excluded from version control via `.gitignore`.

### Report Structure
```json
{
  "SessionInfo": {
    "StartTime": "2024-01-01T10:00:00Z",
    "Duration": 45.2,
    "TestCategory": "All"
  },
  "ValidationResults": [...],
  "ApiTestResults": [...],
  "Summary": {
    "ValidationPassed": 15,
    "ValidationFailed": 0,
    "ApiPassed": 8,
    "ApiFailed": 1,
    "TotalIssues": 1
  }
}
```

## 🔄 Automation Integration

### Git Hooks (Pre-commit)

Create `.git/hooks/pre-commit` (Windows):
```batch
@echo off
powershell -ExecutionPolicy Bypass -File ".\code365scripts.openai\_tests_\pre-commit-test.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo Pre-commit tests failed!
    exit /b 1
)
```

Create `.git/hooks/pre-commit` (Unix/Linux):
```bash
#!/bin/bash
pwsh -c ".\code365scripts.openai\_tests_\pre-commit-test.ps1"
if [ $? -ne 0 ]; then
    echo "Pre-commit tests failed!"
    exit 1
fi
```

### GitHub Actions Workflow

```yaml
name: Test Module
on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Run Validation Tests
      shell: pwsh
      run: |
        .\code365scripts.openai\_tests_\quick-test.ps1 -Quiet
        
    - name: Run API Tests (if secrets available)
      if: env.OPENAI_API_KEY != ''
      shell: pwsh
      env:
        OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
      run: |
        .\code365scripts.openai\_tests_\test.ps1 -Interactive:$false
```

### PowerShell Profile Integration

Add to your PowerShell profile for easy access:
```powershell
# Quick test function
function Test-OpenAIModule {
    param([switch]$Quick, [switch]$Full, [switch]$PreCommit)
    
    $basePath = ".\code365scripts.openai\_tests_"
    
    if ($Quick) {
        & "$basePath\quick-test.ps1"
    } elseif ($Full) {
        & "$basePath\comprehensive-test.ps1"
    } elseif ($PreCommit) {
        & "$basePath\pre-commit-test.ps1"
    } else {
        & "$basePath\test.ps1"
    }
}

# Aliases
Set-Alias -Name "test-openai" -Value Test-OpenAIModule
Set-Alias -Name "test-quick" -Value { Test-OpenAIModule -Quick }
Set-Alias -Name "test-precommit" -Value { Test-OpenAIModule -PreCommit }
```

## 🎯 Test Coverage

### Current Coverage Areas

#### ✅ Covered
- Module import and loading
- Function existence and accessibility
- Parameter validation and types
- Help documentation completeness
- Alias configuration
- Basic API functionality
- Error handling for missing credentials
- Environment variable support
- File-based prompt loading
- JSON output format
- Multi-endpoint support

#### 🔄 Partial Coverage
- Function calling features
- Streaming responses
- Azure OpenAI integration
- Profile/environment management
- Context variable substitution

#### ❌ Not Yet Covered
- Image generation functions
- Assistant API functionality
- Vector store operations
- Real-time streaming validation
- Performance benchmarking
- Memory usage analysis

## 📁 File Management

### Test Result Files

All test result files are automatically:
- ✅ **Stored in `_tests_/testresults/` folder**: Keeps results organized and separate from test scripts
- ✅ **Excluded from Git**: `.gitignore` prevents accidental commits
- ✅ **Timestamped**: Easy to identify when tests were run
- ✅ **Machine-readable**: JSON/XML formats for CI/CD integration

### Cleanup

To clean up old test results:
```powershell
# Remove all test result files
Remove-Item ".\code365scripts.openai\_tests_\testresults\*" -Exclude ".gitignore"

# Or clean files older than 7 days
Get-ChildItem ".\code365scripts.openai\_tests_\testresults\" -Exclude ".gitignore" | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | 
    Remove-Item

# Clean specific file types
Remove-Item ".\code365scripts.openai\_tests_\testresults\*TestResults*.json"
Remove-Item ".\code365scripts.openai\_tests_\testresults\*TestReport*.json"
Remove-Item ".\code365scripts.openai\_tests_\testresults\*TestSession*.json"
```

## 🐛 Troubleshooting

### Common Issues

#### "Module not found"
```powershell
# Ensure you're in the correct directory
Get-Location  # Should show the repository root
Test-Path ".\code365scripts.openai\code365scripts.openai.psd1"  # Should be True
```

#### "API tests failing"
```powershell
# Check API key configuration
$env:OPENAI_API_KEY  # Should show your API key
gpt "test" -Verbose  # Check detailed error messages
```

#### "Permission denied" on Git hooks
```bash
# Make hook executable (Unix/Linux)
chmod +x .git/hooks/pre-commit
```

### Performance Issues

If tests are running slowly:
1. Use `-SkipApiTests` for validation-only testing
2. Run `quick-test.ps1` instead of full test suite
3. Check network connectivity for API tests
4. Verify API key quotas and limits

## 📈 Contributing to Tests

### Adding New Tests

1. **Validation Tests**: Add to `Test-ValidationStep` calls in test scripts
2. **API Tests**: Add to `$testScenarios` array in `test.ps1`
3. **New Test Files**: Follow naming convention and update this README

### Test Guidelines

- ✅ **Fast**: Validation tests should complete in < 5 seconds
- ✅ **Reliable**: Tests should not depend on external services when possible
- ✅ **Clear**: Test names should clearly describe what is being tested
- ✅ **Isolated**: Tests should not depend on each other
- ✅ **Informative**: Failed tests should provide actionable error messages

### Code Quality Standards

- Use `#Requires -Version 5.1` for compatibility
- Include comprehensive help documentation
- Follow PowerShell best practices (approved verbs, proper error handling)
- Use consistent formatting and naming conventions
- Include both positive and negative test cases

## 📞 Support

For issues with the test suite:
1. Check this README for common solutions
2. Review test output and error messages
3. Verify environment configuration
4. Check module dependencies and versions
5. Create an issue in the repository with test output

---

**Last Updated**: 2024-08-30  
**Test Suite Version**: 2.0.0  
**Compatible Module Versions**: 4.0.0+