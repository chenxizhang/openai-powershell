function New-ChatGPTConversation {
    <#
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
    .EXAMPLE
        New-ChatGPTConversation

        Use OpenAI Service with all the default settings, will read the API key from environment variable (OPENAI_API_KEY), enter the chat mode.
    .EXAMPLE 
        New-ChatGPTConversation -api_key "your api key" -model "gpt-3.5-turbo"

        Use OpenAI Service with the specified api key and model, enter the chat mode.
    .EXAMPLE
        chat -system "You help me to translate the text to Chinese."

        Use OpenAI Service to translate text (system prompt specified), will read the API key from environment variable (OPENAI_API_KEY), enter the chat mode.
    .EXAMPLE
        chat -endpoint "ollama" -model "llama3"

        Use OpenAI Service with the local model, enter the chat mode.
    .EXAMPLE
        chat -endpoint $endpoint $env:OPENAI_API_ENDPOINT_AZURE -model $env:OPENAI_API_MODEL_AZURE -api_key $env:OPENAI_API_KEY_AZURE

        Use Azure OpenAI Service with the specified api key and model, enter the chat mode.
    
    .EXAMPLE
        gpt -system "Translate the text to Chinese." -prompt "Hello, how are you?"

        Use OpenAI Service to translate text (system prompt specified), will read the API key from environment variable (OPENAI_API_KEY), model from OPENAI_API_MODEL (if present) or use "gpt-3.5-turbo" as default, get the chat completion result directly.

    .EXAMPLE
        "Hello, how are you?" | gpt -system "Translate the text to Chinese."

        Use OpenAI Service to translate text (system prompt specified, user prompt will pass from pipeline), will read the API key from environment variable (OPENAI_API_KEY), model from OPENAI_API_MODEL (if present) or use "gpt-3.5-turbo" as default, get the chat completion result directly.

    .OUTPUTS
        System.String, the completion result.  
    .LINK
        https://github.com/chenxizhang/openai-powershell
    #>

    [CmdletBinding(DefaultParameterSetName = "default")]
    [Alias("chatgpt")][Alias("chat")][Alias("gpt")]
    param(
        [Alias("token", "access_token", "accesstoken", "key", "apikey")]
        [string]$api_key,
        [Alias("engine", "deployment")]
        [string]$model,
        [string]$endpoint,
        [string]$system = "You are a chatbot, please answer the user's question according to the user's language.",
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [string]$prompt = "",
        [Alias("settings")]
        [PSCustomObject]$config, 
        [Alias("out")]   
        [string]$outFile,
        [switch]$json,
        [Alias("variables")]
        [PSCustomObject]$context,
        [PSCustomObject]$headers
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
    }

    PROCESS {

        if ($hasError) {
            return
        }

        # if endpoint contains ".openai.azure.com", then people wants to use azure openai service, try to concat the endpoint with the model
        if ($endpoint.EndsWith("openai.azure.com/")) {
            $version = Get-AzureAPIVersion
            $endpoint += "openai/deployments/$model/chat/completions?api-version=$version"
        }


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
        $parsedprompt = Get-PromptContent($prompt)
        $prompt = $parsedprompt.content

        # if user provide the context, inject the data into the prompt by replace the context key with the context value
        if ($context) {
            Write-Verbose ($resources.verbose_context_received -f ($context | ConvertTo-Json -Depth 10))
            foreach ($key in $context.keys) {
                $prompt = $prompt -replace "{{$key}}", $context[$key]
            }
            Write-Verbose ($resources.verbose_prompt_context_injected -f $prompt)
        }

        $telemetries.Add("promptType", $parsedprompt.type)
        $telemetries.Add("promptLib", $parsedprompt.lib)

        # if system is not empty and it is a file, then read the file as the system prompt
        $parsedsystem = Get-PromptContent($system)
        $system = $parsedsystem.content

        # if user provide the context, inject the data into the system prompt by replace the context key with the context value
        if ($context) {
            Write-Verbose ($resources.verbose_context_received -f ($context | ConvertTo-Json -Depth 10))
            foreach ($key in $context.keys) {
                $system = $system -replace "{{$key}}", $context[$key]
            }
            Write-Verbose ($resources.verbose_prompt_context_injected -f $system)
        }

        $telemetries.Add("systemPromptType", $parsedsystem.type)
        $telemetries.Add("systemPromptLib", $parsedsystem.lib)

        # collect the telemetry data
        Submit-Telemetry -cmdletName $MyInvocation.MyCommand.Name -innovationName $MyInvocation.InvocationName -props $telemetries

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

        if ($PSBoundParameters.Keys.Contains("prompt")) {
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

            $params = @{
                Uri         = $endpoint
                Method      = "POST"
                Body        = @{model = "$model"; messages = $messages }
                Headers     = $header
                ContentType = "application/json;charset=utf-8"
            }

            if ($json) {
                $params.Body.Add("response_format" , @{type = "json_object" } )
            }


            if ($config) {
                Merge-Hashtable -table1 $params.Body -table2 $config
            }

            $params.Body = ($params.Body | ConvertTo-Json -Depth 10)

            Write-Verbose ($resources.verbose_prepare_params -f ($params | ConvertTo-Json -Depth 10))

            $response = Invoke-RestMethod @params

            if ($PSVersionTable['PSVersion'].Major -eq 5) {
                Write-Verbose ($resources.verbose_powershell_5_utf8)

                $dstEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
                $srcEncoding = [System.Text.Encoding]::UTF8

                $response.choices | ForEach-Object {
                    $_.message.content = $srcEncoding.GetString([System.Text.Encoding]::Convert($srcEncoding, $dstEncoding, $srcEncoding.GetBytes($_.message.content)))
                }

            }
            Write-Verbose ($resources.verbose_response_utf8 -f ($response | ConvertTo-Json -Depth 10))

            $result = $response.choices[0].message.content
            Write-Verbose ($resources.verbose_response_plain_text -f $result)

            #if user specify the outfile, write the response to the file
            if ($outFile) {
                Write-Verbose ($resources.verbose_outfile_specified -f $outFile)
                $result | Out-File -FilePath $outFile -Encoding utf8
            }

            # support passthru, even though user specify the outfile, we still return the result to the pipeline
            Write-Output $result
        }
        else {
            Write-Verbose ($resources.verbose_chat_mode)

            $stream = ($PSVersionTable['PSVersion'].Major -gt 5)

            $index = 1; 
            $welcome = "`n{0}`n{1}" -f ($resources.welcome_chatgpt -f $(if ($azure) { " $($resources.azure_version) " } else { "" }), $model), $resources.shortcuts
    
            Write-Host $welcome -ForegroundColor Yellow
            Write-Host $system -ForegroundColor Cyan
    
            $messages = @()
            $systemPrompt = @(
                [PSCustomObject]@{
                    role    = "system"
                    content = $system
                }
            )

            Write-Verbose "Prepare the system prompt: $($systemPrompt|ConvertTo-Json -Depth 10)"
            
            while ($true) {
                Write-Verbose ($resources.verbose_chat_let_chat)

                $current = $index++
                $prompt = Read-Host -Prompt "`n[$current] $($resources.prompt)"
                Write-Verbose "Prompt received: $prompt"
    
                if ($prompt -in ("q", "bye")) {
                    Write-Verbose ($resources.verbose_chat_q_message -f $prompt)
                    break
                }
    
                if ($prompt -eq "m") {

                    $os = [System.Environment]::OSVersion.Platform

                    if ($os -notin @([System.PlatformID]::Win32NT, [System.PlatformID]::Win32Windows, [System.PlatformID]::Win32S)) {
                        Write-Host ($resources.verbose_chat_m_message_not_supported)
                        continue
                    }

                    Write-Verbose ($resources.verbose_chat_m_message)
                    $prompt = Read-MultiLineInputBoxDialog -Message $resources.multi_line_prompt -WindowTitle $resources.multi_line_prompt -DefaultText ""

                    Write-Verbose ($resources.verbose_prompt_received -f $prompt)

                    if ($null -eq $prompt) {
                        Write-Host $resources.cancel_button_message
                        continue
                    }
                    else {
                        Write-Host "$($resources.multi_line_message)`n$prompt"
                    }
                }
    
                if ($prompt -eq "f") {

                    $os = [System.Environment]::OSVersion.Platform

                    if ($os -notin @([System.PlatformID]::Win32NT, [System.PlatformID]::Win32Windows, [System.PlatformID]::Win32S)) {
                        Write-Host ($resources.verbose_chat_f_message_not_supported)
                        continue
                    }

                    Write-Verbose ($resources.verbose_chat_f_message)
    
                    $file = Read-OpenFileDialog -WindowTitle $resources.file_prompt

                    Write-Verbose ($resources.verbose_chat_file_read -f $file)
    
                    if (!($file)) {
                        Write-Host $resources.cancel_button_message
                        continue
                    }
                    else {
                        $prompt = Get-Content $file -Encoding utf8
                        Write-Host "$($resources.multi_line_message)`n$prompt"
                    }
                }
    
                $messages += [PSCustomObject]@{
                    role    = "user"
                    content = $prompt
                }

                Write-Verbose ($resources.verbose_prepare_messages -f ($messages | ConvertTo-Json -Depth 10))
    
                $params = @{
                    Uri         = $endpoint
                    Method      = "POST"
                    Body        = @{model = "$model"; messages = ($systemPrompt + $messages[-5..-1]); stream = $stream } 
                    Headers     = $header
                    ContentType = "application/json;charset=utf-8"
                }

                if ($json) {
                    $params.Body.Add("response_format" , @{type = "json_object" } )
                }


                if ($config) {
                    Merge-Hashtable -table1 $params.Body -table2 $config
                }
                $params.Body = ($params.Body | ConvertTo-Json -Depth 10)


                Write-Verbose ($resources.verbose_prepare_params -f ($params | ConvertTo-Json -Depth 10))
    
                try {
    
                    if ($stream) {
                        Write-Verbose ($resources.verbose_chat_stream_mode)
                        $client = New-Object System.Net.Http.HttpClient
                        $body = $params.Body
                        Write-Verbose "body: $body"
    
                        $request = [System.Net.Http.HttpRequestMessage]::new()
                        $request.Method = "POST"
                        $request.RequestUri = $params.Uri
                        $request.Headers.Clear()
                        $request.Content = [System.Net.Http.StringContent]::new(($body), [System.Text.Encoding]::UTF8)
                        $request.Content.Headers.Clear()
                        $request.Content.Headers.Add("Content-Type", "application/json;charset=utf-8")

                        foreach ($k in $header.Keys) {
                            $request.Headers.Add($k, $header[$k])
                        }
                                        
                        $task = $client.Send($request)
                        $response = $task.Content.ReadAsStream()
                        $reader = [System.IO.StreamReader]::new($response)
                        $result = "" # message from the api
                        Write-Host -ForegroundColor Red "`n[$current] " -NoNewline
    
                        while ($true) {
                            $line = $reader.ReadLine()
                            if (($line -eq $null) -or ($line -eq "data: [DONE]")) { break }
    
                            $chunk = ($line -replace "data: ", "" | ConvertFrom-Json).choices.delta.content
                            Write-Host $chunk -NoNewline -ForegroundColor Green
                            # Write-Verbose ($resources.verbose_chat_stream_chunk_received -f $chunk)
                            $result += $chunk
    
                            Start-Sleep -Milliseconds 5
                        }

                        Write-Host ""

                        $reader.Close()
                        $reader.Dispose()
    
                        $messages += [PSCustomObject]@{
                            role    = "assistant"
                            content = $result
                        }

                        Write-Verbose ($resources.verbose_chat_message_combined -f ($messages | ConvertTo-Json -Depth 10))
                        Write-Host ""
    
                    }
                    else {

                        Write-Verbose ($resources.verbose_chat_not_stream_mode)
                        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                        $response = Invoke-RestMethod @params
                        Write-Verbose ($resources.verbose_chat_response_received -f ($response | ConvertTo-Json -Depth 10))

                        $stopwatch.Stop()
                        $result = $response.choices[0].message.content
                        $total_tokens = $response.usage.total_tokens
                        $prompt_tokens = $response.usage.prompt_tokens
                        $completion_tokens = $response.usage.completion_tokens
        
                        Write-Verbose ($resources.verbose_chat_response_summary -f $result, $total_tokens, $prompt_tokens, $completion_tokens)
        
                        if ($PSVersionTable['PSVersion'].Major -le 5) {

                            Write-Verbose ($resources.verbose_powershell_5_utf8)

                            $dstEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
                            $srcEncoding = [System.Text.Encoding]::UTF8
                            $result = $srcEncoding.GetString([System.Text.Encoding]::Convert($srcEncoding, $dstEncoding, $srcEncoding.GetBytes($result)))

                            Write-Verbose ($resouces.verbose_response_utf8 -f $result)
                        }
        
                        $messages += [PSCustomObject]@{
                            role    = "assistant"
                            content = $result
                        }

                        Write-Verbose ($resources.verbose_chat_message_combined -f ($messages | ConvertTo-Json -Depth 10))
                
        
                        Write-Host -ForegroundColor Red ("`n[$current] $($resources.response)" -f $total_tokens, $prompt_tokens, $completion_tokens )
                        
                        Write-Host $result -ForegroundColor Green
                    }
                }
                catch {
                    Write-Error $_
                }
            }
        }


    }

}
