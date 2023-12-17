This is a unofficial PowerShell Module for OpenAI, you can use the module to get completions for your input, or start the chat experience in PowerShell directly. The module can install in PowerShell 5.1 and above version, if you use PowerShell core (6.x+), you can even use it in all the platform, including Windows, MacOS and Linux.

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai)

## Reference book

Please read the book [PowerShell for OpenAI](https://openai.book.xizhang.com/powershell) for more information.

## Install the Module

> Install-Module -Name code365scripts.openai -Scope CurrentUser

## Prepare for using

You need your own OpenAI API key, please find it in below page. We are strong recommended you store those information in the environment varilable.

![image](https://user-images.githubusercontent.com/1996954/218254458-efc867cc-f34c-4315-9dfb-823e923641ee.png)

If you want to use Azure OpenAI Service, please follow the guidance [here](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/create-resource) to create your resource, and you can find the endpoint and api_key in below page.

![image](https://user-images.githubusercontent.com/1996954/218254252-91dc617b-f706-4249-9455-d8e95baa30e0.png)

The model you will find in another page. According to the newest release, you might want to check it out <https://oai.azure.com/portal> to get the deployment information.

![image](https://user-images.githubusercontent.com/1996954/218254283-0e89b3cd-e72c-4e0e-a069-ea63155ab095.png)

## How to use

Currently, we support three cmdlets:

- `New-OpenAICompletion` (alias: `noc`)
- `New-ChatGPTConversation` (alias: `chat` or `chatgpt` )
- `New-ImageGeneration` (alias: `image` or `dall`)

You can find the full help by using `Get-Help **cmdlet name or alias** -Full` in your terminal.

## Telemetry data collection and privacy

We will collect the telemetry data to help us improve the module, we just collect `command name`,`alias name`, `if you are using azure (true or false)`, `what Powershell version you are using`, You can check the source code [here](https://github.com/chenxizhang/openai-powershell/blob/master/code365scripts.openai/Private/Submit-Telemetry.ps1).

**There are nothing related to your privacy information and your input data.**

If you don't want to send the telemetry data, you can add the environment variable `DISABLE_TELEMETRY_OPENAI_POWERSHELL` and set the value to `true`.

## Advance use cases

You can also define the environment variable in a separate file, or define your custom functions to simplify the usage. You can find the sample in the `$home\.openai-powershell\profile.ps1` file.

```
# This is the profile file for openai-powershell module, you can define your own functions here and environment variables here, and this file can be reused for multiple machines.
# Author: Ares Chen (https://github.com/chenxizhang/openai-powershell)

# environment variables (you can define your own variables here, uncomment below lines to use them)

# # OPEN AI default environment
# $env:OPENAI_API_KEY =
# # AZURE OPENAI SERVICE default environment
# $env:OPENAI_API_KEY_AZURE =
# $env:OPENAI_ENDPOINT_AZURE =
# $env:OPENAI_ENGINE_AZURE =
# $env:OPENAI_CHAT_ENGINE_AZURE =

# # AZURE OPENAI SERVICE dev environment
# $env:OPENAI_API_KEY_AZURE_DEV =
# $env:OPENAI_ENDPOINT_AZURE_DEV =
# $env:OPENAI_ENGINE_AZURE_DEV =
# $env:OPENAI_CHAT_ENGINE_AZURE_DEV =

# Custom functions
# You can define some functions here, to simplify the usage of openai-powershell module, please don't forget to add the "global" keyword before the function name, so that the function can be used in other scripts.

# function global:gptcs($inputfile,$outfile){
#     chat -azure -system "c:\temp\cs.md" -prompt $inputfile | Out-File $outfile -Encoding utf8
# }
# Then you can use gptcs function in your powershell script like this:
# gptcs "c:\temp\mycode.cs" "c:\temp\out.cs"

# if you modify this file, please re-open the powershell console to make the changes take effect.
```
## Prepare the environment variable

We recommended you to store the `api_key`, `engine` and `endpoint` in the environment variable, so you don't need to specify them in each command. You can use below command to set the environment variable.

If you use OpenAI service directly, you just need one environment variable `OPENAI_API_KEY`, and you can use below command to set it.

If you use Azure OpenAI service, you need three environment variables `OPENAI_API_KEY_AZURE`, `OPENAI_ENGINE_AZURE` (for text or code completion), `OPENAI_CHAT_ENGINE_AZURE` (for chat completion) and `OPENAI_ENDPOINT_AZURE`.

Since you can create and use multiple Azure OpenAI service resources in your real cases, we supported multiple environment for Azure OpenAI scenario. You can define even more environment variables to support multiple environments. For example, you can define `OPENAI_API_KEY_AZURE_DEV`, `OPENAI_ENGINE_AZURE_DEV`, `OPENAI_CHAT_ENGINE_AZURE_DEV` and `OPENAI_ENDPOINT_AZURE_DEV` for your dev environment, and define `OPENAI_API_KEY_AZURE_PROD`, `OPENAI_ENGINE_AZURE_PROD`, `OPENAI_CHAT_ENGINE_AZURE_PROD` and `OPENAI_ENDPOINT_AZURE_PROD` for your prod environment. If you don't define the environment variable, we will use the default environment variable `OPENAI_API_KEY_AZURE`, `OPENAI_ENGINE_AZURE`, `OPENAI_CHAT_ENGINE_AZURE` and `OPENAI_ENDPOINT_AZURE`.

> Another reason we supported multiple environments is that you can get all the models in a single Azure OpenAI service resource.


### How to define environment variable in Windows

You can use the below script template to create all the environment variables in Windows. Copy to a file, and change the value of the variables, save it as a `ps1` file, and then run it in PowerShell.

```powershell
# OPENAI SERVICE default environment
SETEX OPENAI_API_KEY=

# AZURE OPENAI SERVICE default environment
SETEX OPENAI_API_KEY_AZURE=
SETEX OPENAI_ENDPOINT_AZURE=
SETEX OPENAI_ENGINE_AZURE=
SETEX OPENAI_CHAT_ENGINE_AZURE=

# AZURE OPENAI SERVICE dev environment
SETEX OPENAI_API_KEY_AZURE_DEV=
SETEX OPENAI_ENDPOINT_AZURE_DEV=
SETEX OPENAI_ENGINE_AZURE_DEV=
SETEX OPENAI_CHAT_ENGINE_AZURE_DEV=
```

### How to define environment variable in Linux machine

You can install PowerShell in Linux machine by following the guidance [here](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.3), and enter `pwsh` in your terminal to start PowerShell, type `nano $PROFILE` to create the profile file, and then copy the below script to the file, and change the value of the variables, save it, and then type `exit` to exit PowerShell, and then type `pwsh` to start PowerShell again, you will find the environment variables are set.

```powershell
# OPENAI SERVICE default environment
$env:OPENAI_API_KEY=

# AZURE OPENAI SERVICE default environment
$env:OPENAI_API_KEY_AZURE=
$env:OPENAI_ENDPOINT_AZURE=
$env:OPENAI_ENGINE_AZURE=
$env:OPENAI_CHAT_ENGINE_AZURE=

# AZURE OPENAI SERVICE dev environment
$env:OPENAI_API_KEY_AZURE_DEV=
$env:OPENAI_ENDPOINT_AZURE_DEV=
$env:OPENAI_ENGINE_AZURE_DEV=
$env:OPENAI_CHAT_ENGINE_AZURE_DEV=
```

## Update the module

> Update-Module -Name code365scripts.openai

## Uninstall the Module

> UnInstall-Module -Name code365scripts.openai