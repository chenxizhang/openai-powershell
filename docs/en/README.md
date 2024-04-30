---
title: Essential Tool
description: This article provides an overview of the OpenAI PowerShell SDK. It also explains why I developed this SDK, typical application scenarios, and more.
date: 2024-04-30
author: chenxizhang | 陈希章
---

> This document was written by {{page.author}} on {{page.date}} and generated at {{honkit.time}}.

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai)

This is an unofficial PowerShell SDK. The intention and purpose behind my design of this SDK is to simplify everyone's access to the OpenAI service and seamlessly integrate it into their daily work. Initially, it was to meet my own needs, and then it gradually expanded and formed a relatively complete version. It currently supports both OpenAI service calls and Azure OpenAI service calls, it even recently added support for local models. In addition, it is not just a simple API wrapper, but an SDK that is more aligned with PowerShell use cases, such as supporting pipeline operations, custom output formats, file input and output, etc. All these features greatly improve user efficiency.
