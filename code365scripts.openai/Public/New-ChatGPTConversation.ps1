function New-ChatGPTConversation {

    <#
    .SYNOPSIS
        Create a new ChatGPT conversation
    .DESCRIPTION
        Create a new ChatGPT conversation, You can chat with the openai service just like chat with a human.
    .PARAMETER api_key
        Your OpenAI API key, you can also set it in environment variable OPENAI_API_KEY or OPENAI_API_KEY_AZURE if you use Azure OpenAI API.
    .PARAMETER engine
        The engine to use for this request, you can also set it in environment variable OPENAI_CHAT_ENGINE or OPENAI_CHAT_ENGINE_AZURE if you use Azure OpenAI API.
    .PARAMETER endpoint
        The endpoint to use for this request, you can also set it in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_AZURE if you use Azure OpenAI API.
    .PARAMETER azure
        if you use Azure OpenAI API, you can use this switch.
    .PARAMETER system
        The system prompt, this is a string, you can use it to define the role you want it be, for example, "You are a chatbot, please answer the user's question according to the user's language."
    .PARAMETER stream
        If you want to stream the response, you can use this switch. Please note, we only support this feature in new Powershell (6.0+).
    .PARAMETER prompt
        If you want to get result immediately, you can use this parameter to define the prompt. It will not start the chat conversation.
    .PARAMETER config
        The dynamic settings for the API call, it can meet all the requirement for each model. please pass a custom object to this parameter, like @{temperature=1;max_tokens=1024}
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
    .LINK
        https://github.com/chenxizhang/openai-powershell
    #>


    [CmdletBinding()]
    [Alias("chatgpt")][Alias("chat")]
    param(
        [Parameter()][string]$api_key,
        [Parameter()][string]$engine,
        [string]$endpoint, 
        [Parameter(ParameterSetName = "Azure")][switch]$azure,
        [string]$system = "You are a chatbot, please answer the user's question according to the user's language.",
        [string]$prompt = "",
        [switch]$stream,
        [PSCustomObject]$config,
        [Parameter( ParameterSetName = “Azure”)][string]$environment
    )
    BEGIN {

        Write-Verbose "Parameter received`n$($PSBoundParameters | Out-String)"
        Write-Verbose "Environment variable detected.`n$(Get-ChildItem Env:OPENAI_* | Out-String)"

        if ($azure) {
            $api_key = if ($api_key) { $api_key } else { Get-FirstNonNullItemInArray("OPENAI_API_KEY_AZURE_$environment", "OPENAI_API_KEY_AZURE") }
            $engine = if ($engine) { $engine } else { Get-FirstNonNullItemInArray("OPENAI_CHAT_ENGINE_AZURE_$environment", "OPENAI_CHAT_ENGINE_AZURE") }
            $endpoint = if ($endpoint) { $endpoint } else { "{0}openai/deployments/$engine/chat/completions?api-version=2023-03-15-preview" -f (Get-FirstNonNullItemInArray("OPENAI_ENDPOINT_AZURE_$environment", "OPENAI_ENDPOINT_AZURE")) }
        }
        else {
            $api_key = if ($api_key) { $api_key } else { $env:OPENAI_API_KEY }
            $engine = if ($engine) { $engine } else { if ($env:OPENAI_CHAT_ENGINE) { $env:OPENAI_CHAT_ENGINE }else { "gpt-3.5-turbo" } }
            $endpoint = if ($endpoint) { $endpoint } else { "https://api.openai.com/v1/chat/completions" }
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
            Write-Error $resources.powershell_version_unsupported
            $hasError = $true
        }

        if ($hasError) {
            return
        }
    }

    PROCESS {

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


            if ($config) {
                Merge-Hashtable -table1 $params.Body -table2 $config
            }

            $params.Body = ($params.Body | ConvertTo-Json -Depth 10)

            Write-Verbose "Prepare the params for Invoke-WebRequest: $($params|ConvertTo-Json -Depth 10)"

            $response = Invoke-RestMethod @params
            Write-Verbose "Response received: $($response|ConvertTo-Json -Depth 10)"
            $result = $response.choices[0].message.content
            Write-Verbose "Response parsed to plain text: $result"
            Write-Output $result 

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

                $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
                if ($prompt -eq "q") {
                    Write-Verbose "User pressed q, so we will quit the chat."
                    break
                }
    
                if ($prompt -eq "m") {
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

                if ($config) {
                    Merge-Hashtable -table1 $params.Body -table2 $config
                }
                $params.Body = ($params.Body | ConvertTo-Json -Depth 10)


                Write-Verbose "Prepare the params for Invoke-WebRequest: $($params|ConvertTo-Json -Depth 10)"
    
                try {
    
                    if ($stream) {
                        Write-Verbose "Stream mode detected, so we will use Invoke-WebRequest to stream the response."

                        $stopwatch.Stop()
                        Write-Verbose "Stopped watcher"
    
                        $client = New-Object System.Net.Http.HttpClient
                        $body = $params.Body
    
                        Write-Verbose "body: $body"
    
                        $request = [System.Net.Http.HttpRequestMessage]::new()
                        $request.Method = "POST"
                        $request.RequestUri = $params.Uri
                        $request.Content = [System.Net.Http.StringContent]::new(($body), [System.Text.Encoding]::UTF8)
                        $request.Content.Headers.Clear()
                        if ($azure) {
                            $request.Content.Headers.Add("api-key", $api_key)
                        }
                        else {
                            $request.Content.Headers.Add("Authorization", "Bearer $api_key")
                        }
                        $request.Content.Headers.Add("Content-Type", "application/json;charset=utf-8")
                        
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
                        $stream.Close()
    
                        $messages += [PSCustomObject]@{
                            role    = "assistant"
                            content = $result
                        }

                        Write-Verbose "Message combined. $($messages|ConvertTo-Json -Depth 10)"
    
                        
                        Write-Host ""
    
                    }
                    else {

                        Write-Verbose "It is not in stream mode."

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
                    Write-Host $_.ErrorDetails -ForegroundColor Red
                }
            }
        }


    }

}
