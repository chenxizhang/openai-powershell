function New-ImageGeneration {
    <#
    .SYNOPSIS
        Generate image from prompt, using DALL-e-3 model.
    .DESCRIPTION
        Generate image from prompt, using DALL-e-3 model. The image size can be 1024x1024, 1792x1024, 1024x1792.
    .OUTPUTS
        System.String, the file path of the generated image.
    .PARAMETER prompt
        The prompt to generate image, this is required, and it can pass from pipeline.
        If you want to use a file as prompt, you can specify the file path here.
        You can also specify a url as prompt, we will read the url as prompt.
        You can read the prompt from a library (https://github.com/code365opensource/promptlibrary), by use "lib:xxxxx" as the prompt, for example, "lib:fitness".
    .PARAMETER api_key
        The API key to access OpenAI service, if not specified, the API key will be read from environment variable OPENAI_API_KEY. if you use Azure OpenAI service, you can specify the API key by environment variable OPENAI_API_KEY_AZURE or OPENAI_API_KEY_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_API_KEY_AZURE_PROD, OPENAI_API_KEY_AZURE_TEST, etc. 
    .PARAMETER endpoint
        The endpoint to access OpenAI service, if not specified, the endpoint will be read from environment variable OPENAI_ENDPOINT. if you use Azure OpenAI service, you can specify the endpoint by environment variable OPENAI_ENDPOINT_AZURE or OPENAI_ENDPOINT_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_ENDPOINT_AZURE_DEV, OPENAI_ENDPOINT_AZURE_PROD, OPENAI_ENDPOINT_AZURE_TEST, etc.
    .PARAMETER size
        The size of the image to generate, the value can be small (1024x1024), medium(1792x1024), large(1024x1792), the default is small.
    .PARAMETER outfolder
        The folder to save the generated image, default is current folder. You can use out as the alias of this parameter.
    .PARAMETER environment
        The environment name, if you use Azure OpenAI service, you can specify the environment by this parameter, the environment name can be any names you want, for example, dev, prod, test, etc, the environment name will be used to read the API key and endpoint from environment variable, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_ENDPOINT_AZURE_DEV, etc.
        You can use env as the alias of this parameter.
    .PARAMETER azure
        Use Azure OpenAI service, if specified, the API key and endpoint will be read from environment variable OPENAI_API_KEY_AZURE or OPENAI_API_KEY_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_API_KEY_AZURE_PROD, OPENAI_API_KEY_AZURE_TEST, etc. and OPENAI_ENDPOINT_AZURE or OPENAI_ENDPOINT_AZURE_<environment>.
    .EXAMPLE
        New-ImageGeneration -prompt "A painting of a cat sitting on a chair"
        Use dall-e-3 model to generate image, the image size is 1024x1024, the generated image will be saved to current folder.
    .EXAMPLE
        image -prompt "A painting of a cat sitting on a chair"
        Use the alias (image) to generate image, the image size is 1024x1024, the generated image will be saved to current folder.
    .EXAMPLE
        "A painting of a cat sitting on a chair" | New-ImageGeneration
        Pass the prompt from pipeline, the image size is 1024x1024, the generated image will be saved to current folder.
    .EXAMPLE
        New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -size medium -outfolder "c:\temp" -api_key "your API key" -endpoint "your endpoint"
        Use dall-e-3 model to generate image, the image size is 1792x1024, the generated image will be saved to c:\temp folder, use your own API key and endpoint.
    .EXAMPLE
        New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -size small -outfolder "c:\temp" -azure
        Use dall-e-3 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use Azure OpenAI service.
    .EXAMPLE
        New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -size small -outfolder "c:\temp" -azure -environment "dev"
        Use dall-e-3 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use Azure OpenAI service, read API key and endpoint from environment variable OPENAI_API_KEY_AZURE_DEV and OPENAI_ENDPOINT_AZURE_DEV.
    .EXAMPLE
        New-ImageGeneration -outfolder "c:\temp" -azure -prompt "c:\temp\prompt.txt"
        Use dall-e-3 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use Azure OpenAI service, and use prompt from file c:\temp\prompt.txt
    .LINK
        https://github.com/chenxizhang/openai-powershell
    #>
    [CmdletBinding(DefaultParameterSetName = "default")]
    [Alias("dall")][Alias("image")]
    param(
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)][string]$prompt,
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]
        [string]$api_key,
        [Parameter(ParameterSetName = "azure")]
        [string]$endpoint, 
        [Parameter(ParameterSetName = "azure", Mandatory = $true)]
        [switch]$azure,
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]
        [string]$size = "small",
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]
        [Alias("out")]
        [string]$outfolder = ".",
        [Alias("env")]
        [Parameter(ParameterSetName = "azure")]
        [string]$environment
    )

   
    BEGIN {
        Write-Verbose ($resources.verbose_parameters_received -f ($PSBoundParameters | Out-String))
        Write-Verbose ($resources.verbose_environment_received -f (Get-ChildItem Env:OPENAI_* | Out-String))

        if ($azure) {
            $api_key = if ($api_key) { $api_key } else { Get-FirstNonNullItemInArray("OPENAI_API_KEY_AZURE_$environment", "OPENAI_API_KEY_AZURE") }
            $endpoint = if ($endpoint) { $endpoint } else { "{0}openai/deployments/Dalle3/images/generations?api-version=2023-12-01-preview" -f (Get-FirstNonNullItemInArray("OPENAI_ENDPOINT_AZURE_$environment", "OPENAI_ENDPOINT_AZURE")) }
        }
        else {
            $api_key = if ($api_key) { $api_key } else { $env:OPENAI_API_KEY }
            $endpoint = "https://api.openai.com/v1/images/generations" 
        }

        Write-Verbose ($resources.verbose_parameters_parsed -f $api_key, $endpoint)

        $hasError = $false

        if ((!$azure) -and ((Test-OpenAIConnectivity) -eq $False)) {
            Write-Error $resources.openai_unavaliable
            $hasError = $true
        }


        if (!$api_key) {
            Write-Error $resources.error_missing_api_key
            $hasError = $true
        }

        if (!$endpoint) {
            Write-Error $resources.error_missing_endpoint
            $hasError = $true
        }


    }

    PROCESS {
        if ($hasError) {
            return
        }


        $telemetries = @{
            useAzure = $azure
        }

        # if the prompt is a file, read the content of the file
        $parsedprompt = Get-PromptContent $prompt
        $prompt = $parsedprompt.content
        $telemetries.Add("promptType", $parsedprompt.type)
        $telemetries.Add("promptLib", $parsedprompt.lib)

        # collect the telemetry data
        Submit-Telemetry -cmdletName $MyInvocation.MyCommand.Name -innovationName $MyInvocation.InvocationName -props $telemetries

        $size = switch ($size) {
            "large" { "1024x1792" }
            "medium" { "1792x1024" }
            "small" { "1024x1024" }
            default { "1024x1024" }
        }
        
        $body = @{
            prompt = $prompt
            size   = $size
            model  = "dall-e-3" 
        } | ConvertTo-Json -Depth 10


        $headers = @{
            "Content-Type" = "application/json;charset=utf-8"
        }

        if ($azure) {
            $headers.Add("api-key", $api_key)
        }
        else {
            $headers.Add("Authorization", "Bearer $api_key")
        }

        
        $request = Invoke-WebRequest -Method Post -Uri $endpoint -Headers $headers -Body $body
        Write-Verbose $request

        $url = ($request | ConvertFrom-Json).data[0].url
        $filename = [System.Guid]::NewGuid().ToString() + ".png"
        $file = [System.IO.Path]::Combine($outfolder, $filename)
        Invoke-WebRequest -Uri $url -OutFile $file
        Write-Verbose ($resources.verbose_image_download_completed -f $outfolder)
        Write-Output $file # return the file path
    }

    END {

    }
}