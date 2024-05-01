---
external help file: code365scripts.openai-help.xml
Module Name: code365scripts.openai
online version: https://github.com/chenxizhang/openai-powershell
schema: 2.0.0
---

# New-ChatGPTConversation

## SYNOPSIS
创建一个新的 ChatGPT 对话或获取一个对话补全结果（如果您指定了 prompt 参数）。

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
创建一个新的 ChatGPT 对话，您可以像与人类聊天一样与 OpenAI 服务进行对话。
如果您指定了 prompt 参数，您还可以获取对话补全结果。

## EXAMPLES

### EXAMPLE 1
```
New-ChatGPTConversation
```

使用所有默认设置，创建一个新的 ChatGPT 对话，使用 OpenAI 服务。

### EXAMPLE 2
```
New-ChatGPTConverstaion -azure
```

使用所有默认设置，创建一个新的 ChatGPT 对话，使用 Azure OpenAI 服务。

### EXAMPLE 3
```
chat -azure
```

使用 cmdlet 的别名（chat），使用所有默认设置，创建一个新的 ChatGPT 对话，使用 Azure OpenAI 服务。

### EXAMPLE 4
```
New-ChatGPTConversation -api_key "你的 API 密钥" -model "你的模型名称"
```

使用您的 API 密钥和模型名称，创建一个新的 ChatGPT 对话，使用 OpenAI 服务。

### EXAMPLE 5
```
New-ChatGPTConversation -api_key "你的 API 密钥" -model "你的部署名称" -azure
```

使用您的 API 密钥和部署名称，创建一个新的 ChatGPT 对话，使用 Azure OpenAI 服务。

### EXAMPLE 6
```
New-ChatGPTConversation -api_key "你的 API 密钥" -model "你的部署名称" -azure -system "你是一个聊天机器人，请根据用户的语言回答用户的问题。"
```

使用您的 API 密钥和部署名称，创建一个新的 ChatGPT 对话，使用 Azure OpenAI 服务，并定义系统提示。

### EXAMPLE 7
```
New-ChatGPTConversation -api_key "你的 API 密钥" -model "你的部署名称" -azure -system "你是一个聊天机器人，请根据用户的语言回答用户的问题。" -endpoint "https://api.openai.com/v1/completions"
```

使用您的 API 密钥和模型 ID，创建一个新的 ChatGPT 对话，使用 Azure OpenAI 服务，并定义系统提示和端点。

### EXAMPLE 8
```
chat -azure -system "你是一个聊天机器人，请根据用户的语言回答用户的问题。" -env "sweden"
```

使用 cmdlet 的别名（chat），使用 Azure OpenAI 服务，以及在环境变量 OPENAI_API_KEY_AZURE_SWEDEN、OPENAI_CHAT_DEPLOYMENT_AZURE_SWEDEN 和 OPENAI_ENDPOINT_AZURE_SWEDEN 中定义的 API 密钥、模型和端点，创建一个新的 ChatGPT 对话。

### EXAMPLE 9
```
chat -azure -api_version "2021-09-01-preview"
```

使用 cmdlet 的别名（chat），使用 API 版本 2021-09-01-preview，创建一个新的 ChatGPT 对话，使用 Azure OpenAI 服务。

### EXAMPLE 10
```
gpt -azure -prompt "为什么人们会微笑"
```

使用 cmdlet 的别名（gpt），使用 Azure OpenAI 服务和提示，创建一个新的 ChatGPT 对话。

### EXAMPLE 11
```
"为什么人们会微笑" | gpt -azure
```

使用 cmdlet 的别名（gpt），使用 Azure OpenAI 服务和来自管道的提示，创建一个新的 ChatGPT 对话。

### EXAMPLE 12
```
gpt -azure -prompt "c:\temp\prompt.txt"
```

使用 cmdlet 的别名（gpt），使用 Azure OpenAI 服务和来自文件的提示，创建一个新的 ChatGPT 对话。

### EXAMPLE 13
```
gpt -azure -prompt "c:\temp\prompt.txt" -context @{variable1="value1";variable2="value2"}
```

使用 cmdlet 的别名（gpt），使用 Azure OpenAI 服务和来自文件的提示，并将一些数据传递给提示，创建一个新的 ChatGPT 对话。

### EXAMPLE 14
```
gpt -azure -system "c:\temp\system.txt" -prompt "c:\temp\prompt.txt"
```

使用 cmdlet 的别名（gpt），使用 Azure OpenAI 服务和系统提示及来自文件的提示，创建一个新的 ChatGPT 对话。

### EXAMPLE 15
```
gpt -azure -system "c:\temp\system.txt" -prompt "c:\temp\prompt.txt" -outFile "c:\temp\result.txt"
```

使用 cmdlet 的别名（gpt），使用 Azure OpenAI 服务和系统提示及来自文件的提示，然后将结果保存到文件，创建一个新的 ChatGPT 对话。

