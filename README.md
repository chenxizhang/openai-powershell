This is a unofficial PowerShell Module for OpenAI, you can use the module to get completions for your input, or start the chat experience in PowerShell directly. The module can install in PowerShell 5.1 and above version, if you use PowerShell core (6.x+), you can even use it in all the platform, including Windows, MacOS and Linux.

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![](https://img.shields.io/badge/changelog-blue)](https://github.com/chenxizhang/openai-powershell/blob/master/CHANGELOG.md) [![](https://img.shields.io/badge/简体中文-blue)](README.zh.md)


## Prerequisites

You must have `PowerShell` to use this module, it is included in `Windows` by default, if you are using `MacOS` or `Linux`, you can install it by following the guidance.

- MacOS
    - You can run `brew install powershell/tap/powershell` to install PowerShell in MacOS, and then type `pwsh` in your terminal to start PowerShell.
- Linux
    - You can follow the guidance [here](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.3) to install PowerShell in Linux, and then type `pwsh` in your terminal to start PowerShell.

You also need to prepare your `API key`, this is the most important thing before you use the module, the basic understanding of the LLM models is also required. Mostly you need a subscription to use the `OpenAI` Service, `Azure OpenAI` Service or a lot of `OpenAI-like` services, and they are not free. We also support the `local` LLMs, you will be empowered in another way if you have a strong enough GPU machine.

## Install the Module

> Install-Module -Name code365scripts.openai -Scope CurrentUser

## How to use

You need the basic knowledage of [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/01-getting-started). Currently, we support below cmdlets:

- `New-ChatGPTConversation` (alias: `chat` or `chatgpt` or `gpt`) to start a chat experience in PowerShell, or automate your work in a workflow by using the gpt mode. It supports below service providers. 

    1. OpenAI service powered by [OpenAI](https://platform.openai.com).
    1. Azure OpenAI service powered by [Microsoft](https://ai.azure.com/).
    1. Local LLMs powered by [ollama](https://ollama.com/blog/openai-compatibility)
    1. DBRX powered by [Databricks](https://www.databricks.com/blog/introducing-dbrx-new-state-art-open-llm), it isn't really compatible with OpenAI, but I have done some magic, and you can just pass your api_key and endpoint to use it.
    1. OpenAI compatible services, you just pass the specific api_key and endpoint, model name when you use this cmdlet.
        1. Kimi powered by [Moonshot](https://platform.moonshot.cn/docs/api/chat)
        1. GLM powered by [Zhipu](https://maas.aminer.cn/dev/api)

- `New-ImageGeneration` (alias: `image` or `dall`) to generate image from a prompt. It supports the Azure OpenAI service, OpenAI service, and currently use the `DALL-E-3` model.

You can find the full help by using `Get-Help <cmdlet name or alias> -Full` in your terminal, we have the detailed help for each cmdlet in both English and Chinese.

## Telemetry data collection and privacy

We will collect the telemetry data to help us improve the module, we just collect `command name`,`alias name`, `if you are using azure (true or false)`, `what Powershell version you are using`, You can check the source code [here](https://github.com/chenxizhang/openai-powershell/blob/master/code365scripts.openai/Private/Submit-Telemetry.ps1). **There are nothing related to your privacy information and your input data.** If you don't want to send the telemetry data, you can add the environment variable `DISABLE_TELEMETRY_OPENAI_POWERSHELL` and set the value to `true`.

## Update the module

> Update-Module -Name code365scripts.openai

## Uninstall the Module

> UnInstall-Module -Name code365scripts.openai

>[!TIP]
> If you have any questions or suggestions, please feel free to open an issue in the [GitHub]