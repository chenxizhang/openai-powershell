---
external help file: code365scripts.openai-help.xml
Module Name: code365scripts.openai
online version: https://github.com/chenxizhang/openai-powershell
schema: 2.0.0
---

# New-ChatGPTConversation

## SYNOPSIS
创建一个新的 ChatGPT 对话，或者如果您直接指定了 prompt 参数，则获取聊天完成结果。

## SYNTAX

```
New-ChatGPTConversation [-api_key <String>] [-model <String>] [-endpoint <String>] [-system <String>]
 [[-prompt] <String>] [-config <PSObject>] [-outFile <String>] [-json] [-context <PSObject>]
 [-headers <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
创建一个新的 ChatGPT 对话，您可以像与人聊天一样与 OpenAI 服务聊天。
如果您指定了 prompt 参数，您也可以获得聊天完成结果。

## EXAMPLES

### EXAMPLE 1
```
New-ChatGPTConversation
```

使用所有默认设置的 OpenAI Service，将从环境变量 (OPENAI_API_KEY) 读取 API 密钥，进入聊天模式。

### EXAMPLE 2
```
New-ChatGPTConversation -api_key "your api key" -model "gpt-3.5-turbo"
```

使用指定的 API 密钥和模型的 OpenAI Service，进入聊天模式。

### EXAMPLE 3
```
chat -system "You help me to translate the text to Chinese."
```

使用 OpenAI Service 翻译文本（指定系统提示），将从环境变量 (OPENAI_API_KEY) 读取 API 密钥，进入聊天模式。

### EXAMPLE 4
```
chat -endpoint "ollama" -model "llama3"
```

使用本地模型的 OpenAI Service，进入聊天模式。

### EXAMPLE 5
```
chat -endpoint $endpoint $env:OPENAI_API_ENDPOINT_AZURE -model $env:OPENAI_API_MODEL_AZURE -api_key $env:OPENAI_API_KEY_AZURE
```

使用指定的 API 密钥和模型的 Azure OpenAI Service，进入聊天模式。

### EXAMPLE 6
```
gpt -system "Translate the text to Chinese." -prompt "Hello, how are you?"
```

使用 OpenAI Service 翻译文本（指定系统提示），将从环境变量 (OPENAI_API_KEY) 读取 API 密钥，模型从 OPENAI_API_MODEL 读取（如果存在）或默认使用 "gpt-3.5-turbo"，直接获取聊天完成结果。

### EXAMPLE 7
```
"Hello, how are you?" | gpt -system "Translate the text to Chinese."
```

使用 OpenAI Service 翻译文本（指定系统提示，用户提示将通过管道传递），将从环境变量 (OPENAI_API_KEY) 读取 API 密钥，模型从 OPENAI_API_MODEL 读取（如果存在）或默认使用 "gpt-3.5-turbo"，直接获取聊天完成结果。

## PARAMETERS

### -api_key
用于访问 OpenAI Service 的 API 密钥，如果未指定，将从环境变量 OPENAI_API_KEY 中读取。
您也可以使用 "token"、"access_token" 或 "accesstoken" 作为别名。

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
用于此请求的模型，您也可以在环境变量 OPENAI_API_MODEL 中设置。
如果您使用的是 Azure OpenAI Service，则模型应是您在门户中创建的部署名称。

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
用于此请求的端点，您也可以在环境变量 OPENAI_API_ENDPOINT 中设置。
您还可以使用一些特殊值来指定端点，如 "ollama", "local", "kimi", "zhipu"。

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
系统提示，这是一个字符串，您可以使用它定义您希望它扮演的角色，例如，"You are a chatbot, please answer the user's question according to the user's language."
如果您提供一个文件路径到这个参数，我们将读取文件作为系统提示。
您也可以为此参数指定一个 URL，我们将读取 URL 作为系统提示。
您可以通过使用 "lib:xxxxx" 作为提示从库 (https://github.com/code365opensource/promptlibrary) 读取提示，例如，"lib:fitness"。

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
如果您希望立即获得结果，您可以使用此参数定义提示。
它不会启动聊天对话。
如果您提供一个文件路径到这个参数，我们将读取文件作为提示。
您也可以为此参数指定一个 URL，我们将读取 URL 作为提示。
您可以通过使用 "lib:xxxxx" 作为提示从库 (https://github.com/code365opensource/promptlibrary) 读取提示，例如，"lib:fitness"。

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
API 调用的动态设置，它可以满足每个模型的所有要求。
请传递一个自定义对象到这个参数，如 @{temperature=1;max_tokens=1024}。

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
如果您希望将结果保存到文件中，您可以使用此参数设置文件路径。
您也可以使用 "out" 作为别名。

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
以 json 格式发送响应。

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
如果您希望将一些动态值传递给提示，您可以在这里使用 context 参数。
它可以是任何东西，您只需在这里指定一个自定义的 PowerShell 对象。
您可以通过使用 {{you_variable_name}} 语法在系统提示或用户提示中定义变量，然后将数据传递给 context 参数，如 @{you_variable_name="your value"}。
如果有多个变量，您可以使用 @{variable1="value1";variable2="value2"}。

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
如果您希望将一些自定义头传递到 API 调用，您可以使用此参数。
您可以传递一个自定义的哈希表给这个参数，如 @{header1="value1";header2="value2"}。

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
此 cmdlet 支持通用参数：-Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, 和 -WarningVariable。有关更多信息，请参阅 [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216)。

## INPUTS

## OUTPUTS

### System.String, 完成的结果。
## NOTES

## RELATED LINKS

[https://github.com/chenxizhang/openai-powershell](https://github.com/chenxizhang/openai-powershell)


