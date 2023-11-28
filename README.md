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

Currently, we support three cmdlets, `New-OpenAICompletion` (alias: `noc`) and `New-ChatGPTConversation` (alias: `chat` or `chatgpt` ), `New-ImageGeneration` (alias: `image` or `dall`),  you can find the full help by using `Get-Help noc -Full` in your terminal.


### New-OpenAICompletion

<code>
SYNOPSIS
    Get completion from OpenAI API


SYNTAX
    New-OpenAICompletion [-prompt <String>] [-api_key <String>] [-engine <String>] [-endpoint <String>] [-max_tokens <Int32>] [-temperature <Double>] [-n <Int32>] [<CommonParameters>]

    New-OpenAICompletion [-prompt <String>] [-api_key <String>] [-engine <String>] [-endpoint <String>] [-max_tokens <Int32>] [-temperature <Double>] [-n <Int32>] [-azure] [-environment <String>] [-api_version
    <String>] [<CommonParameters>]


DESCRIPTION
    Get completion from OpenAI API, you can use this cmdlet to get completion from OpenAI API.The cmdlet accept pipeline input. You can also assign the prompt, api_key, engine, endpoint, max_tokens, temperature, n       
    parameters.


PARAMETERS
    -prompt <String>
        The prompt to get completion from OpenAI API

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false

    -api_key <String>
        The api_key to get completion from OpenAI API. You can also set api_key in environment variable OPENAI_API_KEY or OPENAI_API_KEY_AZURE (if you want to use Azure OpenAI Service API).

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -engine <String>
        The engine to get completion from OpenAI API. You can also set engine in environment variable OPENAI_ENGINE or OPENAI_ENGINE_AZURE (if you want to use Azure OpenAI Service API). The default value is
        text-davinci-003, but now we recommend you to use gpt-3.5-turbo-instruct.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -endpoint <String>
        The endpoint to get completion from OpenAI API. You can also set endpoint in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_AZURE (if you want to use Azure OpenAI Service API).

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

    -environment <String>
        If you want to use Azure OpenAI API, you can use this parameter to set the environment. We will read environment variable OPENAI_API_KEY_AZURE_$environment, OPENAI_ENGINE_AZURE_$environment,
        OPENAI_ENDPOINT_AZURE_$environment. if you don't set this parameter (or the environment doesn't exist), we will read environment variable OPENAI_API_KEY_AZURE, OPENAI_ENGINE_AZURE, OPENAI_ENDPOINT_AZURE.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -api_version <String>
        If you want to use Azure OpenAI API, you can use this parameter to set the api_version. The default value is 2023-09-01-preview.

        Required?                    false
        Position?                    named
        Default value                2023-09-01-preview
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
    System.String, the completion result.


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






    -------------------------- EXAMPLE 8 --------------------------

    PS > noc "Which city is the capital of China?" -azure -environment "dev"
    Use Azure OpenAI API with environment variable OPENAI_API_KEY_AZURE_dev, OPENAI_ENGINE_AZURE_dev, OPENAI_ENDPOINT_AZURE_dev






    -------------------------- EXAMPLE 9 --------------------------

    PS > noc "Which city is the capital of China?" -azure -environment "dev" -api_version "2023-09-01-preview"
    Use Azure OpenAI API with environment variable OPENAI_API_KEY_AZURE_dev, OPENAI_ENGINE_AZURE_dev, OPENAI_ENDPOINT_AZURE_dev and api_version 2023-09-01-preview




RELATED LINKS
    https://github.com/chenxizhang/openai-powershell

</code>

### New-ChatGPTConversation

