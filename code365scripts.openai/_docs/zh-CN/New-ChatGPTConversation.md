---
external help file: code365scripts.openai-help.xml
Module Name: code365scripts.openai
online version: https://github.com/chenxizhang/openai-powershell
schema: 2.0.0
---

# New-ChatGPTConversation

## SYNOPSIS
Create a new ChatGPT conversation or get a Chat Completion result if you specify the prompt parameter directly.

## SYNTAX

```
New-ChatGPTConversation [-api_key <String>] [-model <String>] [-endpoint <String>] [-system <String>]
 [[-prompt] <String>] [-config <PSObject>] [-outFile <String>] [-json] [-context <PSObject>]
 [-headers <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Create a new ChatGPT conversation, You can chat with the OpenAI service just like chat with a human.
You can also get the chat completion result if you specify the prompt parameter.

## EXAMPLES

### EXAMPLE 1
```
New-ChatGPTConversation
```

Use OpenAI Service with all the default settings, will read the API key from environment variable (OPENAI_API_KEY), enter the chat mode.

### EXAMPLE 2
```
New-ChatGPTConversation -api_key "your api key" -model "gpt-3.5-turbo"
```

Use OpenAI Service with the specified api key and model, enter the chat mode.

### EXAMPLE 3
```
chat -system "You help me to translate the text to Chinese."
```

Use OpenAI Service to translate text (system prompt specified), will read the API key from environment variable (OPENAI_API_KEY), enter the chat mode.

### EXAMPLE 4
```
chat -endpoint "ollama" -model "llama3"
```

Use OpenAI Service with the local model, enter the chat mode.

### EXAMPLE 5
```
chat -endpoint $endpoint $env:OPENAI_API_ENDPOINT_AZURE -model $env:OPENAI_API_MODEL_AZURE -api_key $env:OPENAI_API_KEY_AZURE
```

Use Azure OpenAI Service with the specified api key and model, enter the chat mode.

### EXAMPLE 6
```
gpt -system "Translate the text to Chinese." -prompt "Hello, how are you?"
```

Use OpenAI Service to translate text (system prompt specified), will read the API key from environment variable (OPENAI_API_KEY), model from OPENAI_API_MODEL (if present) or use "gpt-3.5-turbo" as default, get the chat completion result directly.

### EXAMPLE 7
```
"Hello, how are you?" | gpt -system "Translate the text to Chinese."
```

Use OpenAI Service to translate text (system prompt specified, user prompt will pass from pipeline), will read the API key from environment variable (OPENAI_API_KEY), model from OPENAI_API_MODEL (if present) or use "gpt-3.5-turbo" as default, get the chat completion result directly.

## PARAMETERS

### -api_key
The API key to access OpenAI service, if not specified, the API key will be read from environment variable OPENAI_API_KEY.
You can also use "token" or "access_token" or "accesstoken" as the alias.

```yaml
Type: String
Parameter Sets: (All)
Aliases: token, access_token, accesstoken, key, apikey

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -model
The model to use for this request, you can also set it in environment variable OPENAI_API_MODEL.
If you are using Azure OpenAI Service, the model should be the deployment name you created in portal.

```yaml
Type: String
Parameter Sets: (All)
Aliases: engine, deployment

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -endpoint
The endpoint to use for this request, you can also set it in environment variable OPENAI_API_ENDPOINT.
You can also use some special value to specify the endpoint, like "ollama", "local", "kimi", "zhipu".

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
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -config
The dynamic settings for the API call, it can meet all the requirement for each model.
please pass a custom object to this parameter, like @{temperature=1;max_tokens=1024}.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: settings

Required: False
Position: Named
Default value: None
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
Aliases: variables

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -headers
If you want to pass some custom headers to the API call, you can use this parameter.
You can pass a custom hashtable to this parameter, like @{header1="value1";header2="value2"}.

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

