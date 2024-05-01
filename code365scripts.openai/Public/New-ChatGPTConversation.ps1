function New-ChatGPTConversation {

    <#
    .SYNOPSIS
        Create a new ChatGPT conversation or get a Chat Completion result.(if you specify the prompt parameter)
    .DESCRIPTION
        Create a new ChatGPT conversation, You can chat with the OpenAI service just like chat with a human. You can also get the chat completion result if you specify the prompt parameter.
    .PARAMETER api_key
        The API key to access OpenAI service, if not specified, the API key will be read from environment variable OPENAI_API_KEY. if you use azure OpenAI service, you can specify the API key by environment variable OPENAI_API_KEY_AZURE or OPENAI_API_KEY_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_API_KEY_AZURE_PROD, OPENAI_API_KEY_AZURE_TEST, etc.
    .PARAMETER model
        The model to use for this request, you can also set it in environment variable OPENAI_CHAT_MODEL or OPENAI_CHAT_DEPLOYMENT_AZURE if you use Azure OpenAI service. If you use multiple environments, you can use OPENAI_CHAT_DEPLOYMENT_AZURE_<environment> to define the model for each environment. You can use engine or deployment as the alias of this parameter.
    .PARAMETER endpoint
        The endpoint to use for this request, you can also set it in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_AZURE if you use Azure OpenAI service. If you use multiple environments, you can use OPENAI_ENDPOINT_AZURE_<environment> to define the endpoint for each environment.
    .PARAMETER azure
        if you use Azure OpenAI service, you can use this switch.
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
    .PARAMETER environment
        The environment name, if you use Azure OpenAI service, you can use this parameter to define the environment name, it will be used to get the API key, model and endpoint from environment variable. If the environment is not exist, it will use the default environment. 
        You can use env as the alias of this parameter.
    .PARAMETER api_version
        The api version, if you use Azure OpenAI service, you can use this parameter to define the api version, the default value is 2023-09-01-preview.
    .PARAMETER outFile
        If you want to save the result to a file, you can use this parameter to set the file path. You can also use "out" as the alias.
    .PARAMETER local
        If you want to use the local LLMs, like the model hosted by ollama, you can use this switch. You can also use "ollama" as the alias.
    .PARAMETER context
        If you want to pass some dymamic value to the prompt, you can use the context parameter here. It can be anything, you just specify a custom powershell object here. You define the variables in the system prompt or user prompt by using {{you_variable_name}} syntext, and then pass the data to the context parameter, like @{you_variable_name="your value"}. if there are multiple variables, you can use @{variable1="value1";variable2="value2"}.
    .PARAMETER json
        Send the response in json format.
    .EXAMPLE
        New-ChatGPTConversation
        Create a new ChatGPT conversation, use OpenAI service with all the default settings.
    .EXAMPLE
        New-ChatGPTConverstaion -azure
        Create a new ChatGPT conversation, use Azure OpenAI service with all the default settings.
    .EXAMPLE
        chat -azure
        Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure OpenAI service with all the default settings.
    .EXAMPLE
        New-ChatGPTConversation -api_key "your API key" -model "your model name"
        Create a new ChatGPT conversation, use OpenAI service with your API key and model name.
    .EXAMPLE
        New-ChatGPTConversation -api_key "your API key" -model "your deployment name" -azure
        Create a new ChatGPT conversation, use Azure OpenAI service with your API key and deployment name.
    .EXAMPLE
        New-ChatGPTConversation -api_key "your API key" -model "your deployment name" -azure -system "You are a chatbot, please answer the user's question according to the user's language."
        Create a new ChatGPT conversation, use Azure OpenAI service with your API key and deployment name, and define the system prompt.
    .EXAMPLE
        New-ChatGPTConversation -api_key "your API key" -model "your deployment name" -azure -system "You are a chatbot, please answer the user's question according to the user's language." -endpoint "https://api.openai.com/v1/completions"
        Create a new ChatGPT conversation, use Azure OpenAI service with your API key and model id, and define the system prompt and endpoint.
    .EXAMPLE
        chat -azure -system "You are a chatbot, please answer the user's question according to the user's language." -env "sweden"
        Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure OpenAI service with the API key, model and endpoint defined in environment variable OPENAI_API_KEY_AZURE_SWEDEN, OPENAI_CHAT_DEPLOYMENT_AZURE_SWEDEN and OPENAI_ENDPOINT_AZURE_SWEDEN.
    .EXAMPLE
        chat -azure -api_version "2021-09-01-preview"
        Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure OpenAI service with the api version 2021-09-01-preview.
    .EXAMPLE
        gpt -azure -prompt "why people smile"
        Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the prompt.
    .EXAMPLE
        "why people smile" | gpt -azure
        Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the prompt from pipeline.
    .EXAMPLE
        gpt -azure -prompt "c:\temp\prompt.txt"
        Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the prompt from file.
    .EXAMPLE
        gpt -azure -prompt "c:\temp\prompt.txt" -context @{variable1="value1";variable2="value2"}
        Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the prompt from file, pass some data to the prompt.
    .EXAMPLE
        gpt -azure -system "c:\temp\system.txt" -prompt "c:\temp\prompt.txt"
        Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the system prompt and prompt from file.
    .EXAMPLE
        gpt -azure -system "c:\temp\system.txt" -prompt "c:\temp\prompt.txt" -outFile "c:\temp\result.txt"
        Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the system prompt and prompt from file, then save the result to a file.
    .EXAMPLE
        gpt -azure -system "c:\temp\system.txt" -prompt "c:\temp\prompt.txt" -config @{temperature=1;max_tokens=1024}
        Create a new ChatGPT conversation by cmdlet's alias(gpt), use Azure OpenAI service with the system prompt and prompt from file and your customized settings.
    .EXAMPLE
        chat -local -model "llama3"
        Create a new ChatGPT conversation by using local LLMs, for example, the llama3. The default endpoint is http://localhost:11434/v1/chat/completions. You can modify this endpoint as well.
    .OUTPUTS
        System.String, the completion result.  
    .LINK
        https://github.com/chenxizhang/openai-powershell
    #>


    [CmdletBinding(DefaultParameterSetName = "default")]
    [Alias("chatgpt")][Alias("chat")][Alias("gpt")]
    param(
        [Parameter(ParameterSetName = "local", Mandatory = $true)]
        [Alias("ollama")]
        [switch]$local,
        [Parameter(ParameterSetName = "azure", Mandatory = $true)]
        [switch]$azure,
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]
        [string]$api_key,
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]    
        [Parameter(ParameterSetName = "local", Mandatory = $true)]
        [Alias("engine", "deployment")]
        [string]$model,
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]    
        [Parameter(ParameterSetName = "local")]
        [string]$endpoint,
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]    
        [Parameter(ParameterSetName = "local")]
        [string]$system = "You are a chatbot, please answer the user's question according to the user's language.",
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]    
        [Parameter(ParameterSetName = "local")]
        [Parameter(ValueFromPipeline = $true)]
        [string]$prompt = "",
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]    
        [Parameter(ParameterSetName = "local")]
        [PSCustomObject]$config,
        [Parameter(ParameterSetName = "azure")]
        [Alias("env")]
        [string]$environment,
        [Parameter(ParameterSetName = "azure")]
        [string]$api_version = "2023-09-01-preview",   
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]    
        [Parameter(ParameterSetName = "local")]
        [Alias("out")]   
        [string]$outFile,
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]    
        [Parameter(ParameterSetName = "local")]
        [switch]$json,
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]    
        [Parameter(ParameterSetName = "local")]
        [PSCustomObject]$context
    )
    BEGIN {

        Write-Verbose ($resources.verbose_parameters_received -f ($PSBoundParameters | Out-String))
        Write-Verbose ($resources.verbose_environment_received -f (Get-ChildItem Env:OPENAI_* | Out-String))

        switch ($PSCmdlet.ParameterSetName) {
            "default" {
                $api_key = if ($api_key) { $api_key } else { $env:OPENAI_API_KEY }
                $model = if ($model) { $model } else { if ($env:OPENAI_CHAT_MODEL) { $env:OPENAI_CHAT_MODEL }else { "gpt-3.5-turbo" } }
                $endpoint = if ($endpoint) { $endpoint } else { "https://api.openai.com/v1/chat/completions" }
            }
            "azure" {
                $api_key = if ($api_key) { $api_key } else { Get-FirstNonNullItemInArray("OPENAI_API_KEY_AZURE_$environment", "OPENAI_API_KEY_AZURE") }
                $model = if ($model) { $model } else { Get-FirstNonNullItemInArray("OPENAI_CHAT_DEPLOYMENT_AZURE_$environment", "OPENAI_CHAT_DEPLOYMENT_AZURE") }
                $endpoint = if ($endpoint) { "{0}openai/deployments/$model/chat/completions?api-version=$api_version" -f $endpoint } else { "{0}openai/deployments/$model/chat/completions?api-version=$api_version" -f (Get-FirstNonNullItemInArray("OPENAI_ENDPOINT_AZURE_$environment", "OPENAI_ENDPOINT_AZURE")) }
            }
            "local" {
                $endpoint = if ($endpoint) { $endpoint }else { "http://localhost:11434/v1/chat/completions" }
                $api_key = if ($api_key) { $api_key } else { "local" }
            }
        }

        Write-Verbose ($resources.verbose_parameters_parsed -f $api_key, $model, $endpoint)

        $hasError = $false

        if ((!$azure) -and ((Test-OpenAIConnectivity) -eq $False)) {
            Write-Error $resources.openai_unavaliable
            $hasError = $true
        }


        if (!$api_key) {
            Write-Error $resources.error_missing_api_key
            $hasError = $true
        }

        if (!$model) {
            Write-Error $resources.error_missing_engine
            $hasError = $true
        }
    }

    PROCESS {

        if ($hasError) {
            return
        }

        $telemetries = @{
            type = $PSCmdlet.ParameterSetName
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
                Headers     = if ($azure) { @{"api-key" = "$api_key" } } else { @{"Authorization" = "Bearer $api_key" } }
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
            else {
                Write-Verbose ($resources.verbose_outfile_not_specified)
                Write-Output $result

                # if user does not specify the outfile, copy the response to clipboard
                # Set-Clipboard $result
                # Write-Host "Copied the response to clipboard." -ForegroundColor Green
            }

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
                    Headers     = if ($azure) { @{"api-key" = "$api_key" } } else { @{"Authorization" = "Bearer $api_key" } }
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

                        if ($azure) {
                            $request.Headers.Add("api-key", $api_key)
                        }
                        else {
                            $request.Headers.Add("Authorization", "Bearer $api_key")
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
                            Write-Verbose ($resources.verbose_chat_stream_chunk_received -f $chunk)
                            $result += $chunk
    
                            Start-Sleep -Milliseconds 50
                        }
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