```

NAME
    New-ChatGPTConversation
    
SYNOPSIS
    Create a new ChatGPT conversation or get a Chat Completion result.(if you specify the prompt parameter)
    
    
SYNTAX
    New-ChatGPTConversation [-api_key <String>] [-engine <String>] [-endpoint <String>] [-system <String>] [-prompt <String>] [-stream] [-config <PSObject>] [<CommonParameters>]
    
    New-ChatGPTConversation [-api_key <String>] [-engine <String>] [-endpoint <String>] [-azure] [-system <String>] [-prompt <String>] [-stream] [-config <PSObject>] [-environment <String>] [-api_version <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Create a new ChatGPT conversation, You can chat with the openai service just like chat with a human. You can also get the chat completion result if you specify the prompt parameter.
    

PARAMETERS
    -api_key <String>
        Your OpenAI API key, you can also set it in environment variable OPENAI_API_KEY or OPENAI_API_KEY_AZURE if you use Azure OpenAI API. If you use multiple environments, you can use OPENAI_API_KEY_AZURE_$environment to define the api key for each environment.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -engine <String>
        The engine to use for this request, you can also set it in environment variable OPENAI_CHAT_ENGINE or OPENAI_CHAT_ENGINE_AZURE if you use Azure OpenAI API. If you use multiple environments, you can use OPENAI_CHAT_ENGINE_AZURE_$environment to define the engine for each environment.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -endpoint <String>
        The endpoint to use for this request, you can also set it in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_AZURE if you use Azure OpenAI API. If you use multiple environments, you can use OPENAI_ENDPOINT_AZURE_$environment to define the endpoint for each environment.
        
        Required?                    false
        Position?                    named
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
        Position?                    named
        Default value                You are a chatbot, please answer the user's question according to the user's language.
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -prompt <String>
        If you want to get result immediately, you can use this parameter to define the prompt. It will not start the chat conversation.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -stream [<SwitchParameter>]
        If you want to stream the response, you can use this switch. Please note, we only support this feature in new Powershell (6.0+).
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -config <PSObject>
        The dynamic settings for the API call, it can meet all the requirement for each model. please pass a custom object to this parameter, like @{temperature=1;max_tokens=1024}
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -environment <String>
        The environment name, if you use Azure OpenAI API, you can use this parameter to define the environment name, it will be used to get the api key, engine and endpoint from environment variable. If the environment is not exist, it will use the default environment.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -api_version <String>
        The api version, if you use Azure OpenAI API, you can use this parameter to define the api version, the default value is 2023-09-01-preview.
        
        Required?                    false
        Position?                    named
        Default value                2023-09-01-preview
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.String, the completion result. If you use stream mode, it will not return anything.
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > New-ChatGPTConversation
    Create a new ChatGPT conversation, use openai service with all the default settings.
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > New-ChatGPTConverstaion -azure
    Create a new ChatGPT conversation, use Azure openai service with all the default settings.
    
    
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS > New-ChatGPTConverstaion -azure -stream
    Create a new ChatGPT conversation, use Azure openai service and stream the response, with all the default settings.
    
    
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS > chat -azure
    Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure openai service with all the default settings.
    
    
    
    
    
    
    -------------------------- EXAMPLE 5 --------------------------
    
    PS > New-ChatGPTConversation -api_key "your api key" -engine "your engine id"
    Create a new ChatGPT conversation, use openai service with your api key and engine id.
    
    
    
    
    
    
    -------------------------- EXAMPLE 6 --------------------------
    
    PS > New-ChatGPTConversation -api_key "your api key" -engine "your engine id" -azure
    Create a new ChatGPT conversation, use Azure openai service with your api key and engine id.
    
    
    
    
    
    
    -------------------------- EXAMPLE 7 --------------------------
    
    PS > New-ChatGPTConversation -api_key "your api key" -engine "your engine id" -azure -system "You are a chatbot, please answer the user's question according to the user's language."
    Create a new ChatGPT conversation, use Azure openai service with your api key and engine id, and define the system prompt.
    
    
    
    
    
    
    -------------------------- EXAMPLE 8 --------------------------
    
    PS > New-ChatGPTConversation -api_key "your api key" -engine "your engine id" -azure -system "You are a chatbot, please answer the user's question according to the user's language." -endpoint "https://api.openai.com/v1/completions"
    Create a new ChatGPT conversation, use Azure openai service with your api key and engine id, and define the system prompt and endpoint.
    
    
    
    
    
    
    -------------------------- EXAMPLE 9 --------------------------
    
    PS > chat -azure -system "You are a chatbot, please answer the user's question according to the user's language." -environment "sweden"
    Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure openai service with the api key, engine and endpoint defined in environment variable OPENAI_API_KEY_AZURE_SWEDEN, OPENAI_CHAT_ENGINE_AZURE_SWEDEN and OPENAI_ENDPOINT_AZURE_SWEDEN.
    
    
    
    
    
    
    -------------------------- EXAMPLE 10 --------------------------
    
    PS > chat -azure -api_version "2021-09-01-preview"
    Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure openai service with the api version 2021-09-01-preview.
    
    
    
    
    
    
    
RELATED LINKS
    https://github.com/chenxizhang/openai-powershell




```