### EXAMPLE 16
```
gpt -azure -system "c:\temp\system.txt" -prompt "c:\temp\prompt.txt" -config @{temperature=1;max_tokens=1024}
```

使用 cmdlet 的别名（gpt），使用 Azure OpenAI 服务和系统提示及来自文件的提示以及您的自定义设置，创建一个新的 ChatGPT 对话。

### EXAMPLE 17
```
chat -local -model "llama3"
```

使用本地大型语言模型（例如，由 ollama 托管的模型 llama3）创建一个新的 ChatGPT 对话。
默认端点是 http://localhost:11434/v1/chat/completions。
您也可以修改此端点。

## PARAMETERS

### -local
如果您想使用本地大型语言模型，如由 ollama 托管的模型，可以使用此开关。
您也可以使用 "ollama" 作为此参数的别名。

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
如果您使用 Azure OpenAI 服务，可以使用此开关。

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
用于访问 OpenAI 服务的 API 密钥，如果没有指定，API 密钥将从环境变量 OPENAI_API_KEY 中读取。
如果您使用 azure OpenAI 服务，您可以通过环境变量 OPENAI_API_KEY_AZURE 或 OPENAI_API_KEY_AZURE_\<environment\> 指定 API 密钥，其中 \<environment\> 可以是您想要的任何名称，例如，OPENAI_API_KEY_AZURE_DEV、OPENAI_API_KEY_AZURE_PROD、OPENAI_API_KEY_AZURE_TEST 等。

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
此请求要使用的模型，您也可以在环境变量 OPENAI_CHAT_MODEL 或 OPENAI_CHAT_DEPLOYMENT_AZURE 中设置它，如果您使用 Azure OpenAI 服务。
如果您使用多个环境，可以使用 OPENAI_CHAT_DEPLOYMENT_AZURE_\<environment\> 为每个环境定义模型。
您可以使用 engine 或 deployment 作为此参数的别名。

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
此请求要使用的端点，您也可以在环境变量 OPENAI_ENDPOINT 或 OPENAI_ENDPOINT_AZURE 中设置它，如果您使用 Azure OpenAI 服务。
如果您使用多个环境，可以使用 OPENAI_ENDPOINT_AZURE_\<environment\> 为每个环境定义端点。

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
系统提示，这是一个字符串，您可以使用它来定义您想要的角色，例如，“你是一个聊天机器人，请根据用户的语言回答用户的问题。”
如果您为这个参数提供了一个文件路径，我们将把该文件作为系统提示读取。
您也可以指定一个 URL 给这个参数，我们将把该 URL 作为系统提示读取。
您可以通过使用 "lib:xxxxx" 作为提示，从库（https://github.com/code365opensource/promptlibrary）中读取提示，例如，"lib:fitness"。

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
如果您想立即获取结果，可以使用这个参数来定义提示。
它不会启动聊天对话。
如果您为这个参数提供了一个文件路径，我们将把该文件作为提示读取。
您也可以指定一个 URL 给这个参数，我们将把该 URL 作为提示读取。
您可以通过使用 "lib:xxxxx" 作为提示，从库（https://github.com/code365opensource/promptlibrary）中读取提示，例如，"lib:fitness"。

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
API 调用的动态设置，它可以满足每个模型的所有要求。
请将一个自定义对象传递给此参数，如 @{temperature=1;max_tokens=1024}。

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
环境名称，如果您使用 Azure OpenAI 服务，可以使用此参数来定义环境名称，它将用于从环境变量中获取 API 密钥、模型和端点。
如果环境不存在，它将使用默认环境。
您可以使用 env 作为此参数的别名。

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
API 版本，如果您使用 Azure OpenAI 服务，可以使用此参数来定义 API 版本，默认值是 2023-09-01-preview。

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
如果您想将结果保存到文件中，可以使用此参数来设置文件路径。
您也可以使用 "out" 作为此参数的别名。

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
如果您想将一些动态值传递给提示，您可以在这里使用 context 参数。
它可以是任何东西，您只需在这里指定一个自定义的 PowerShell 对象。
您在系统提示或用户提示中使用 {{you_variable_name}} 语法定义变量，然后将数据传递给 context 参数，如 @{you_variable_name="your value"}。
如果有多个变量，可以使用 @{variable1="value1";variable2="value2"}。

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
此 cmdlet 支持常见参数：-Debug、-ErrorAction、-ErrorVariable、-InformationAction、-InformationVariable、-OutVariable、-OutBuffer、-PipelineVariable、-Verbose、-WarningAction 和 -WarningVariable。有关更多信息，请参见 [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216)。

## INPUTS

## OUTPUTS

### System.String, 补全结果。
## NOTES

## RELATED LINKS

[https://github.com/chenxizhang/openai-powershell](https://github.com/chenxizhang/openai-powershell)
