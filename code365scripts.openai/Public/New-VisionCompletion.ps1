function New-VisionCompletion {

    <#
    .SYNOPSIS
        Generate text from a prompt and an image.
    .DESCRIPTION
        Generate text from a prompt and an image by using the newest GPT-4-Vision-preview model. You can use this cmdlet to get completion from OpenAI API.The cmdlet accept pipeline input. You can also assign the prompt, api_key, engine, endpoint, max_tokens, temperature. You can input multiple images, and we will use all the images to generate the text.
    .PARAMETER prompt
        The prompt to get completion from OpenAI API. If yuo provide a file path, we will read the file as prompt. You can also set prompt in pipeline input.
        You can also specify a url, we will read the url as prompt.
    .PARAMETER files
        The image files to get completion from OpenAI API. We support jpg, png, gif, and you can input multiple images, and you can even mix local file path and online url.
    .PARAMETER api_key
        The api_key to get completion from OpenAI API. You can also set api_key in environment variable OPENAI_API_KEY or OPENAI_API_KEY_AZURE (if you want to use Azure OpenAI Service API).
    .PARAMETER engine
        The engine (refer to the deployment name if you use Azure OpenAI service) to get completion from OpenAI API. You can also set engine in environment variable OPENAI_VISION_ENGINE or OPENAI_VISION_ENGINE_AZURE (if you want to use Azure OpenAI Service API). The default value is gpt-4-vision-preview. You can use model or deployment as the alias of engine.
    .PARAMETER endpoint
        The endpoint to get completion from OpenAI API. You can also set endpoint in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_AZURE (if you want to use Azure OpenAI Service API).
    .PARAMETER max_tokens
        The max_tokens to get completion from OpenAI API. The default value is 1024.
    .PARAMETER temperature
        The temperature to get completion from OpenAI API. The default value is 1, which means most creatively.
    .PARAMETER azure
        If you want to use Azure OpenAI API, you can use this switch.
    .PARAMETER environment
        If you want to use Azure OpenAI API, you can use this parameter to set the environment. We will read environment variable OPENAI_API_KEY_AZURE_$environment, OPENAI_VISION_ENGINE_AZURE_$environment, OPENAI_ENDPOINT_AZURE_$environment. if you don't set this parameter (or the environment doesn't exist), we will read environment variable OPENAI_API_KEY_AZURE, OPENAI_ENGINE_AZURE, OPENAI_ENDPOINT_AZURE.
        You can use env as the alias of environment.
    .PARAMETER api_version
        If you want to use Azure OpenAI API, you can use this parameter to set the api_version. The default value is 2023-07-01-preview.
    .PARAMETER outFile
        If you want to save the result to a file, you can use this parameter to set the file path.
    .EXAMPLE
        New-VisionCompletion -prompt "What's in below pictures?" -files "c:\temp\image1.jpg","c:\temp\image2.jpg"
        Use default api_key, engine, endpoint from environment varaibles
    .EXAMPLE
        vc "What's in below pictures?" -files "c:\temp\image1.jpg","c:\temp\image2.jpg"
        Use alias of the cmdlet with default api_key, engine, endpoint from environment varaibles
    .EXAMPLE
        "What's in below pictures?" | vc -files "c:\temp\image1.jpg","c:\temp\image2.jpg"
        Use pipeline input
    .EXAMPLE
        vc "What's in below pictures?" -files "c:\temp\image1.jpg","c:\temp\image2.jpg" -api_key "your api key"
        Set api_key in the command
    .EXAMPLE
        vc "What's in below pictures?" -files "c:\temp\image1.jpg","c:\temp\image2.jpg" -api_key "your api key" -azure
        Set api_key in the command and use Azure OpenAI API
    .EXAMPLE
        vc "What's in below pictures?" -files "c:\temp\image1.jpg","c:\temp\image2.jpg" -api_key "your api key" -azure -environment "dev"
        Set api_key in the command and use Azure OpenAI API with environment variable OPENAI_API_KEY_AZURE_dev, OPENAI_VISION_ENGINE_AZURE_dev, OPENAI_ENDPOINT_AZURE_dev
    .LINK
        https://github.com/chenxizhang/openai-powershell
    .INPUTS
        System.String, you can pass one or more string to the cmdlet, and we will get the completion for you.
    .OUTPUTS
        System.String, the completion from OpenAI API
    #>

    [CmdletBinding()]
    [Alias("vc")]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$prompt,
        [Parameter(Mandatory = $true)][string[]]$files,
        [string]$api_key,
        [Parameter()]
        [Alias("model", "deployment")]
        [string]$engine,
        [Parameter()][string]$endpoint,
        [Parameter()][int]$max_tokens = 1024,
        [Parameter()][double]$temperature = 1,
        [switch]$azure,
        [Alias("env")]
        [string]$environment,
        [string]$api_version = "2023-07-01-preview",
        [string]$outFile
    )


    BEGIN {

        Write-Verbose "Parameter received`n$($PSBoundParameters | Out-String)"
        Write-Verbose "Environment variable detected.`n$(Get-ChildItem Env:OPENAI_* | Out-String)"

        if ($azure) {
            $api_key = if ($api_key) { $api_key } else { Get-FirstNonNullItemInArray("OPENAI_API_KEY_AZURE_$environment", "OPENAI_API_KEY_AZURE") }
            $engine = if ($engine) { $engine } else { Get-FirstNonNullItemInArray("OPENAI_VISION_ENGINE_AZURE_$environment", "OPENAI_VISION_ENGINE_AZURE") }
            $endpoint = "{0}openai/deployments/{1}/chat/completions?api-version=$api_version" -f $(if ($endpoint) { $endpoint }else { Get-FirstNonNullItemInArray("OPENAI_ENDPOINT_AZURE_$environment", "OPENAI_ENDPOINT_AZURE") }), $engine
        }
        else {
            $api_key = if ($api_key) { $api_key } else { $env:OPENAI_API_KEY }
            $engine = if ($engine) { $engine } else { if ($env:OPENAI_VISION_ENGINE) { $env:OPENAI_VISION_ENGINE }else { "gpt-4-vision-preview" } }
            $endpoint = if ($endpoint) { $endpoint } else { if ($env:OPENAI_ENDPOINT) { $env:OPENAI_ENDPOINT }else { "https://api.openai.com/v1/chat/completions" } }
        }

        Write-Verbose "Parameter parsed, api_key: $api_key, engine: $engine, endpoint: $endpoint"

        $hasError = $false

        if ((!$azure) -and ((Test-OpenAIConnectivity) -eq $False)) {
            Write-Error $resources.openai_unavaliable
            $hasError = $true
        }


        if (!$api_key) {
            Write-Error $resources.error_missing_api_key
            $hasError = $true
        }

        if (!$engine) {
            Write-Error $resources.error_missing_engine
            $hasError = $true
        }

        if (!$endpoint) {
            Write-Error $resources.error_missing_endpoint
            $hasError = $true
        }

        # ensure all the files are valid image(jpg,png,gif)
        $files | ForEach-Object {
            # if the file not startwith http/https and endwith jpg/png/gif, then we will treat it as a local file path and check if the file exists
            if ((Get-IsValidImage -path $_) -eq $false) {
                Write-Error "File $_ is not a url and not a valid local image(jpg,png,gif)."
                Set-Variable -Name "hasError" -Value $true
            }
        }
    }

    PROCESS {

        if ($hasError) {
            return
        }

        $telemetries = @{
            useAzure = $azure
        }

        # if prompt is a file path, and the file is exist, then read the file as the prompt
        $parsedprompt = Get-PromptContent $prompt
        $prompt = $parsedprompt.content
        $telemetries.promptType = $parsedprompt.type
        $telemetries.promptLib = $parsedprompt.lib

        # collect the telemetry data
        Submit-Telemetry -cmdletName $MyInvocation.MyCommand.Name -innovationName $MyInvocation.InvocationName -props $telemetries

        $imageContent = $files | ForEach-Object {
            Write-Verbose "Processing file $_"
            $uri = Get-ImageBase64Uri $_
            Write-Verbose "Image uri: $uri"
            Write-Output @{
                type      = "image_url"
                image_url = $uri
            }
        }

        $imageContent = @(@{type = "text"; text = $prompt }) + $imageContent

        $params = @{
            Uri         = $endpoint
            Method      = "POST"
            Body        = @{
                model       = "$engine"
                messages    = @(
                    @{
                        role    = "user"
                        content = $imageContent
                    }
                )
                max_tokens  = $max_tokens
                temperature = $temperature
            } | ConvertTo-Json -Depth 10
            Headers     = if ($azure) { @{"api-key" = "$api_key" } } else { @{"Authorization" = "Bearer $api_key" } }
            ContentType = "application/json;charset=utf-8"
        }

        Write-Verbose $params


        $response = Invoke-RestMethod @params

        if ($PSVersionTable['PSVersion'].Major -eq 5) {
            Write-Verbose "Powershell 5.0 detected, convert the response to UTF8"

            $dstEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
            $srcEncoding = [System.Text.Encoding]::UTF8

            $response.choices | ForEach-Object {
                $_.message.content = $srcEncoding.GetString([System.Text.Encoding]::Convert($srcEncoding, $dstEncoding, $srcEncoding.GetBytes($_.message.content)))
            }

        }
        Write-Verbose "Response converted to UTF8: $($response | ConvertTo-Json -Depth 10)"

        $result = $response.choices[0].message.content
        Write-Verbose "Response parsed to plain text: $result"
        if ($outFile) {
            Write-Verbose "Write result to file $outFile"
            $result | Out-File $outFile -Encoding utf8
        }
        else {
            Write-Verbose "Output result to pipeline"
            Write-Output $result 
            Set-Clipboard $result
            Write-Host "Copied the response to clipboard." -ForegroundColor Green
        }
    }
}