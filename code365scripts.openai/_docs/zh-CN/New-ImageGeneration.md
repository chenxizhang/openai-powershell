---
external help file: code365scripts.openai-help.xml
Module Name: code365scripts.openai
online version: https://github.com/chenxizhang/openai-powershell
schema: 2.0.0
---

# New-ImageGeneration

## SYNOPSIS
Generate image from prompt, using DALL-e-3 model.

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
Generate image from prompt, using DALL-e-3 model.
The image size can be 1024x1024, 1792x1024, 1024x1792.

## EXAMPLES

### EXAMPLE 1
```
New-ImageGeneration -prompt "A painting of a cat sitting on a chair"
```

Use dall-e-3 model to generate image, the image size is 1024x1024, the generated image will be saved to current folder.

### EXAMPLE 2
```
image -prompt "A painting of a cat sitting on a chair"
```

Use the alias (image) to generate image, the image size is 1024x1024, the generated image will be saved to current folder.

### EXAMPLE 3
```
"A painting of a cat sitting on a chair" | New-ImageGeneration
```

Pass the prompt from pipeline, the image size is 1024x1024, the generated image will be saved to current folder.

### EXAMPLE 4
```
New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -size medium -outfolder "c:\temp" -api_key "your API key" -endpoint "your endpoint"
```

Use dall-e-3 model to generate image, the image size is 1792x1024, the generated image will be saved to c:\temp folder, use your own API key and endpoint.

### EXAMPLE 5
```
New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -size small -outfolder "c:\temp" -azure
```

Use dall-e-3 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use Azure OpenAI service.

### EXAMPLE 6
```
New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -size small -outfolder "c:\temp" -azure -environment "dev"
```

Use dall-e-3 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use Azure OpenAI service, read API key and endpoint from environment variable OPENAI_API_KEY_AZURE_DEV and OPENAI_ENDPOINT_AZURE_DEV.

### EXAMPLE 7
```
New-ImageGeneration -outfolder "c:\temp" -azure -prompt "c:\temp\prompt.txt"
```

Use dall-e-3 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use Azure OpenAI service, and use prompt from file c:\temp\prompt.txt

## PARAMETERS

### -prompt
The prompt to generate image, this is required, and it can pass from pipeline.
If you want to use a file as prompt, you can specify the file path here.
You can also specify a url as prompt, we will read the url as prompt.
You can read the prompt from a library (https://github.com/code365opensource/promptlibrary), by use "lib:xxxxx" as the prompt, for example, "lib:fitness".

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
The API key to access OpenAI service, if not specified, the API key will be read from environment variable OPENAI_API_KEY.
if you use Azure OpenAI service, you can specify the API key by environment variable OPENAI_API_KEY_AZURE or OPENAI_API_KEY_AZURE_\<environment\>, the \<environment\> can be any names you want, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_API_KEY_AZURE_PROD, OPENAI_API_KEY_AZURE_TEST, etc.

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
The endpoint to access OpenAI service, if not specified, the endpoint will be read from environment variable OPENAI_ENDPOINT.
if you use Azure OpenAI service, you can specify the endpoint by environment variable OPENAI_ENDPOINT_AZURE or OPENAI_ENDPOINT_AZURE_\<environment\>, the \<environment\> can be any names you want, for example, OPENAI_ENDPOINT_AZURE_DEV, OPENAI_ENDPOINT_AZURE_PROD, OPENAI_ENDPOINT_AZURE_TEST, etc.

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
Use Azure OpenAI service, if specified, the API key and endpoint will be read from environment variable OPENAI_API_KEY_AZURE or OPENAI_API_KEY_AZURE_\<environment\>, the \<environment\> can be any names you want, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_API_KEY_AZURE_PROD, OPENAI_API_KEY_AZURE_TEST, etc.
and OPENAI_ENDPOINT_AZURE or OPENAI_ENDPOINT_AZURE_\<environment\>.

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
The size of the image to generate, the value can be small (1024x1024), medium(1792x1024), large(1024x1792), the default is small.

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
The folder to save the generated image, default is current folder.
You can use out as the alias of this parameter.

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
The environment name, if you use Azure OpenAI service, you can specify the environment by this parameter, the environment name can be any names you want, for example, dev, prod, test, etc, the environment name will be used to read the API key and endpoint from environment variable, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_ENDPOINT_AZURE_DEV, etc.
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String, the file path of the generated image.
## NOTES

## RELATED LINKS

[https://github.com/chenxizhang/openai-powershell](https://github.com/chenxizhang/openai-powershell)

