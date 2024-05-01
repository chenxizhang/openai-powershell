---
external help file: code365scripts.openai-help.xml
Module Name: code365scripts.openai
online version: https://github.com/chenxizhang/openai-powershell
schema: 2.0.0
---

# New-ChatGPTConversation

## SYNOPSIS
Create a new ChatGPT conversation or get a Chat Completion result.(if you specify the prompt parameter)

## SYNTAX

### default (Default)
```
New-ChatGPTConversation [-api_key <String>] [-model <String>] [-endpoint <String>] [-system <String>]
 [-prompt <String>] [-config <PSObject>] [-outFile <String>] [-json] [-context <PSObject>] [<CommonParameters>]
```

### local
```
New-ChatGPTConversation [-local] -model <String> [-endpoint <String>] [-system <String>] [-prompt <String>]
 [-config <PSObject>] [-outFile <String>] [-json] [-context <PSObject>] [<CommonParameters>]
```

### azure
```
New-ChatGPTConversation [-azure] [-api_key <String>] [-model <String>] [-endpoint <String>] [-system <String>]
 [-prompt <String>] [-config <PSObject>] [-environment <String>] [-api_version <String>] [-outFile <String>]
 [-json] [-context <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Create a new ChatGPT conversation, You can chat with the OpenAI service just like chat with a human.
You can also get the chat completion result if you specify the prompt parameter.

## EXAMPLES

### EXAMPLE 1
```
New-ChatGPTConversation
```

Create a new ChatGPT conversation, use OpenAI service with all the default settings.

### EXAMPLE 2
```
New-ChatGPTConverstaion -azure
```

Create a new ChatGPT conversation, use Azure OpenAI service with all the default settings.

### EXAMPLE 3
```
chat -azure
```

Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure OpenAI service with all the default settings.

### EXAMPLE 4
```
New-ChatGPTConversation -api_key "your API key" -model "your model name"
```

Create a new ChatGPT conversation, use OpenAI service with your API key and model name.

### EXAMPLE 5
```
New-ChatGPTConversation -api_key "your API key" -model "your deployment name" -azure
```

Create a new ChatGPT conversation, use Azure OpenAI service with your API key and deployment name.

### EXAMPLE 6
```
New-ChatGPTConversation -api_key "your API key" -model "your deployment name" -azure -system "You are a chatbot, please answer the user's question according to the user's language."
```

Create a new ChatGPT conversation, use Azure OpenAI service with your API key and deployment name, and define the system prompt.

### EXAMPLE 7
```
New-ChatGPTConversation -api_key "your API key" -model "your deployment name" -azure -system "You are a chatbot, please answer the user's question according to the user's language." -endpoint "https://api.openai.com/v1/completions"
```

Create a new ChatGPT conversation, use Azure OpenAI service with your API key and model id, and define the system prompt and endpoint.

### EXAMPLE 8
```
chat -azure -system "You are a chatbot, please answer the user's question according to the user's language." -env "sweden"
```

Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure OpenAI service with the API key, model and endpoint defined in environment variable OPENAI_API_KEY_AZURE_SWEDEN, OPENAI_CHAT_DEPLOYMENT_AZURE_SWEDEN and OPENAI_ENDPOINT_AZURE_SWEDEN.

### EXAMPLE 9
```
chat -azure -api_version "2021-09-01-preview"
```

Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure OpenAI service with the api version 2021-09-01-preview.

### EXAMPLE 10
```
gpt -azure -prompt "why people smile"
```

Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the prompt.

### EXAMPLE 11
```
"why people smile" | gpt -azure
```

Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the prompt from pipeline.

### EXAMPLE 12
```
gpt -azure -prompt "c:\temp\prompt.txt"
```

Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the prompt from file.

### EXAMPLE 13
```
gpt -azure -prompt "c:\temp\prompt.txt" -context @{variable1="value1";variable2="value2"}
```

Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the prompt from file, pass some data to the prompt.

### EXAMPLE 14
```
gpt -azure -system "c:\temp\system.txt" -prompt "c:\temp\prompt.txt"
```

Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the system prompt and prompt from file.

### EXAMPLE 15
```
gpt -azure -system "c:\temp\system.txt" -prompt "c:\temp\prompt.txt" -outFile "c:\temp\result.txt"
```

Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the system prompt and prompt from file, then save the result to a file.

### EXAMPLE 16
```
gpt -azure -system "c:\temp\system.txt" -prompt "c:\temp\prompt.txt" -config @{temperature=1;max_tokens=1024}
```

Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the system prompt and prompt from file and your customized settings.

### EXAMPLE 17
```
chat -local -model "llama3"
```

Create a new ChatGPT conversation by using local LLMs, for example, the llama3.
The default endpoint is http://localhost:11434/v1/chat/completions.
You can modify this endpoint as well.

## PARAMETERS

### -local
If you want to use the local LLMs, like the model hosted by ollama, you can use this switch.
You can also use "ollama" as the alias.

```yaml
Type: SwitchParameter
Parameter Sets: local
Aliases: ollama

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -azure
if you use Azure OpenAI service, you can use this switch.

