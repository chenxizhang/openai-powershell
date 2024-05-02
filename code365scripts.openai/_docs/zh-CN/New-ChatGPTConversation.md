---
external help file: code365scripts.openai-help.xml
Module Name: code365scripts.openai
online version: https://github.com/chenxizhang/openai-powershell
schema: 2.0.0
---

# New-ChatGPTConversation

## SYNOPSIS
创建一个新的 ChatGPT 对话，或者如果你直接指定了 prompt 参数，获取一个 Chat 完成的结果。

## SYNTAX

```
New-ChatGPTConversation [-api_key <String>] [-model <String>] [-endpoint <String>] [-system <String>]
 [[-prompt] <String>] [-config <PSObject>] [-outFile <String>] [-json] [-context <PSObject>]
 [-headers <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
创建一个新的 ChatGPT 对话，你可以像和人类聊天一样和 OpenAI 服务聊天。
如果你指定了 prompt 参数，你也可以获取聊天完成的结果。

## EXAMPLES

### EXAMPLE 1
```
New-ChatGPTConversation
```

使用 OpenAI 服务，并使用所有默认设置，将从环境变量（OPENAI_API_KEY）中读取 API 密钥，进入聊天模式。

### EXAMPLE 2
```
New-ChatGPTConversation -api_key "你的 api 密钥" -model "gpt-3.5-turbo"
```

使用指定的 api 密钥和模型的 OpenAI 服务，进入聊天模式。

### EXAMPLE 3
```
chat -system "你帮我翻译这段文字到中文。"
```

使用 OpenAI 服务翻译文本（指定了系统提示），将从环境变量（OPENAI_API_KEY）中读取 API 密钥，进入聊天模式。

### EXAMPLE 4
```
chat -endpoint "ollama" -model "llama3"
```

使用本地模型的 OpenAI 服务，进入聊天模式。

### EXAMPLE 5
```
chat -endpoint $endpoint $env:OPENAI_API_ENDPOINT_AZURE -model $env:OPENAI_API_MODEL_AZURE -api_key $env:OPENAI_API_KEY_AZURE
```

使用指定的 api 密钥和模型的 Azure OpenAI 服务，进入聊天模式。

### EXAMPLE 6
```
gpt -system "翻译这段文字到中文。" -prompt "Hello, how are you?"
```

使用 OpenAI 服务翻译文本（指定了系统提示），将从环境变量（OPENAI_API_KEY）中读取 API 密钥，模型从 OPENAI_API_MODEL（如果存在）或者使用 "gpt-3.5-turbo" 作为默认，直接获取聊天完成的结果。

### EXAMPLE 7
```
"Hello, how are you?" | gpt -system "翻译这段文字到中文。"
```

使用 OpenAI 服务翻译文本（指定了系统提示，用户提示将从管道传递），将从环境变量（OPENAI_API_KEY）中读取 API 密钥，模型从 OPENAI_API_MODEL（如果存在）或者使用 "gpt-3.5-turbo" 作为默认，直接获取聊天完成的结果。

## PARAMETERS

### -api_key
访问 OpenAI 服务的 API 密钥，如果没有指定，API 密钥将从环境变量 OPENAI_API_KEY 中读取。
你也可以使用 "token" 或 "access_token" 或 "accesstoken" 作为别名。

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
用于此请求的模型，你也可以在环境变量 OPENAI_API_MODEL 中设置它。
如果你使用的是 Azure OpenAI 服务，模型应该是你在门户中创建的部署名称。

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
用于此请求的端点，你也可以在环境变量 OPENAI_API_ENDPOINT 中设置它。
你也可以使用一些特殊值来指定端点，比如 "ollama", "local", "kimi", "zhipu"。

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
系统提示，这是一个字符串，你可以用它来定义你想要它扮演的角色，例如，"你是一个聊天机器人，请根据用户的语言回答用户的问题。"
如果你为这个参数提供了一个文件路径，我们将读取该文件作为系统提示。
你也可以指定一个 url 给这个参数，我们将读取该 url 作为系统提示。
你可以通过使用 "lib:xxxxx" 作为提示，从库（https://github.com/code365opensource/promptlibrary）中读取提示，例如，"lib:fitness"。

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 你是一个聊天机器人，请根据用户的语言回答用户的问题。
Accept pipeline input: False
Accept wildcard characters: False
```

### -prompt
如果你想立即获取结果，你可以使用这个参数来定义提示。
它不会启动聊天对话。
如果你为这个参数提供了一个文件路径，我们将读取该文件作为提示。
你也可以指定一个 url 给这个参数，我们将读取该 url 作为提示。
你可以通过使用 "lib:xxxxx" 作为提示，从库（https://github.com/code365opensource/promptlibrary）中读取提示，例如，"lib:fitness"。

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
请将一个自定义对象传递给这个参数，比如 @{temperature=1;max_tokens=1024}。

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
如果你想将结果保存到文件中，你可以使用这个参数来设置文件路径。
你也可以使用 "out" 作为别名。

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
如果你想将一些动态值传递给提示，你可以在这里使用 context 参数。
它可以是任何东西，你只需要在这里指定一个自定义的 powershell 对象。
你通过使用 {{you_variable_name}} 语法，在系统提示或用户提示中定义变量，然后将数据传递给 context 参数，比如 @{you_variable_name="你的值"}。
如果有多个变量，你可以使用 @{variable1="value1";variable2="value2"}。

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
如果你想将一些自定义头部传递给 API 调用，你可以使用这个参数。
你可以将一个自定义的哈希表传递给这个参数，比如 @{header1="value1";header2="value2"}。

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
此 cmdlet 支持常见参数：-Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, 和 -WarningVariable。更多信息，请查看 [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216)。

## INPUTS

## OUTPUTS

### System.String, 完成的结果。
## NOTES

## RELATED LINKS

[https://github.com/chenxizhang/openai-powershell](https://github.com/chenxizhang/openai-powershell)
