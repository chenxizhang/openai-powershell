---
external help file: code365scripts.openai-help.xml
Module Name: code365scripts.openai
online version: https://github.com/chenxizhang/openai-powershell
schema: 2.0.0
---

# New-ImageGeneration

## SYNOPSIS
使用 DALL-E-3 模型从提示生成图像。

## SYNTAX

### default (Default)
```
New-ImageGeneration [[-prompt] <String>] [-api_key <String>] [-size <String>] [-outfolder <String>]
 [<CommonParameters>]
```

### azure
```
New-ImageGeneration [[-prompt] <String>] [-api_key <String>] [-endpoint <String>] [-azure] [-size <String>]
 [-outfolder <String>] [-environment <String>] [<CommonParameters>]
```

## DESCRIPTION
使用 DALL-E-3 模型从提示生成图像。
图像大小可以是 1024x1024，1792x1024，1024x1792。

## EXAMPLES

### EXAMPLE 1
```
New-ImageGeneration -prompt "A painting of a cat sitting on a chair"
```

使用 dall-e-3 模型生成图像，图像大小为 1024x1024，生成的图像将保存到当前文件夹。

### EXAMPLE 2
```
image -prompt "A painting of a cat sitting on a chair"
```

使用别名（image）生成图像，图像大小为 1024x1024，生成的图像将保存到当前文件夹。

### EXAMPLE 3
```
"A painting of a cat sitting on a chair" | New-ImageGeneration
```

从管道传递提示，图像大小为 1024x1024，生成的图像将保存到当前文件夹。

### EXAMPLE 4
```
New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -size medium -outfolder "c:\temp" -api_key "your API key" -endpoint "your endpoint"
```

使用 dall-e-3 模型生成图像，图像大小为 1792x1024，生成的图像将保存到 c:\temp 文件夹，使用您自己的 API 密钥和端点。

### EXAMPLE 5
```
New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -size small -outfolder "c:\temp" -azure
```

使用 dall-e-3 模型生成图像，图像大小为 1024x1024，生成的图像将保存到 c:\temp 文件夹，使用 Azure OpenAI 服务。

### EXAMPLE 6
```
New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -size small -outfolder "c:\temp" -azure -environment "dev"
```

使用 dall-e-3 模型生成图像，图像大小为 1024x1024，生成的图像将保存到 c:\temp 文件夹，使用 Azure OpenAI 服务，从环境变量 OPENAI_API_KEY_AZURE_DEV 和 OPENAI_ENDPOINT_AZURE_DEV 中读取 API 密钥和端点。

### EXAMPLE 7
```
New-ImageGeneration -outfolder "c:\temp" -azure -prompt "c:\temp\prompt.txt"
```

使用 dall-e-3 模型生成图像，图像大小为 1024x1024，生成的图像将保存到 c:\temp 文件夹，使用 Azure OpenAI 服务，并使用文件 c:\temp\prompt.txt 中的提示

## PARAMETERS

### -prompt
生成图像的提示，这是必需的，并且可以从管道传递。
如果您想使用文件作为提示，可以在这里指定文件路径。
您也可以指定一个 URL 作为提示，我们将读取 URL 作为提示。
您可以通过使用 "lib:xxxxx" 作为提示，从库（https://github.com/code365opensource/promptlibrary）中读取提示，例如，"lib:fitness"。

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -api_key
访问 OpenAI 服务的 API 密钥，如果没有指定，API 密钥将从环境变量 OPENAI_API_KEY 中读取。
如果您使用 Azure OpenAI 服务，您可以通过环境变量 OPENAI_API_KEY_AZURE 或 OPENAI_API_KEY_AZURE_\<environment\> 指定 API 密钥，\<environment\> 可以是您想要的任何名称，例如，OPENAI_API_KEY_AZURE_DEV，OPENAI_API_KEY_AZURE_PROD，OPENAI_API_KEY_AZURE_TEST 等。

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

### -endpoint
访问 OpenAI 服务的端点，如果没有指定，端点将从环境变量 OPENAI_ENDPOINT 中读取。
如果您使用 Azure OpenAI 服务，您可以通过环境变量 OPENAI_ENDPOINT_AZURE 或 OPENAI_ENDPOINT_AZURE_\<environment\> 指定端点，\<environment\> 可以是您想要的任何名称，例如，OPENAI_ENDPOINT_AZURE_DEV，OPENAI_ENDPOINT_AZURE_PROD，OPENAI_ENDPOINT_AZURE_TEST 等。

```yaml
Type: String
Parameter Sets: azure
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -azure
使用 Azure OpenAI 服务，如果指定，API 密钥和端点将从环境变量 OPENAI_API_KEY_AZURE 或 OPENAI_API_KEY_AZURE_\<environment\> 中读取，\<environment\> 可以是您想要的任何名称，例如，OPENAI_API_KEY_AZURE_DEV，OPENAI_API_KEY_AZURE_PROD，OPENAI_API_KEY_AZURE_TEST 等。
和 OPENAI_ENDPOINT_AZURE 或 OPENAI_ENDPOINT_AZURE_\<environment\>。

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

### -size
要生成的图像的大小，值可以是 small (1024x1024)，medium(1792x1024)，large(1024x1792)，默认是 small。

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Small
Accept pipeline input: False
Accept wildcard characters: False
```

### -outfolder
保存生成的图像的文件夹，默认是当前文件夹。
您可以使用 out 作为此参数的别名。

```yaml
Type: String
Parameter Sets: (All)
Aliases: out

Required: False
Position: Named
Default value: .
Accept pipeline input: False
Accept wildcard characters: False
```

### -environment
环境名称，如果您使用 Azure OpenAI 服务，可以通过此参数指定环境，环境名称可以是您想要的任何名称，例如，dev，prod，test 等，环境名称将用于从环境变量中读取 API 密钥和端点，例如，OPENAI_API_KEY_AZURE_DEV，OPENAI_ENDPOINT_AZURE_DEV 等。
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

### CommonParameters
此 cmdlet 支持常见参数：-Debug，-ErrorAction，-ErrorVariable，-InformationAction，-InformationVariable，-OutVariable，-OutBuffer，-PipelineVariable，-Verbose，-WarningAction 和 -WarningVariable。有关更多信息，请参见 [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216)。

## INPUTS

## OUTPUTS

### System.String, 生成的图像的文件路径。
## NOTES

## RELATED LINKS

[https://github.com/chenxizhang/openai-powershell](https://github.com/chenxizhang/openai-powershell)
