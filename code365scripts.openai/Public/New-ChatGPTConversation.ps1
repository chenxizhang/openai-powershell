function New-ChatGPTConversation {

    <#
    .SYNOPSIS
        Create a new ChatGPT conversation or get a Chat Completion result.(if you specify the prompt parameter)
    .DESCRIPTION
        Create a new ChatGPT conversation, You can chat with the openai service just like chat with a human. You can also get the chat completion result if you specify the prompt parameter.
    .PARAMETER api_key
        Your OpenAI API key, you can also set it in environment variable OPENAI_API_KEY or OPENAI_API_KEY_AZURE if you use Azure OpenAI API. If you use multiple environments, you can use OPENAI_API_KEY_AZURE_$environment to define the api key for each environment.
    .PARAMETER model
        The engine to use for this request, you can also set it in environment variable OPENAI_CHAT_ENGINE or OPENAI_CHAT_ENGINE_AZURE if you use Azure OpenAI API. If you use multiple environments, you can use OPENAI_CHAT_ENGINE_AZURE_$environment to define the engine for each environment. You can use model or deployment as the alias of engine.
    .PARAMETER endpoint
        The endpoint to use for this request, you can also set it in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_AZURE if you use Azure OpenAI API. If you use multiple environments, you can use OPENAI_ENDPOINT_AZURE_$environment to define the endpoint for each environment.
    .PARAMETER azure
        if you use Azure OpenAI API, you can use this switch.
    .PARAMETER system
        The system prompt, this is a string, you can use it to define the role you want it be, for example, "You are a chatbot, please answer the user's question according to the user's language."
        If you provide a file path to this parameter, we will read the file as the system prompt.
        You can also specify a url to this parameter, we will read the url as the system prompt.
        You can read the prompt from a library (https://github.com/code365opensource/promptlibrary), by use "lib:xxxxx" as the prompt, for example, "lib:fitness".
    .PARAMETER stream
        If you want to stream the response, you can use this switch. Please note, we only support this feature in new Powershell (6.0+).
    .PARAMETER prompt
        If you want to get result immediately, you can use this parameter to define the prompt. It will not start the chat conversation.
        If you provide a file path to this parameter, we will read the file as the prompt.
        You can also specify a url to this parameter, we will read the url as the prompt.
        You can read the prompt from a library (https://github.com/code365opensource/promptlibrary), by use "lib:xxxxx" as the prompt, for example, "lib:fitness".
    .PARAMETER config
        The dynamic settings for the API call, it can meet all the requirement for each model. please pass a custom object to this parameter, like @{temperature=1;max_tokens=1024}
    .PARAMETER environment
        The environment name, if you use Azure OpenAI API, you can use this parameter to define the environment name, it will be used to get the api key, engine and endpoint from environment variable. If the environment is not exist, it will use the default environment.
        You can use env as the alias of this parameter.
    .PARAMETER api_version
        The api version, if you use Azure OpenAI API, you can use this parameter to define the api version, the default value is 2023-09-01-preview.
    .PARAMETER outFile
        If you want to save the result to a file, you can use this parameter to set the file path.
    .PARAMETER local
        If you want to use the local LLMs, like the model hosted by ollama, you can use this switch. You can also use "ollama" as the alias.
    .EXAMPLE
        New-ChatGPTConversation
        Create a new ChatGPT conversation, use openai service with all the default settings.
    .EXAMPLE
        New-ChatGPTConverstaion -azure
        Create a new ChatGPT conversation, use Azure openai service with all the default settings.
    .EXAMPLE
        New-ChatGPTConverstaion -azure -stream
        Create a new ChatGPT conversation, use Azure openai service and stream the response, with all the default settings.
    .EXAMPLE
        chat -azure
        Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure openai service with all the default settings.
    .EXAMPLE
        New-ChatGPTConversation -api_key "your api key" -engine "your engine id"
        Create a new ChatGPT conversation, use openai service with your api key and engine id.
    .EXAMPLE
        New-ChatGPTConversation -api_key "your api key" -engine "your engine id" -azure
        Create a new ChatGPT conversation, use Azure openai service with your api key and engine id.
    .EXAMPLE
        New-ChatGPTConversation -api_key "your api key" -engine "your engine id" -azure -system "You are a chatbot, please answer the user's question according to the user's language."
        Create a new ChatGPT conversation, use Azure openai service with your api key and engine id, and define the system prompt.
    .EXAMPLE
        New-ChatGPTConversation -api_key "your api key" -engine "your engine id" -azure -system "You are a chatbot, please answer the user's question according to the user's language." -endpoint "https://api.openai.com/v1/completions"
        Create a new ChatGPT conversation, use Azure openai service with your api key and engine id, and define the system prompt and endpoint.
    .EXAMPLE
        chat -azure -system "You are a chatbot, please answer the user's question according to the user's language." -environment "sweden"
        Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure openai service with the api key, engine and endpoint defined in environment variable OPENAI_API_KEY_AZURE_SWEDEN, OPENAI_CHAT_ENGINE_AZURE_SWEDEN and OPENAI_ENDPOINT_AZURE_SWEDEN.
    .EXAMPLE
        chat -azure -api_version "2021-09-01-preview"
        Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure openai service with the api version 2021-09-01-preview.
    .EXAMPLE
        chat -azure -prompt "c:\temp\prompt.txt"
        Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure openai service with the prompt from file.
    .EXAMPLE
        chat -azure -system "c:\temp\system.txt" -prompt "c:\temp\prompt.txt"
        Create a new ChatGPT conversation by cmdlet's alias(chat), use Azure openai service with the system prompt and prompt from file.
    .EXAMPLE
        chat -local -model "llama3"
        Create a new ChatGPT conversation by using local LLMs, for example, the llama3. The default endpoint is http://localhost:11434/v1/chat/completions. You can modify this endpoint as well.
    .OUTPUTS
        System.String, the completion result. If you use stream mode, it will not return anything. 
    .LINK
        https://github.com/chenxizhang/openai-powershell
    #>


    [CmdletBinding(DefaultParameterSetName = "default")]
    [Alias("chatgpt")][Alias("chat")][Alias("gpt")]
    param(
        [Parameter(ParameterSetName = "local", Mandatory = $true, Position = 0)]
        [Alias("ollama")]
        [switch]$local,
        [Parameter(ParameterSetName = "azure", Mandatory = $true, Position = 0)]
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
        [string]$prompt = "",
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]    
        [Parameter(ParameterSetName = "local")]
        [switch]$stream,
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
        [string]$outFile,
        [Parameter(ParameterSetName = "default")]
        [Parameter(ParameterSetName = "azure")]    
        [Parameter(ParameterSetName = "local")]
        [switch]$json

    )
    BEGIN {

        Write-Verbose "Parameter received`n$($PSBoundParameters | Out-String)"
        Write-Verbose "Environment variable detected.`n$(Get-ChildItem Env:OPENAI_* | Out-String)"

        switch ($PSCmdlet.ParameterSetName) {
            "default" {
                $api_key = if ($api_key) { $api_key } else { $env:OPENAI_API_KEY }
                $engine = if ($engine) { $engine } else { if ($env:OPENAI_CHAT_ENGINE) { $env:OPENAI_CHAT_ENGINE }else { "gpt-3.5-turbo" } }
                $endpoint = if ($endpoint) { $endpoint } else { "https://api.openai.com/v1/chat/completions" }
            }
            "azure" {
                $api_key = if ($api_key) { $api_key } else { Get-FirstNonNullItemInArray("OPENAI_API_KEY_AZURE_$environment", "OPENAI_API_KEY_AZURE") }
                $engine = if ($engine) { $engine } else { Get-FirstNonNullItemInArray("OPENAI_CHAT_ENGINE_AZURE_$environment", "OPENAI_CHAT_ENGINE_AZURE") }
                $endpoint = if ($endpoint) { $endpoint } else { "{0}openai/deployments/$engine/chat/completions?api-version=$api_version" -f (Get-FirstNonNullItemInArray("OPENAI_ENDPOINT_AZURE_$environment", "OPENAI_ENDPOINT_AZURE")) }
            }
            "local" {
                $endpoint = if ($endpoint) { $endpoint }else { "http://localhost:11434/v1/chat/completions" }
                $api_key = if ($api_key) { $api_key } else { "local" }
            }
        }

        Write-Verbose "Parameter parsed. api_key: $api_key, engine: $engine, endpoint: $endpoint"

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

        if (($PSVersionTable['PSVersion'].Major -le 5) -and $stream) {
            # only new powershell support stream
            # Write-Error $resources.powershell_version_unsupported
            # $hasError = $true
            Write-Host "Powershell 5.0 detected, stream mode is not supported. We will use the normal mode."
            $stream = $false
        }

        # if user didn't specify the stream parameter, and current powershell version is greater than 5, then use the stream mode
        if ($PSVersionTable['PSVersion'].Major -gt 5 -and !$stream) {
            Write-Verbose "Powershell 6.0+ detected, stream mode is not specified, we will use the stream mode by default."
            $stream = $true
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
        $telemetries.Add("promptType", $parsedprompt.type)
        $telemetries.Add("promptLib", $parsedprompt.lib)

        # if system is not empty and it is a file, then read the file as the system prompt
        $parsedsystem = Get-PromptContent($system)
        $system = $parsedsystem.content
        $telemetries.Add("systemPromptType", $parsedsystem.type)
        $telemetries.Add("systemPromptLib", $parsedsystem.lib)

        # collect the telemetry data
        Submit-Telemetry -cmdletName $MyInvocation.MyCommand.Name -innovationName $MyInvocation.InvocationName -props $telemetries

        if ($prompt.Length -gt 0) {
            Write-Verbose "Prompt received: $prompt, so it is in prompt mode, not in chat mode."
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
                Body        = @{model = "$engine"; messages = $messages }
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

            Write-Verbose "Prepare the params for Invoke-WebRequest: $($params|ConvertTo-Json -Depth 10)"

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

            #if user specify the outfile, write the response to the file
            if ($outFile) {
                Write-Verbose "Outfile specified, write the response to the file: $outFile"
                $result | Out-File -FilePath $outFile -Encoding utf8
            }
            else {
                Write-Verbose "Outfile not specified, output the response to pipeline"
                Write-Output $result

                # if user does not specify the outfile, copy the response to clipboard
                Set-Clipboard $result
                Write-Host "Copied the response to clipboard." -ForegroundColor Green
            }

        }
        else {
            Write-Verbose "Prompt not received, so it is in chat mode."

            $index = 1; 
            $welcome = "`n{0}`n{1}" -f ($resources.welcome_chatgpt -f $(if ($azure) { " $($resources.azure_version) " } else { "" }), $engine), $resources.shortcuts
    
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
                Write-Verbose "Start a new loop - let's chat!"

                $current = $index++
                $prompt = Read-Host -Prompt "`n[$current] $($resources.prompt)"
                Write-Verbose "Prompt received: $prompt"
    
                if ($prompt -in ("q", "bye")) {
                    Write-Verbose "User pressed $prompt, so we will quit the chat."
                    break
                }
    
                if ($prompt -eq "m") {

                    $os = [System.Environment]::OSVersion.Platform

                    if ($os -notin @([System.PlatformID]::Win32NT, [System.PlatformID]::Win32Windows, [System.PlatformID]::Win32S)) {
                        Write-Host "Multi-line input is not supported on this platform. Please use another platform or use the file mode."
                        continue
                    }

                    Write-Verbose "User pressed m, so we will prompt a window to collect user input in multi-lines mode."
                    $prompt = Read-MultiLineInputBoxDialog -Message $resources.multi_line_prompt -WindowTitle $resources.multi_line_prompt -DefaultText ""

                    Write-Verbose "Prompt received: $prompt"

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
                        Write-Host "File input is not supported on this platform. Please use another platform or use the file input mode."
                        continue
                    }

                    Write-Verbose "User pressed f, so we will prompt a window to collect user input from a file."
    
                    $file = Read-OpenFileDialog -WindowTitle $resources.file_prompt

                    Write-Verbose "File received: $file"
    
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

                Write-Verbose "Prepare the messages: $($messages|ConvertTo-Json -Depth 10)"
    
                $params = @{
                    Uri         = $endpoint
                    Method      = "POST"
                    Body        = @{model = "$engine"; messages = ($systemPrompt + $messages[-5..-1]); stream = if ($stream) { $true }else { $false } } 
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


                Write-Verbose "Prepare the params for Invoke-WebRequest: $($params|ConvertTo-Json -Depth 10)"
    
                try {
    
                    if ($stream) {
                        Write-Verbose "Stream mode detected, so we will use Invoke-WebRequest to stream the response."
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

                        
                        Write-Verbose "Prepared the client"
                                            
                        $task = $client.Send($request)
                        Write-Verbose "Got task result: $task"
    
                        $response = $task.Content.ReadAsStream()
                        $reader = [System.IO.StreamReader]::new($response)
    
                        Write-Verbose "Got task stream response and reader: $response, $reader"
    
                        $result = "" # message from the api
                        Write-Host -ForegroundColor Red "`n[$current] " -NoNewline
    
                        while ($true) {
                            $line = $reader.ReadLine()
                            Write-Verbose "Read line from stream: $line"
    
                            if (($line -eq $null) -or ($line -eq "data: [DONE]")) { break }
    
                            $chunk = ($line -replace "data: ", "" | ConvertFrom-Json).choices.delta.content
                            Write-Host $chunk -NoNewline -ForegroundColor Green
                            Write-Verbose "Chunk received: $chunk"
                            $result += $chunk
    
                            Start-Sleep -Milliseconds 50
                        }
                        $reader.Close()
                        $reader.Dispose()
    
                        $messages += [PSCustomObject]@{
                            role    = "assistant"
                            content = $result
                        }

                        Write-Verbose "Message combined. $($messages|ConvertTo-Json -Depth 10)"
                        Write-Host ""
    
                    }
                    else {

                        Write-Verbose "It is not in stream mode."
                        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                        $response = Invoke-RestMethod @params
                        Write-Verbose "Response received: $($response| ConvertTo-Json -Depth 10)"

                        $stopwatch.Stop()
                        $result = $response.choices[0].message.content
                        $total_tokens = $response.usage.total_tokens
                        $prompt_tokens = $response.usage.prompt_tokens
                        $completion_tokens = $response.usage.completion_tokens
        
                        Write-Verbose "Response parsed to plain text: $result, total_tokens: $total_tokens, prompt_tokens: $prompt_tokens, completion_tokens: $completion_tokens"
        
                        if ($PSVersionTable['PSVersion'].Major -le 5) {

                            Write-Verbose "Powershell 5.0 detected, convert the response to UTF8"

                            $dstEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
                            $srcEncoding = [System.Text.Encoding]::UTF8
                            $result = $srcEncoding.GetString([System.Text.Encoding]::Convert($srcEncoding, $dstEncoding, $srcEncoding.GetBytes($result)))

                            Write-Verbose "Response converted to UTF8: $result"
                        }
        
                        $messages += [PSCustomObject]@{
                            role    = "assistant"
                            content = $result
                        }

                        Write-Verbose "Message combined. $($messages|ConvertTo-Json -Depth 10)"
                
        
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
