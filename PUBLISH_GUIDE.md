# PowerShell Module Publishing Guide

This guide will walk you through publishing the `code365scripts.openai` module to the PowerShell Gallery.

## 📋 Prerequisites

1. **PowerShell Gallery Account**
   - Visit [PowerShell Gallery](https://www.powershellgallery.com/)
   - Sign in with your Microsoft account
   - Go to `Account Settings` → `API Keys`
   - Create a new API Key with "Push new packages and package versions" permission

2. **PowerShellGet Module**
   ```powershell
   # Check if already installed
   Get-Module -ListAvailable PowerShellGet
   
   # Install or update if needed
   Install-Module -Name PowerShellGet -Force -AllowClobber
   ```

## 🚀 Publishing Steps

### Step 1: Run Pre-publish Check
```powershell
.\pre-publish-check.ps1
```

### Step 2: Test Publishing (Optional)
```powershell
# Use WhatIf parameter to preview the publishing process
.\publish.ps1 -NuGetApiKey 'your-api-key-here' -WhatIf
```

### Step 3: Official Publishing
```powershell
# Replace with your actual API Key
.\publish.ps1 -NuGetApiKey 'your-api-key-here'
```

## ✅ Post-publishing Verification

1. **Check PowerShell Gallery**
   - Visit: https://www.powershellgallery.com/packages/code365scripts.openai
   - Confirm the new version has been uploaded

2. **Test Installation**
   ```powershell
   # Test in a new PowerShell session
   Install-Module -Name code365scripts.openai -Force
   Get-Module -ListAvailable code365scripts.openai
   ```

3. **Test Functionality**
   ```powershell
   Import-Module code365scripts.openai
   Get-Command -Module code365scripts.openai
   ```

## 🔄 Version Management

For each new version release:

1. **Update Version Number**
   - Edit `ModuleVersion` in `code365scripts.openai.psd1`
   - Follow Semantic Versioning (SemVer)

2. **Update CHANGELOG.md**
   - Document new features, fixes, and breaking changes

3. **Run Tests**
   ```powershell
   # If you have test scripts
   .\_tests_\test.ps1
   ```

## 🛠️ Troubleshooting

### Common Errors

1. **Version Number Issue**
   ```
   Error: The specified version 'x.x.x.x' of module 'ModuleName' cannot be published as the current version 'x.x.x.x' is already available
   ```
   **Solution**: Increment the version number

2. **Invalid API Key**
   ```
   Error: The specified API key is invalid
   ```
   **Solution**: Check if API Key is correct and has sufficient permissions

3. **Module Manifest Error**
   ```
   Error: The module manifest could not be validated
   ```
   **Solution**: Run `Test-ModuleManifest` to check syntax

### Validation Commands

```powershell
# Validate module manifest
Test-ModuleManifest .\code365scripts.openai\code365scripts.openai.psd1

# Check module import
Import-Module .\code365scripts.openai -Force
Get-Module code365scripts.openai

# Verify function exports
Get-Command -Module code365scripts.openai
```

## 📞 Support

If you encounter issues:
1. Check [PowerShell Gallery documentation](https://docs.microsoft.com/en-us/powershell/scripting/gallery/)
2. Review [PowerShellGet documentation](https://docs.microsoft.com/en-us/powershell/module/powershellget/)
3. Report issues in GitHub Issues

## 🎉 After Successful Publishing

1. **Update README.md** badges
2. **Create GitHub Release**
3. **Notify users** about the new version
4. **Monitor** download statistics and user feedback

---

**Note**: First-time publishing may take a few minutes to appear in the PowerShell Gallery.
