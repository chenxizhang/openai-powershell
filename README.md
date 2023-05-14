---
title: Unleash your infinite potential in your favorite terminal
---

# OpenAI Powershell Module

This is a unofficial PowerShell Module for OpenAI, you can use the module to get completions for your input, or start the chat experience in PowerShell directly. The module can install in PowerShell 5.1 and above version, if you use PowerShell core (6.x+), you can even use it in all the platform, including Windows, MacOS and Linux.

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/code365scripts.openai?label=code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/code365scripts.openai)](https://www.powershellgallery.com/packages/code365scripts.openai)

## Install the Module

> Install-Module -Name code365scripts.openai

## Update the module

> Update-Module -Name code365scripts.openai

## Prepare for using

You need your own OpenAI API key, please find it in below page. We are strong recommended you store those information in the environment varilable.

![image](https://user-images.githubusercontent.com/1996954/218254458-efc867cc-f34c-4315-9dfb-823e923641ee.png)

If you want to use Azure OpenAI Service, you can find the endpoint and api_key in below page.

![image](https://user-images.githubusercontent.com/1996954/218254252-91dc617b-f706-4249-9455-d8e95baa30e0.png)

The model you will find in another page.

![image](https://user-images.githubusercontent.com/1996954/218254283-0e89b3cd-e72c-4e0e-a069-ea63155ab095.png)

## How to use

Currently, we support two cmdlets, `New-OpenAICompletion` (alias: `noc`) and `New-ChatGPTConversation` (alias: `chat` or `chatgpt` ), you can find the full help by using `Get-Help noc -Full` in your terminal.

### New-OpenAICompletion

```
SYNOPSIS
    Get completion from OpenAI API


SYNTAX

    New-OpenAICompletion [-prompt] <String> [-api_key <String>] [-engine <String>] [-endpoint <String>] [-max_tokens <Int32>] [-temperature <Double>] [-n <Int32>] [-azure] [<CommonParameters>]


DESCRIPTION

    Get completion from OpenAI API, you can use this cmdlet to get completion from OpenAI API.The cmdlet accept pipeline input. You can also assign the prompt, api_key, engine, endpoint, max_tokens, temperature, n parameters.


PARAMETERS

    -prompt <String>
        The prompt to get completion from OpenAI API

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false

    -api_key <String>
        The api_key to get completion from OpenAI API. You can also set api_key in environment variable OPENAI_API_KEY or OPENAI_API_KEY_Azure (if you want to use Azure OpenAI Service API).

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -engine <String>
        The engine to get completion from OpenAI API. You can also set engine in environment variable OPENAI_ENGINE or OPENAI_ENGINE_Azure (if you want to use Azure OpenAI Service API).

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -endpoint <String>
        The endpoint to get completion from OpenAI API. You can also set endpoint in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_Azure (if you want to use Azure OpenAI Service API).

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -max_tokens <Int32>
        The max_tokens to get completion from OpenAI API. The default value is 1024.

        Required?                    false
        Position?                    named
        Default value                1024
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -temperature <Double>
        The temperature to get completion from OpenAI API. The default value is 1, which means most creatively.

        Required?                    false
        Position?                    named
        Default value                1
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -n <Int32>
        If you want to get multiple completion, you can use this parameter. The default value is 1.

        Required?                    false
        Position?                    named
        Default value                1
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -azure [<SwitchParameter>]
        If you want to use Azure OpenAI API, you can use this switch.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

    System.String, you can pass one or more string to the cmdlet, and we will get the completion for you.


OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > New-OpenAICompletion -prompt "Which city is the capital of China?"
    Use default api_key, engine, endpoint from environment varaibles


    -------------------------- EXAMPLE 2 --------------------------

    PS > noc "Which city is the capital of China?"
    Use alias of the cmdlet with default api_key, engine, endpoint from environment varaibles


    -------------------------- EXAMPLE 3 --------------------------

    PS > "Which city is the capital of China?" | noc
    Use pipeline input

    -------------------------- EXAMPLE 4 --------------------------

    PS > noc "Which city is the capital of China?" -api_key "your api key"
    Set api_key in the command

    -------------------------- EXAMPLE 5 --------------------------

    PS > noc "Which city is the capital of China?" -api_key "your api key" -engine "davinci"
    Set api_key and engine in the command

    -------------------------- EXAMPLE 6 --------------------------

    PS > noc "Which city is the capital of China?" -azure
    Use Azure OpenAI API

    -------------------------- EXAMPLE 7 --------------------------

    PS > "string 1","string 2" | noc -azure
    Use Azure OpenAI API with pipeline input (multiple strings)

RELATED LINKS
    https://github.com/chenxizhang/openai-powershell

```

### New-ChatGPTConversation

```
SYNOPSIS
    Create a new ChatGPT conversation


SYNTAX
    New-ChatGPTConversation [[-api_key] <String>] [[-engine] <String>] [[-endpoint] <String>] [-azure] [[-system] <String>] [<CommonParameters>]


DESCRIPTION
    Create a new ChatGPT conversation, You can chat with the openai service just like chat with a human.


PARAMETERS
    -api_key <String>
        Your OpenAI API key, you can also set it in environment variable OPENAI_API_KEY or OPENAI_API_KEY_Azure if you use Azure OpenAI API.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -engine <String>
        The engine to use for this request, you can also set it in environment variable OPENAI_ENGINE or OPENAI_ENGINE_Azure if you use Azure OpenAI API.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -endpoint <String>
        The endpoint to use for this request, you can also set it in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_Azure if you use Azure OpenAI API.

        Required?                    false
        Position?                    3
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -azure [<SwitchParameter>]
        if you use Azure OpenAI API, you can use this switch.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -system <String>
        The system prompt, this is a string, you can use it to define the role you want it be, for example, "You are a chatbot, please answer the user's question according to the user's language."

        Required?                    false
        Position?                    4
        Default value                You are a chatbot, please answer the user's question according to the user's language.
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > New-ChatGPTConversation
    Create a new ChatGPT conversation, use openai service with all the default settings.


    -------------------------- EXAMPLE 2 --------------------------

    PS > New-ChatGPTConverstaion -azure
    Create a new ChatGPT conversation, use Azure openai service with all the default settings.


    -------------------------- EXAMPLE 3 --------------------------

    PS > chat -azure
    Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure openai service with all the default settings.


    -------------------------- EXAMPLE 4 --------------------------

    PS > New-ChatGPTConversation -api_key "your api key" -engine "your engine id"
    Create a new ChatGPT conversation, use openai service with your api key and engine id.

    -------------------------- EXAMPLE 5 --------------------------

    PS > New-ChatGPTConversation -api_key "your api key" -engine "your engine id" -azure
    Create a new ChatGPT conversation, use Azure openai service with your api key and engine id.

    -------------------------- EXAMPLE 6 --------------------------

    PS > New-ChatGPTConversation -api_key "your api key" -engine "your engine id" -azure -system "You are a chatbot, please answer the user's question according to the user's language."
    Create a new ChatGPT conversation, use Azure openai service with your api key and engine id, and define the system prompt.

    -------------------------- EXAMPLE 7 --------------------------

    PS > New-ChatGPTConversation -api_key "your api key" -engine "your engine id" -azure -system "You are a chatbot, please answer the user's question according to the user's language." -endpoint "https://api.openai.com/v1/completions"
    Create a new ChatGPT conversation, use Azure openai service with your api key and engine id, and define the system prompt and endpoint.

RELATED LINKS
    https://github.com/chenxizhang/openai-powershell

```

## Uninstall the Module

> UnInstall-Module -Name code365scripts.openai
