[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![](https://img.shields.io/badge/change-logs-blue)](CHANGELOG.md) [![](https://img.shields.io/badge/lang-简体中文-blue)](README.zh.md) [![](https://img.shields.io/badge/user_manual-English-blue)](https://github.com/chenxizhang/openai-powershell/discussions/categories/use-cases)

This is an unofficial OpenAI PowerShell module that allows you to get input completion or start a chat experience directly in PowerShell. This module is compatible with PowerShell 5.1 and above, and if you are using PowerShell Core (6.x+), it can be used on all platforms including Windows, MacOS, and Linux.

## Prerequisites

To use this module, you must install PowerShell. It is included by default in Windows. If you are using MacOS or Linux, you can install it using the following guide:

- MacOS:
  - Run `brew install powershell/tap/powershell` to install PowerShell on MacOS, then enter `pwsh` in the terminal to launch PowerShell.
- Linux:
  - Follow the guide [here](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.3) to install PowerShell on Linux, then enter `pwsh` in the terminal to launch PowerShell.

You will also need to prepare your API key, which is essential before using the module. A basic understanding of LLM models is also necessary. Most OpenAI services, Azure OpenAI services, and many services similar to OpenAI require a subscription and are not free. The good news is we also support local LLM if you have a powerful GPU machine, which can offer additional functionality.

## Install the Module

To install the module, run the following command in PowerShell:

```powershell
Install-Module -Name code365scripts.openai -Scope CurrentUser
```
Currently, the module supports the following commands:
#### New-ChatGPTConversation
This command (aliases: `chat`, `chatgpt`, `gpt`) starts a chat experience or automates your workflow using gpt mode in PowerShell. It supports `OpenAI`, `Azure OpenAI`, `Databricks`, `KIMI`, `Zhipu Qingyan`, and a large number of open-source models run by `ollama` (such as llama3, etc.) and any other platforms and large models compatible with OpenAI services.

#### New-ImageGeneration
This command (aliases: `image`, `dall`) generates images from prompts. It supports the Azure OpenAI service, OpenAI service, currently using the `DALL-E-3` model.

## User Manual

1. [Start your desktop ChatGPT journey with a simple command](https://github.com/chenxizhang/openai-powershell/discussions/180)
2. [Three basic parameters adapted to mainstream platforms and models](https://github.com/chenxizhang/openai-powershell/discussions/181)
3. [Get Help](https://github.com/chenxizhang/openai-powershell/discussions/183)
4. [Aliases for commands and parameters](https://github.com/chenxizhang/openai-powershell/discussions/182)
5. [System and user prompts](https://github.com/chenxizhang/openai-powershell/discussions/186)
6. [Customizing Settings](https://github.com/chenxizhang/openai-powershell/discussions/185)
7. [Dynamically passing context data](https://github.com/chenxizhang/openai-powershell/discussions/187)
8. [Function calls](https://github.com/chenxizhang/openai-powershell/discussions/189)
9. [What are the limitations of PowerShell 5.1 version?](https://github.com/chenxizhang/openai-powershell/discussions/179)
10. [Using DALL-E-3 to generate images](https://github.com/chenxizhang/openai-powershell/discussions/190)
11. [Using local models](https://github.com/chenxizhang/openai-powershell/discussions/191)

## Telemetry Data Collection and Privacy

We collect telemetry data to help improve the module. The collected data includes `command name`, `alias`, `service provider`, `module version`, and `PowerShell version`. You can view the source code [here](https://github.com/chenxizhang/openai-powershell/blob/master/code365scripts.openai/Private/Submit-Telemetry.ps1). **No personal or input data is collected.** If you do not wish to send telemetry data, you can set the environment variable `DISABLE_TELEMETRY_OPENAI_POWERSHELL` to `true`.

## Update the Module

To update the module, run the following command in PowerShell:

```powershell
Update-Module -Name code365scripts.openai
```

## Uninstall the Module

To uninstall the module, run the following command in PowerShell:

```powershell
Uninstall-Module -Name code365scripts.openai
```