```yaml
Type: SwitchParameter
Parameter Sets: azure
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -api_key
The API key to access OpenAI service, if not specified, the API key will be read from environment variable OPENAI_API_KEY.
if you use azure OpenAI service, you can specify the API key by environment variable OPENAI_API_KEY_AZURE or OPENAI_API_KEY_AZURE_\<environment\>, the \<environment\> can be any names you want, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_API_KEY_AZURE_PROD, OPENAI_API_KEY_AZURE_TEST, etc.

```yaml
Type: String
Parameter Sets: default, azure
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -model
The model to use for this request, you can also set it in environment variable OPENAI_CHAT_MODEL or OPENAI_CHAT_DEPLOYMENT_AZURE if you use Azure OpenAI service.
If you use multiple environments, you can use OPENAI_CHAT_DEPLOYMENT_AZURE_\<environment\> to define the model for each environment.
You can use engine or deployment as the alias of this parameter.

```yaml
Type: String
Parameter Sets: default, azure
Aliases: engine, deployment

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: local
Aliases: engine, deployment

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -endpoint
The endpoint to use for this request, you can also set it in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_AZURE if you use Azure OpenAI service.
If you use multiple environments, you can use OPENAI_ENDPOINT_AZURE_\<environment\> to define the endpoint for each environment.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -system
The system prompt, this is a string, you can use it to define the role you want it be, for example, "You are a chatbot, please answer the user's question according to the user's language."
If you provide a file path to this parameter, we will read the file as the system prompt.
You can also specify a url to this parameter, we will read the url as the system prompt.
You can read the prompt from a library (https://github.com/code365opensource/promptlibrary), by use "lib:xxxxx" as the prompt, for example, "lib:fitness".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: You are a chatbot, please answer the user's question according to the user's language.
Accept pipeline input: False
Accept wildcard characters: False
```

### -prompt
If you want to get result immediately, you can use this parameter to define the prompt.
It will not start the chat conversation.
If you provide a file path to this parameter, we will read the file as the prompt.
You can also specify a url to this parameter, we will read the url as the prompt.
You can read the prompt from a library (https://github.com/code365opensource/promptlibrary), by use "lib:xxxxx" as the prompt, for example, "lib:fitness".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -config
The dynamic settings for the API call, it can meet all the requirement for each model.
please pass a custom object to this parameter, like @{temperature=1;max_tokens=1024}.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -environment
The environment name, if you use Azure OpenAI service, you can use this parameter to define the environment name, it will be used to get the API key, model and endpoint from environment variable.
If the environment is not exist, it will use the default environment. 
You can use env as the alias of this parameter.

```yaml
Type: String
Parameter Sets: azure
Aliases: env

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -api_version
The api version, if you use Azure OpenAI service, you can use this parameter to define the api version, the default value is 2023-09-01-preview.

```yaml
Type: String
Parameter Sets: azure
Aliases:

Required: False
Position: Named
Default value: 2023-09-01-preview
Accept pipeline input: False
Accept wildcard characters: False
```

### -outFile
If you want to save the result to a file, you can use this parameter to set the file path.
You can also use "out" as the alias.

```yaml
Type: String
Parameter Sets: (All)
Aliases: out

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -json
Send the response in json format.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -context
If you want to pass some dymamic value to the prompt, you can use the context parameter here.
It can be anything, you just specify a custom powershell object here.
You define the variables in the system prompt or user prompt by using {{you_variable_name}} syntext, and then pass the data to the context parameter, like @{you_variable_name="your value"}.
if there are multiple variables, you can use @{variable1="value1";variable2="value2"}.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String, the completion result.
## NOTES

## RELATED LINKS

[https://github.com/chenxizhang/openai-powershell](https://github.com/chenxizhang/openai-powershell)

