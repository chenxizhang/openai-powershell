---
description: 本文将介绍如何使用 OpenAI PowerShell SDK 来访问 OpenAI 服务，你将安装这个模块，并且用一些基本的例子来开始熟悉它。
---

> 文档由 {{config.author}} 编写, 在 {{honkit.time}} 生成, 关于本文的反馈，请访问 {{config.ref+file.path}}, 或者在 {{config.discussion}} 提交讨论。

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai)

## 概述

{{page.description}}

## 先决条件

如果你是 Windows 用户，那么你跟世界上大多数人一样，你的电脑上已经安装了 PowerShell，这个模板支持的最低版本是 PowerShell 5.1，它是 Windows 7 就自带的版本，所以你不需要做任何额外的安装。
当然，如果你想要 Windows 上面使用最新版的 PowerShell，或者想要在 Linux 或者 macOS 上面使用 PowerShell，你可以通过下面的官方地址获取安装方式。

1. [Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)
2. [Linux](https://docs.microsoft.com/zh-cn/powershell/scripting/install/installing-powershell-core-on-linux)
3. [macOS](https://docs.microsoft.com/zh-cn/powershell/scripting/install/installing-powershell-core-on-macos)

另外一个条件就是你需要有 OpenAI 的 API Key，你可以在 [OpenAI 官网](https://platform.openai.com/signup/) 注册一个账号，然后在 [API 页面](https://platform.openai.com/api-keys) 获取你的 API Key，这个 API Key 通常都是以 sk 开头的字符串， 你在创建 API Key 的时候，还可以声明相应的权限。

> [!TIP] 如果你还没有 OpenAI 的 API Key，你可以在 [OpenAI 官网](https://platform.openai.com/signup/) 注册一个账号，然后在 [API 页面](https://platform.openai.com/api-keys) 获取你的 API Key。

![](../images/20240430214131.png)

## 安装模块

你可以通过 PowerShell Gallery 来安装 OpenAI PowerShell SDK，只需要运行下面的命令即可：

```powershell
Install-Module -Name code365scripts.openai -Scope CurrentUser
```



## 更新模块