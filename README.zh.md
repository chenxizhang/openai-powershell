这是一个非官方的OpenAI PowerShell模块，允许您直接在PowerShell中获取输入的补全或开始聊天体验。该模块与PowerShell 5.1及以上版本兼容，如果您使用的是PowerShell Core（6.x+），则可以在所有平台上使用它，包括Windows、MacOS和Linux。

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![](https://img.shields.io/badge/changelog-blue)](https://github.com/chenxizhang/openai-powershell/blob/master/CHANGELOG.md) [![](https://img.shields.io/badge/English-blue)](README.md)

## 先决条件

要使用此模块，您必须安装PowerShell。它在Windows中默认包含。如果您使用的是MacOS或Linux，可以通过以下指导安装：

- MacOS：
  - 运行`brew install powershell/tap/powershell`在MacOS上安装PowerShell，然后在终端中输入`pwsh`启动PowerShell。
- Linux：
  - 按照[这里](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.3)的指导在Linux上安装PowerShell，然后在终端中输入`pwsh`启动PowerShell。

您还需要准备您的API密钥，这是使用模块之前必不可少的。还需要对LLM模型有基本的了解。大多数OpenAI服务、Azure OpenAI服务和许多类似OpenAI的服务都需要订阅，并且不是免费的。好消息是我们还支持本地LLM，如果您有足够强大的GPU机器，它可以为您提供额外的功能。

## 安装模块

要安装模块，请在PowerShell中运行以下命令：

```powershell
Install-Module -Name code365scripts.openai -Scope CurrentUser
```

## 如何使用

您需要对[PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/01-getting-started)有基本的了解。目前，该模块支持以下命令：

- `New-ChatGPTConversation`（别名：`chat`、`chatgpt`、`gpt`）在PowerShell中开始聊天体验或使用gpt模式自动化您的工作流程。它支持以下服务提供商：

  1. 由[OpenAI](https://platform.openai.com)支持的OpenAI服务。
  2. 由[Microsoft](https://ai.azure.com/)支持的Azure OpenAI服务。
  3. 由[ollama](https://ollama.com/blog/openai-compatibility)支持的本地LLM。
  4. 由[Databricks](https://www.databricks.com/blog/introducing-dbrx-new-state-art-open-llm)支持的DBRX，它与OpenAI不完全兼容，但通过一些调整，您可以通过提供您的API密钥和端点来使用它。
  5. 兼容OpenAI的服务，您可以在使用此命令时传递特定的API密钥、端点和模型名称。
     - 由[Moonshot](https://platform.moonshot.cn/docs/api/chat)支持的Kimi。
     - 由[Zhipu](https://maas.aminer.cn/dev/api)支持的GLM。

- `New-ImageGeneration`（别名：`image`、`dall`）从提示生成图像。它支持Azure OpenAI服务、OpenAI服务，当前使用`DALL-E-3`模型。

您可以在终端中使用`Get-Help **命令名称或别名** -Full`找到每个命令的完整帮助，包括英文和中文。

## 遥测数据收集和隐私

我们收集遥测数据以帮助改进模块。收集的数据包括`命令名称`、`别名名称`、`您是否使用Azure（true或false）`和`您正在使用的PowerShell版本`。您可以在[这里](https://github.com/chenxizhang/openai-powershell/blob/master/code365scripts.openai/Private/Submit-Telemetry.ps1)查看源代码。**不收集任何个人或输入数据。**如果您不想发送遥测数据，可以将环境变量`DISABLE_TELEMETRY_OPENAI_POWERSHELL`设置为`true`。

## 更新模块

要更新模块，请在PowerShell中运行以下命令：

```powershell
Update-Module -Name code365scripts.openai
```

## 卸载模块

要卸载模块，请在PowerShell中运行以下命令：

```powershell
Uninstall-Module -Name code365scripts.openai
```
