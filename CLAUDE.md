# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **code365scripts.openai** PowerShell module - an unofficial OpenAI PowerShell module that provides text completion, chat experiences, and image generation capabilities. The module supports multiple AI services including OpenAI, Azure OpenAI, local LLMs via Ollama, and various other GPT-compatible services.

## Development Commands

### Module Testing
```powershell
# Run the test suite
.\code365scripts.openai\_tests_\test.ps1

# Import module for local testing
Import-Module .\code365scripts.openai\code365scripts.openai.psd1 -Force
```

### Publishing Workflow
```powershell
# Pre-publish validation (recommended before publishing)
.\pre-publish-check.ps1

# Publish to PowerShell Gallery (requires API key)
.\publish.ps1 -NuGetApiKey "your-api-key"

# Preview publish (dry run)
.\publish.ps1 -NuGetApiKey "your-api-key" -WhatIf
```

### Module Management
```powershell
# Test module manifest
Test-ModuleManifest .\code365scripts.openai\code365scripts.openai.psd1

# Update module version in manifest before publishing
# Edit ModuleVersion in code365scripts.openai.psd1
```

## Architecture

### Module Structure
- **Public/**: Exported functions (New-ChatGPTConversation, New-ImageGeneration, New-ChatCompletions, Get-OpenAIClient)
- **Private/**: Internal helper functions (web requests, telemetry, UI dialogs)
- **Types/**: PowerShell type definitions
- **resources.psd1**: Localized strings for UI messages

### Core Functions
- `New-ChatGPTConversation` (alias: `chat`, `chatgpt`) - Interactive chat or single completions
- `New-ChatCompletions` (alias: `gpt`) - Text completions for automation
- `New-ImageGeneration` (alias: `image`, `dall`) - DALL-E image generation
- `Get-OpenAIClient` - Client configuration management

### Key Architecture Patterns
- **Modular Loading**: Main module (psm1) dynamically loads all PS1 files from Types, Public, and Private directories
- **Environment-based Configuration**: Uses environment variables (OPENAI_API_KEY, OPENAI_API_ENDPOINT, OPENAI_API_MODEL) with profile.json override support
- **Multi-Service Support**: Single API interface supports OpenAI, Azure OpenAI, Ollama, KIMI, Zhipu, and other OpenAI-compatible services
- **Dynamic Prompting**: Supports file paths, URLs, and prompt library references (lib:xxxxx format)
- **Context Injection**: Template variable replacement using {{variable}} syntax with context parameter
- **Function Calling**: Integration with PowerShell functions for AI tool use

### Configuration System
- **Profile Management**: `~/.openai-powershell/profile.json` for multiple environment configurations
- **Argument Completion**: Auto-completion for environment names and PowerShell functions
- **Background Updates**: Automatic version checking with notifications

### Dependencies
- **PowerShellExtension** (v0.0.4) - Required module dependency
- **PowerShell 5.1+** - Minimum version requirement
- **Cross-platform** - Compatible with Windows, macOS, and Linux

## Publishing Process

The module uses automated GitHub Actions for publishing:
1. **Code Signing**: All PS1/PSM1 files are digitally signed
2. **Dependency Installation**: Required modules installed before validation
3. **Manifest Validation**: Module manifest tested with dependency resolution
4. **Version Checking**: Ensures new version is higher than published version
5. **Cleanup**: Removes development files (.git, .github, .vscode) before publishing
6. **Gallery Publishing**: Publishes to PowerShell Gallery with fallback options

## Important Notes

- Module version must be incremented in `code365scripts.openai.psd1` before publishing
- All exported functions must be listed in both `FunctionsToExport` and `CmdletsToExport` arrays
- Telemetry collection can be disabled with `DISABLE_TELEMETRY_OPENAI_POWERSHELL=true`
- The module supports both interactive chat sessions and single-shot completions for automation scenarios