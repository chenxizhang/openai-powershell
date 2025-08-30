function New-OpenAICompletion {
    <#
    .SYNOPSIS
        Get completion from OpenAI API
    .DESCRIPTION
        Get completion from OpenAI API, you can use this cmdlet to get completion from OpenAI API.The cmdlet accept pipeline input. You can also assign the prompt, api_key, engine, endpoint, max_tokens, temperature, n parameters.
    .PARAMETER prompt
        The prompt to get completion from OpenAI API. If yuo provide a file path, we will read the file as prompt. You can also set prompt in pipeline input.
        You can also specify the prompt as a url, we will read the url as prompt.
        You can read the prompt from a library (https://github.com/code365opensource/promptlibrary), by use "lib:xxxxx" as the prompt, for example, "lib:fitness".
    .PARAMETER api_key
        The api_key to get completion from OpenAI API. You can also set api_key in environment variable OPENAI_API_KEY or OPENAI_API_KEY_AZURE (if you want to use Azure OpenAI Service API).
    .PARAMETER engine
        The engine to get completion from OpenAI API. You can also set engine in environment variable OPENAI_ENGINE or OPENAI_ENGINE_AZURE (if you want to use Azure OpenAI Service API). The default value is text-davinci-003, but now we recommend you to use gpt-3.5-turbo-instruct.You can use model or deployment as the alias of engine.
    .PARAMETER endpoint
        The endpoint to get completion from OpenAI API. You can also set endpoint in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_AZURE (if you want to use Azure OpenAI Service API).
    .PARAMETER max_tokens
        The max_tokens to get completion from OpenAI API. The default value is 1024.
    .PARAMETER temperature
        The temperature to get completion from OpenAI API. The default value is 1, which means most creatively.
    .PARAMETER n
        If you want to get multiple completion, you can use this parameter. The default value is 1.
    .PARAMETER azure
        If you want to use Azure OpenAI API, you can use this switch.
    .PARAMETER environment
        If you want to use Azure OpenAI API, you can use this parameter to set the environment. We will read environment variable OPENAI_API_KEY_AZURE_$environment, OPENAI_ENGINE_AZURE_$environment, OPENAI_ENDPOINT_AZURE_$environment. if you don't set this parameter (or the environment doesn't exist), we will read environment variable OPENAI_API_KEY_AZURE, OPENAI_ENGINE_AZURE, OPENAI_ENDPOINT_AZURE.
        You can use env as the alias of environment.
    .PARAMETER api_version
        If you want to use Azure OpenAI API, you can use this parameter to set the api_version. The default value is 2023-09-01-preview.
    .PARAMETER outFile
        If you want to save the result to a file, you can use this parameter to set the file path.
    .EXAMPLE
        New-OpenAICompletion -prompt "Which city is the capital of China?"
        Use default api_key, engine, endpoint from environment varaibles
    .EXAMPLE
        noc "Which city is the capital of China?"
        Use alias of the cmdlet with default api_key, engine, endpoint from environment varaibles
    .EXAMPLE
        "Which city is the capital of China?" | noc
        Use pipeline input
    .EXAMPLE
        noc "Which city is the capital of China?" -api_key "your api key"
        Set api_key in the command
    .EXAMPLE
        noc "Which city is the capital of China?" -api_key "your api key" -engine "davinci"
        Set api_key and engine in the command
    .EXAMPLE
        noc "Which city is the capital of China?" -azure
        Use Azure OpenAI API
    .EXAMPLE
        "string 1","string 2" | noc -azure
        Use Azure OpenAI API with pipeline input (multiple strings)
    .EXAMPLE
        noc "Which city is the capital of China?" -azure -environment "dev"
        Use Azure OpenAI API with environment variable OPENAI_API_KEY_AZURE_dev, OPENAI_ENGINE_AZURE_dev, OPENAI_ENDPOINT_AZURE_dev
    .EXAMPLE
        noc "Which city is the capital of China?" -azure -environment "dev" -api_version "2023-09-01-preview"
        Use Azure OpenAI API with environment variable OPENAI_API_KEY_AZURE_dev, OPENAI_ENGINE_AZURE_dev, OPENAI_ENDPOINT_AZURE_dev and api_version 2023-09-01-preview
    .EXAMPLE
        noc -azure -prompt "c:\temp\prompt.txt"
        Use Azure OpenAI API with prompt from file
    .LINK
        https://github.com/chenxizhang/openai-powershell
    .INPUTS
        System.String, you can pass one or more string to the cmdlet, and we will get the completion for you.
    .OUTPUTS
        System.String, the completion result.
    #>

    [CmdletBinding()]
    [Alias("noc")]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$prompt,
        [string]$api_key,
        [Parameter()]
        [Alias("model", "deployment")]
        [string]$engine,
        [Parameter()][string]$endpoint,
        [Parameter()][int]$max_tokens = 1024,
        [Parameter()][double]$temperature = 1,
        [Parameter()][int]$n = 1,
        [switch]$azure,
        [Alias("env")]
        [string]$environment,
        [string]$api_version = "2023-09-01-preview",
        [string]$outFile
    )

    BEGIN {

        Write-Verbose "Parameter received`n$($PSBoundParameters | Out-String)"
        Write-Verbose "Environment variable detected.`n$(Get-ChildItem Env:OPENAI_* | Out-String)"

        if ($azure) {
            $api_key = if ($api_key) { $api_key } else { Get-FirstNonNullItemInArray("OPENAI_API_KEY_AZURE_$environment", "OPENAI_API_KEY_AZURE") }
            $engine = if ($engine) { $engine } else { Get-FirstNonNullItemInArray("OPENAI_ENGINE_AZURE_$environment", "OPENAI_ENGINE_AZURE") }
            $endpoint = "{0}openai/deployments/{1}/completions?api-version=$api_version" -f $(if ($endpoint) { $endpoint }else { Get-FirstNonNullItemInArray("OPENAI_ENDPOINT_AZURE_$environment", "OPENAI_ENDPOINT_AZURE") }), $engine
        }
        else {
            $api_key = if ($api_key) { $api_key } else { $env:OPENAI_API_KEY }
            $engine = if ($engine) { $engine } else { if ($env:OPENAI_ENGINE) { $env:OPENAI_ENGINE }else { "text-davinci-003" } }
            $endpoint = if ($endpoint) { $endpoint } else { if ($env:OPENAI_ENDPOINT) { $env:OPENAI_ENDPOINT }else { "https://api.openai.com/v1/completions" } }
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


    }

    PROCESS {



        if ($hasError) {
            return
        }

        $telemetries =@{
            useAzure = $azure
        }

        # if prompt is a file path, and the file is exist, then read the file as the prompt
        $parsedprompt = Get-PromptContent $prompt
        $prompt = $parsedprompt.content
        $telemetries.promptType = $parsedprompt.type
        $telemetries.promptLib = $parsedprompt.lib

        # collect the telemetry data
        Submit-Telemetry -cmdletName $MyInvocation.MyCommand.Name -innovationName $MyInvocation.InvocationName -props $telemetries
    
        $params = @{
            Uri         = $endpoint
            Method      = "POST"
            Body        = @{
                model       = "$engine"
                prompt      = "$prompt"
                max_tokens  = $max_tokens
                temperature = $temperature
                n           = $n
            } | ConvertTo-Json -Depth 10
            Headers     = if ($azure) { @{"api-key" = "$api_key" } } else { @{"Authorization" = "Bearer $api_key" } }
            ContentType = "application/json;charset=utf-8"
        }

        Write-Verbose "Prepare the params for Invoke-WebRequest: $($params | ConvertTo-Json -Depth 10) "


        try {
            $response = Invoke-RestMethod @params

            Write-Verbose "Response received: $($response | ConvertTo-Json -Depth 10)"

            if ($PSVersionTable['PSVersion'].Major -eq 5) {
                Write-Verbose "Powershell 5.0 detected, convert the response to UTF8"

                $dstEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
                $srcEncoding = [System.Text.Encoding]::UTF8

                $response.choices | ForEach-Object {
                    $_.text = $srcEncoding.GetString([System.Text.Encoding]::Convert($srcEncoding, $dstEncoding, $srcEncoding.GetBytes($_.text)))
                }

                Write-Verbose "Response converted to UTF8: $($response | ConvertTo-Json -Depth 10)"
            }
        
            # parse the response to plain text
            $response = $response.choices.text
            Write-Verbose "Response parsed to plain text: $response"

            # write the response to console
            # if user specify the outfile, write the response to the file
            if ($outFile) {
                Write-Verbose "Write the response to file: $outFile"
                $response | Out-File $outFile -Encoding utf8
            }
            else {
                Write-Output $response

                Set-Clipboard $response
                Write-Host "Copied the response to clipboard." -ForegroundColor Green
            }

            Write-Verbose "Response copied to clipboard: $response"
            
        }
        catch {
            $errorMessage = if ($_.ErrorDetails) { 
                try {
                    $errorObj = $_.ErrorDetails | ConvertFrom-Json
                    if ($errorObj.error.message) {
                        "API Error: $($errorObj.error.message)"
                    } else {
                        $_.ErrorDetails
                    }
                }
                catch {
                    $_.ErrorDetails
                }
            } elseif ($_.Exception.Message) { 
                $_.Exception.Message 
            } else { 
                "Unknown error occurred during completion request" 
            }
            Write-Error "OpenAI completion failed: $errorMessage"
        }
    }

}