### New-ImageGeneration

```

NAME
    New-ImageGeneration
    
SYNOPSIS
    Generate image from prompt
    
    
SYNTAX
    New-ImageGeneration [-prompt <String>] [-api_key <String>] [-endpoint <String>] [-n <Int32>] [-size <Int32>] [-outfolder <String>] [-dall3] [<CommonParameters>]
    
    New-ImageGeneration [-prompt <String>] [-api_key <String>] [-endpoint <String>] [-azure] [-n <Int32>] [-size <Int32>] [-outfolder <String>] [-environment <String>] [-dall3] [<CommonParameters>]
    
    
DESCRIPTION
    Generate image from prompt, use dall-e-2 model by default, dall-e-3 model can be used by specify -dall3 switch
    

PARAMETERS
    -prompt <String>
        The prompt to generate image, this is required.
        
        Required?                    true
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -api_key <String>
        The api key to access openai api, if not specified, the api key will be read from environment variable OPENAI_API_KEY. if you use azure openai service, you can specify the api key by environment variable OPENAI_API_KEY_AZURE or OPENAI_API_KEY_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_API_KEY_AZURE_PROD, OPENAI_API_KEY_AZURE_TEST, etc.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -endpoint <String>
        The endpoint to access openai api, if not specified, the endpoint will be read from environment variable OPENAI_ENDPOINT. if you use azure openai service, you can specify the endpoint by environment variable OPENAI_ENDPOINT_AZURE or OPENAI_ENDPOINT_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_ENDPOINT_AZURE_DEV, OPENAI_ENDPOINT_AZURE_PROD, OPENAI_ENDPOINT_AZURE_TEST, etc.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -azure [<SwitchParameter>]
        Use azure openai service, if specified, the api key and endpoint will be read from environment variable OPENAI_API_KEY_AZURE or OPENAI_API_KEY_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_API_KEY_AZURE_PROD, OPENAI_API_KEY_AZURE_TEST, etc. and OPENAI_ENDPOINT_AZURE or OPENAI_ENDPOINT_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_ENDPOINT_AZURE_DEV, OPENAI_ENDPOINT_AZURE_PROD, OPENAI_ENDPOINT_AZURE_TEST, etc.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -n <Int32>
        The number of images to generate, default is 1. For dall-e-3 model, the n can only be 1. For dall-e-2 model, the n can be 1-10(openai), 1-5(azure).
        
        Required?                    false
        Position?                    named
        Default value                1
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -size <Int32>
        The size of the image to generate, default is 2, which means 1024x1024. For dall-e-3 model, the size can only be 2-4, which means 1024x1024, 1792x1024, 1024x1792. For dall-e-2 model, the size can be 0-2 for 256x256, 512x512, 1024x1024.
        
        Required?                    false
        Position?                    named
        Default value                2
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -outfolder <String>
        The folder to save the generated image, default is current folder.
        
        Required?                    false
        Position?                    named
        Default value                .
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -environment <String>
        The environment name, if you use azure openai service, you can specify the environment by this parameter, the environment name can be any names you want, for example, dev, prod, test, etc, the environment name will be used to read the api key and endpoint from environment variable, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_ENDPOINT_AZURE_DEV, etc.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -dall3 [<SwitchParameter>]
        Use dall-e-3 model if specified, otherwise, use dall-e-2 model. dall-e-3 model can only generate 1024x1024, 1792x1024, 1024x1792 image, dall-e-2 model can generate 256x256, 512x512, 1024x1024 image.
        
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
    
OUTPUTS
    System.String[], the file(s) path of the generated image.
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -n 1 -size 2 -outfolder "c:\temp"
    Use dall-e-2 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder.
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -n 1 -size 2 -outfolder "c:\temp" -api_key "your api key" -endpoint "your endpoint"
    Use dall-e-2 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use your own api key and endpoint.
    
    
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS > image -n 3 -prompt "A painting of a cat sitting on a chair"
    Use dall-e-2 model to generate image, the image size is 1024x1024, the generated image will be saved to current folder, generate 3 images.
    
    
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS > New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -n 1 -size 2 -outfolder "c:\temp" -azure
    Use dall-e-2 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use azure openai service.
    
    
    
    
    
    
    -------------------------- EXAMPLE 5 --------------------------
    
    PS > New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -n 1 -size 2 -outfolder "c:\temp" -azure -environment "dev"
    Use dall-e-2 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use azure openai service, read api key and endpoint from environment variable OPENAI_API_KEY_AZURE_DEV and OPENAI_ENDPOINT_AZURE_DEV.
    
    
    
    
    
    
    -------------------------- EXAMPLE 6 --------------------------
    
    PS > New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -n 1 -size 2 -outfolder "c:\temp" -azure -environment "dev" -dall3
    Use dall-e-3 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use azure openai service, read api key and endpoint from environment variable OPENAI_API_KEY_AZURE_DEV and OPENAI_ENDPOINT_AZURE_DEV.
    
    
    
    
    
    
    
RELATED LINKS
    https://github.com/chenxizhang/openai-powershell



```


