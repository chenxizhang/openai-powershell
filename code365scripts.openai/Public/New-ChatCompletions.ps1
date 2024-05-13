function New-ChatCompletions {
    <#
    .EXTERNALHELP
        code365scripts.openai-help.xml
    .SYNOPSIS
        Create a new ChatGPT conversation or get a Chat Completion result if you specify the prompt parameter directly.
    .DESCRIPTION
        Create a new ChatGPT conversation, You can chat with the OpenAI service just like chat with a human. You can also get the chat completion result if you specify the prompt parameter.
    .PARAMETER api_key
        The API key to access OpenAI service, if not specified, the API key will be read from environment variable OPENAI_API_KEY. You can also use "token" or "access_token" or "accesstoken" as the alias.
    .PARAMETER model
        The model to use for this request, you can also set it in environment variable OPENAI_API_MODEL. If you are using Azure OpenAI Service, the model should be the deployment name you created in portal.
    .PARAMETER endpoint
        The endpoint to use for this request, you can also set it in environment variable OPENAI_API_ENDPOINT. You can also use some special value to specify the endpoint, like "ollama", "local", "kimi", "zhipu".
    .PARAMETER system
        The system prompt, this is a string, you can use it to define the role you want it be, for example, "You are a chatbot, please answer the user's question according to the user's language."
        If you provide a file path to this parameter, we will read the file as the system prompt.
        You can also specify a url to this parameter, we will read the url as the system prompt.
        You can read the prompt from a library (https://github.com/code365opensource/promptlibrary), by use "lib:xxxxx" as the prompt, for example, "lib:fitness".
    .PARAMETER prompt
        If you want to get result immediately, you can use this parameter to define the prompt. It will not start the chat conversation.
        If you provide a file path to this parameter, we will read the file as the prompt.
        You can also specify a url to this parameter, we will read the url as the prompt.
        You can read the prompt from a library (https://github.com/code365opensource/promptlibrary), by use "lib:xxxxx" as the prompt, for example, "lib:fitness".
    .PARAMETER config
        The dynamic settings for the API call, it can meet all the requirement for each model. please pass a custom object to this parameter, like @{temperature=1;max_tokens=1024}.
    .PARAMETER outFile
        If you want to save the result to a file, you can use this parameter to set the file path. You can also use "out" as the alias.
    .PARAMETER context
        If you want to pass some dymamic value to the prompt, you can use the context parameter here. It can be anything, you just specify a custom powershell object here. You define the variables in the system prompt or user prompt by using {{you_variable_name}} syntext, and then pass the data to the context parameter, like @{you_variable_name="your value"}. if there are multiple variables, you can use @{variable1="value1";variable2="value2"}.
    .PARAMETER headers
        If you want to pass some custom headers to the API call, you can use this parameter. You can pass a custom hashtable to this parameter, like @{header1="value1";header2="value2"}.
    .PARAMETER json
        Send the response in json format.
    .PARAMETER functions
        This is s super powerful feature to support the function_call of OpenAI, you can specify the function name(s) and it will be automatically called when the assistant needs it. You can find all the avaliable functions definition here (https://raw.githubusercontent.com/chenxizhang/openai-powershell/master/code365scripts.openai/Private/functions.json)
    .OUTPUTS
        System.String, the completion result.  
    .LINK
        https://github.com/chenxizhang/openai-powershell
    #>

    [CmdletBinding()]
    [Alias("gpt")]
    param(
        [Alias("token", "access_token", "accesstoken", "key", "apikey")]
        [string]$api_key,
        [Alias("engine", "deployment")]
        [string]$model,
        [string]$endpoint,
        [string]$system = "You are a chatbot, please answer the user's question according to the user's language.",
        [Parameter(ValueFromPipeline = $true, Position = 0, Mandatory = $true)]
        [string]$prompt,
        [Alias("settings")]
        [PSCustomObject]$config, 
        [Alias("out")]   
        [string]$outFile,
        [switch]$json,
        [Alias("variables")]
        [PSCustomObject]$context,
        [PSCustomObject]$headers,
        [string[]]$functions,
        [switch]$passthru
    )
    BEGIN {

        Write-Verbose ($resources.verbose_parameters_received -f ($PSBoundParameters | Out-String))
        Write-Verbose ($resources.verbose_environment_received -f (Get-ChildItem Env:OPENAI_API_* | Out-String))

        $api_key = ($api_key, [System.Environment]::GetEnvironmentVariable("OPENAI_API_KEY") | Where-Object { $_.Length -gt 0 } | Select-Object -First 1)
        $model = ($model, [System.Environment]::GetEnvironmentVariable("OPENAI_API_MODEL"), "gpt-3.5-turbo" | Where-Object { $_.Length -gt 0 } | Select-Object -First 1)
        $endpoint = ($endpoint, [System.Environment]::GetEnvironmentVariable("OPENAI_API_ENDPOINT"), "https://api.openai.com/v1/chat/completions" | Where-Object { $_.Length -gt 0 } | Select-Object -First 1)

        $endpoint = switch ($endpoint) {
            { $_ -in ("ollama", "local") } { "http://localhost:11434/v1/chat/completions" }
            "kimi" { "https://api.moonshot.cn/v1/chat/completions" }
            "zhipu" { "https://open.bigmodel.cn/api/paas/v4/chat/completions" }
            default { $endpoint }
        }

        # if use local model, and api_key is not specify, then generate a random key
        if ($endpoint -eq "http://localhost:11434/v1/chat/completions" -and !$api_key) {
            $api_key = "local"
        }

        Write-Verbose ($resources.verbose_parameters_parsed -f $api_key, $model, $endpoint)

        $hasError = $false

        if (!$api_key) {
            Write-Error $resources.error_missing_api_key
            $hasError = $true
        }

        if (!$model) {
            Write-Error $resources.error_missing_engine
            $hasError = $true
        }

        if (!$endpoint) {
            Write-Error $resources.error_missing_endpoint
            $hasError = $true
        }

        if ($hasError) {
            return
        }

        # if endpoint contains ".openai.azure.com", then people wants to use azure openai service, try to concat the endpoint with the model
        if ($endpoint.EndsWith("openai.azure.com/")) {
            $version = Get-AzureAPIVersion
            $endpoint += "openai/deployments/$model/chat/completions?api-version=$version"
        }

        # add databricks support, it will use the basic authorization method, not the bearer token
        $azure = $endpoint.Contains("openai.azure.com")

        $header = if ($azure) { 
            # if the apikey is a jwt, then use the bearer token in authorization header
            if ($api_key -match "^ey[a-zA-Z0-9-_]+\.[a-zA-Z0-9-_]+\.[a-zA-Z0-9-_]+$") {
                @{"Authorization" = "Bearer $api_key" }
            }
            else {
                @{"api-key" = "$api_key" } 
            }
        }
        else { 
            # dbrx instruct use the basic authorization method
            
            @{"Authorization" = "$(if($endpoint.Contains("databricks-dbrx-instruct")){"Basic"}else{"Bearer"}) $api_key" } 
        }

        # if user provide the headers, merge the headers to the default headers
        if ($headers) {
            Merge-Hashtable -table1 $header -table2 $headers
        }

        # if user provide the functions, get the functions from the functions file and define the tools and tool_choice thoughs the config parameter
        if ($functions) {
            $tools = @(Get-PredefinedFunctions -names $functions)
            if ($tools.Count -gt 0) {
                if ($null -eq $config) {
                    $config = @{}
                }
                $config["tools"] = $tools
                $config["tool_choice"] = "auto"
            }
        }

        
    }

    PROCESS {
        $telemetries = @{
            type = switch ($endpoint) {
                { $_ -match "openai.azure.com" } { "azure" }
                { $_ -match "localhost" } { "local" }
                { $_ -match "databricks-dbrx" } { "dbrx" }
                { $_ -match "api.openai.com" } { "openai" }
                { $_ -match "platform.moonshot.cn" } { "kimi" }
                { $_ -match "open.bigmodel.cn" } { "zhipu" }
                default { $endpoint }
            }
        }

        # if prompt is not empty and it is a file, then read the file as the prompt
        $parsedprompt = Get-PromptContent -prompt $prompt -context $context
        $prompt = $parsedprompt.content
        $telemetries.Add("promptType", $parsedprompt.type)
        $telemetries.Add("promptLib", $parsedprompt.lib)

        # if system is not empty and it is a file, then read the file as the system prompt
        $parsedsystem = Get-PromptContent -prompt $system -context $context
        $system = $parsedsystem.content

        $telemetries.Add("systemPromptType", $parsedsystem.type)
        $telemetries.Add("systemPromptLib", $parsedsystem.lib)

        # collect the telemetry data
        Submit-Telemetry -cmdletName $MyInvocation.MyCommand.Name -innovationName $MyInvocation.InvocationName -props $telemetries



        # user provides the prompt directly, so enter the completion mode (return the result directly)
        Write-Verbose ($resources.verbose_prompt_mode -f $prompt)
        $messages = @(
            @{
                role    = "system"
                content = $system
            },
            @{
                role    = "user"
                content = $prompt
            }
        ) 

        $body = @{model = "$model"; messages = $messages }

        $params = @{
            Uri     = $endpoint
            Method  = "POST"
            Headers = $header
        }

        if ($json) {
            $body.Add("response_format" , @{type = "json_object" } )
        }

        if ($config) {
            Merge-Hashtable -table1 $body -table2 $config
        }

        $params.Body = ($body | ConvertTo-Json -Depth 10)

        Write-Verbose ($resources.verbose_prepare_params -f ($params | ConvertTo-Json -Depth 10))

        $response = Invoke-UniWebRequest $params

        # if return the tool_calls, then execute the tool locally and add send the message again.

        while ($response.choices -and $response.choices[0].message.tool_calls) {
            # add the assistant message 
            $this_message = $response.choices[0].message
            $body.messages += $this_message
            $tool_calls = $this_message.tool_calls
                
            foreach ($tool in $tool_calls) {
                Write-Verbose "$($resources.function_call): $($tool.function.name)"
                $function_args = $tool.function.arguments | ConvertFrom-Json
                $tool_response = Invoke-Expression ("{0} {1}" -f $tool.function.name, (
                        $function_args.PSObject.Properties | ForEach-Object {
                            "-{0} {1}" -f $_.Name, $_.Value
                        }
                    ) -join " ")

                $body.messages += @{
                    role         = "tool"
                    name         = $tool.function.name
                    tool_call_id = $tool.id
                    content      = $tool_response
                }
            }

            $params.Body = ($body | ConvertTo-Json -Depth 10)
            $response = Invoke-UniWebRequest $params
        }

        Write-Verbose ($resources.verbose_response_utf8 -f ($response | ConvertTo-Json -Depth 10))

        $result = $response.choices[0].message.content
        Write-Verbose ($resources.verbose_response_plain_text -f $result)

        #if user specify the outfile, write the response to the file
        if ($outFile) {
            Write-Verbose ($resources.verbose_outfile_specified -f $outFile)
            $result | Out-File -FilePath $outFile -Encoding utf8

            if($passthru){
                Write-Output $result
            }
        }
        else{
            # support passthru, even though user specify the outfile, we still return the result to the pipeline
            Write-Output $result
        }
    }
}
