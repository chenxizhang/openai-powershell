---
description: 这里概要性地介绍了 OpenAI PowerShell SDK。以及讲解我为什么开发这个 SDK，典型应用场景等等。
date: '2024-04-30'
author: chenxizhang | 陈希章
---

> 文档由 {{page.author}} 于 {{page.date}} 编写, 在 {{honkit.time}} 生成。

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai)


这是非官方的 PowerShell SDK, 我设计这个 SDK 的初衷和目的是为了简化大家对 OpenAI 服务访问的难度，并且将其跟自己日常的工作能无缝地结合起来。最开始其实是解决我自己的需求，然后逐渐扩展，并且形成了一个相对比较完整、完善的版本，目前它既支持OpenAI服务调用，也支持Azure OpenAI 服务调用，甚至最近还支持了本地模型的支持。另外，它不是一个简单意义上的API 封装，而是一个更加贴近 PowerShell 使用场景的 SDK， 比如支持管道操作、支持自定义输出格式， 支持文件输入输出等等，这将极大地提高用户的使用效率。






