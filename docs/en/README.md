---
description: This briefly introduces the OpenAI PowerShell SDK, explains why I developed this SDK, typical application scenarios, and so on.
date: '2024-04-30'
author: chenxizhang | 陈希章
---

> This document was written by {{page.author}} on {{page.date}}, and was generated on {{honkit.time}}.

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai)


This is an unofficial PowerShell SDK. My initial intention and purpose for creating this SDK is to simplify everyone's access to OpenAI services, and seamlessly integrate it with their daily work. Initially, it was designed to meet my needs, then gradually extended, and formed a relatively complete version. At present, it supports both OpenAI services and Azure OpenAI service calls, and even recently supports local model support. Moreover, it is not a simple API encapsulation in the usual sense, but an SDK that is more closely related to PowerShell use scenarios, such as supporting pipeline operations, supporting custom output formats, file input/output, etc., which will greatly improve user efficiency.