## Uninstall the Module

> UnInstall-Module -Name code365scripts.openai

## Change logs
- 2023-11-26    v1.1.1.4    PowerShell 5.x supports.
- 2023-11-26    v1.1.1.3    Multiple environment and DALL-E 3 support, and fix a lot of bugs.
- 2023-10-23    v1.1.1.2    Fix a bug (ConvertTo-Json truncate the result)
- 2023-09-25    v1.1.1.1    Fix a bug (New-ImageGeneration, or image alias)
- 2023-09-24    v1.1.1.0    Add image generation support (New-ImageGeneration, or image alias)
- 2023-09-23    v1.1.0.9    Add dynamic configuration support for New-ChatGPTConversation,see -config parameter
- 2023-09-17    v1.1.0.8    Add verbose support
- 2023-09-10    v1.1.0.7    Fix the help doc for New-ChatGPTConversation
- 2023-09-06    v1.1.0.6    Bug fix
- 2023-09-06    v1.1.0.5    Added chat completion support.
- 2023-08-12    v1.1.0.4    Added stream support for chat
- 2021-05-13    v1.1.0.3    Small enhancements (save result to clipboard, print the system prompt, etc.)
- 2021-05-13    v1.1.0.0    Simplify the module structure
- 2023-05-07    v1.0.4.12   Fixed the network connectivity test logic
- 2023-05-07    v1.0.4.11   Added azure OpenAI supporrt for New-ChatGPTConversation function
- 2023-05-07    v1.0.4.10   Added network connectivity test logic
- 2023-03-09    v1.0.4.9    Added change logs in the description.
- 2023-03-08    v1.0.4.8    Added error handling.