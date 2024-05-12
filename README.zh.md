[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![](https://img.shields.io/badge/change-logs-blue)](CHANGELOG.md) [![](https://img.shields.io/badge/lang-English-blue)](README.md) [![](https://img.shields.io/badge/用户手册-中文-blue)](https://github.com/chenxizhang/openai-powershell/discussions/categories/use-cases-%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)

这是一个非官方的OpenAI PowerShell模块，允许您直接在PowerShell中根据提示词生成任意文本或直接开始聊天体验。你可以使用包括 OpenAI, Azure OpenAI 服务以及市面上几乎所有主流的GPT服务，甚至本地大语言模型（LLM），而且采用一种非常通用的调用模式，不需要考虑他们的差异。另外，如果你经常需要处理一些批量任务，自动化的任务，或者重度依赖人工的重复性任务，这个模块将对你帮助很大。

该模块与PowerShell 5.1及以上版本兼容，如果您使用的是PowerShell Core（6.x+），则可以在所有平台上使用它，包括Windows、MacOS和Linux。

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
如果你在安装时遇到错误，请先运行 `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`.

## 快速入门

1. 使用 `chat` 命令在您的桌面上开始聊天体验，请确保在运行该命令之前设置环境变量 `OPENAI_API_KEY` 为您的 API 密钥。如果您使用的是 **Azure OpenAI 服务** 或其他平台或 LLMs 而不是 **OpenAI 服务**，您可能希望设置 `OPENAI_API_ENDPOINT` 和 `OPENAI_API_MODEL` 变量。它支持 `OpenAI`、`Azure OpenAI`、`Databricks`、`KIMI`、`智谱清言` 以及大量由 `ollama` 维护的开源模型 （如 llama3 等）和与 OpenAI 服务兼容的其他平台和大型模型。

    ![GIF 5-5-2024 10-49-20 PM](https://github.com/chenxizhang/openai-powershell/assets/1996954/eb5629f8-7014-4b0b-84e5-82259265ab07)

2. 使用 `gpt` 命令获取文本完成。您可以根据自己的提示在一行命令中生成任何文本。

    ![image](https://github.com/chenxizhang/openai-powershell/assets/1996954/f4a21c9d-93c6-4944-9936-ae3718d40857)

   想象一下，您需要使用 GPT 技术对客户反馈进行分类，然后将结果写回 CSV 文件中。您只需使用以下单行代码即可实现目标。

   ```powershell
   Import-Csv surveyresult.csv `
     | Select-Object Eamil,Feedback, `
       @{l="Category";e={gpt -system classifyprompt.md -prompt $_.Feedback}} `
     | Export-Csv surveyresult.csv
   ```

3. 使用 `image` 命令生成图像。它支持 Azure OpenAI 服务、OpenAI 服务，目前使用的是 `DALL-E-3` 模型。

    <img width="956" alt="image" src="https://github.com/chenxizhang/openai-powershell/assets/1996954/cdad0352-9a8a-4d8f-bacd-ff8dd989a4bb">

## 用户手册 

1. [一个简单指令开启你的桌面ChatGPT之旅](https://github.com/chenxizhang/openai-powershell/discussions/180)
2. [三个基本参数适配主流平台和模型](https://github.com/chenxizhang/openai-powershell/discussions/181)
3. [使用帮助](https://github.com/chenxizhang/openai-powershell/discussions/183)
4. [命令和参数的别名](https://github.com/chenxizhang/openai-powershell/discussions/182)
5. [系统指令（system) 和用户指令 (prompt)](https://github.com/chenxizhang/openai-powershell/discussions/186)
6. [个性化参数设置](https://github.com/chenxizhang/openai-powershell/discussions/185)
7. [动态传入上下文数据 - context](https://github.com/chenxizhang/openai-powershell/discussions/187)
8. [函数调用 （function_call)](https://github.com/chenxizhang/openai-powershell/discussions/189)
9. [PowerShell 5.1 版本有什么限制？](https://github.com/chenxizhang/openai-powershell/discussions/179)
10. [使用 DALL-E-3 生成图像](https://github.com/chenxizhang/openai-powershell/discussions/190)
11. [使用本地模型](https://github.com/chenxizhang/openai-powershell/discussions/191)
12. [定义和使用环境变量](https://github.com/chenxizhang/openai-powershell/discussions/197)

## 遥测数据收集和隐私

我们收集遥测数据以帮助改进模块。收集的数据包括`命令名`、`别名`、`服务提供者`、`模块版本` 和 `PowerShell版本`。您可以在[这里](https://github.com/chenxizhang/openai-powershell/blob/master/code365scripts.openai/Private/Submit-Telemetry.ps1)查看源代码。**不收集任何个人或输入数据。** 如果您不想发送遥测数据，可以将环境变量 `DISABLE_TELEMETRY_OPENAI_POWERSHELL` 设置为`true`。

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
