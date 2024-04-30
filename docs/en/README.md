---
description: This provides a general introduction to the OpenAI PowerShell SDK. It also explains why I developed this SDK, typical application scenarios, and so on.
date: 2024-04-30
author: chenxizhang | 陈希章
---

> Document written by {{page.author}} on {{page.date}}, generated at {{honkit.time}}.

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai)


This is an unofficial PowerShell SDK. The original intent and purpose of designing this SDK is to simplify everyone's access to the OpenAI service and seamlessly integrate it with daily work. Initially, it was designed to meet my own needs, but then it gradually expanded and formed a relatively complete version. Currently, it supports not only OpenAI service calling, but also Azure OpenAI service calling, and even recently added support for local model usage. Moreover, it's not just a simple API encapsulation, it's a SDK more closely aligned with PowerShell usage scenarios, such as supporting pipeline operations, customizing output formats, supporting file input and output, etc., which will greatly improve user productivity.

