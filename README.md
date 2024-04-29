This is a unofficial PowerShell Module for OpenAI, you can use the module to get completions for your input, or start the chat experience in PowerShell directly. The module can install in PowerShell 5.1 and above version, if you use PowerShell core (6.x+), you can even use it in all the platform, including Windows, MacOS and Linux.

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai)

## Reference book

Please read the book <https://xizhang.com/openai-powershell> for more information.

## Prerequisites

You must have PowerShell to use this module, it is included in Windows by default, if you are using MacOS or Linux, you can install it by following the guidance.

- MacOS
    - You can run `brew install powershell/tap/powershell` to install PowerShell in MacOS, and then type `pwsh` in your terminal to start PowerShell.
- Linux
    - You can follow the guidance [here](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.3) to install PowerShell in Linux, and then type `pwsh` in your terminal to start PowerShell.

## Install the Module

> Install-Module -Name code365scripts.openai -Scope CurrentUser

## How to use

Currently, we support below cmdlets:

- `New-ChatGPTConversation` (alias: `chat` or `chatgpt` or `gpt`)
- `New-ImageGeneration` (alias: `image` or `dall`)

You can find the full help by using `Get-Help **cmdlet name or alias** -Full` in your terminal.

## Telemetry data collection and privacy

We will collect the telemetry data to help us improve the module, we just collect `command name`,`alias name`, `if you are using azure (true or false)`, `what Powershell version you are using`, You can check the source code [here](https://github.com/chenxizhang/openai-powershell/blob/master/code365scripts.openai/Private/Submit-Telemetry.ps1).

**There are nothing related to your privacy information and your input data.**

If you don't want to send the telemetry data, you can add the environment variable `DISABLE_TELEMETRY_OPENAI_POWERSHELL` and set the value to `true`.

## Prepare for using

You need your own OpenAI API key, please find it in below page. We are strong recommended you store those information in the environment varilable.

![image](https://user-images.githubusercontent.com/1996954/218254458-efc867cc-f34c-4315-9dfb-823e923641ee.png)

If you want to use Azure OpenAI Service, please follow the guidance [here](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/create-resource) to create your resource, and you can find the endpoint and api_key in below page.

![image](https://user-images.githubusercontent.com/1996954/218254252-91dc617b-f706-4249-9455-d8e95baa30e0.png)

The model you will find in another page. According to the newest release, you might want to check it out <https://oai.azure.com/portal> to get the deployment information.

![image](https://user-images.githubusercontent.com/1996954/218254283-0e89b3cd-e72c-4e0e-a069-ea63155ab095.png)

## Update the module

> Update-Module -Name code365scripts.openai

## Uninstall the Module

> UnInstall-Module -Name code365scripts.openai