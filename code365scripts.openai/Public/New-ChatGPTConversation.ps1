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
    .PARAMETER functions
        This is s super powerful feature to support the function_call of OpenAI, you can specify the function name(s) and it will be automatically called when the assistant needs it. You can find all the avaliable functions definition here (https://raw.githubusercontent.com/chenxizhang/openai-powershell/master/code365scripts.openai/Private/functions.json).
    .PARAMETER environment
        If you have multiple environment to use, you can specify the environment name here, and then define the environment in the profile.json file. You can also use "profile" or "env" as the alias.
    .PARAMETER env_config
        The profile.json file path, the default value is "$env:USERPROFILE/.openai-powershell/profile.json".
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

    [CmdletBinding()]
    [Alias("chatgpt")][Alias("chat")]
    param(
        [Alias("token", "access_token", "accesstoken", "key", "apikey")]
        [string]$api_key,
        [Alias("engine", "deployment")]
        [string]$model,
        [string]$endpoint,
        [string]$system = "You are a chatbot, please answer the user's question according to the user's language.",
        [Alias("settings")]
        [PSCustomObject]$config, 
        [Alias("out")]   
        [string]$outFile,
        [switch]$json,
        [Alias("variables")]
        [PSCustomObject]$context,
        [PSCustomObject]$headers,
        [string[]]$functions,
        [Alias("profile", "env")]
        [string]$environment,
        [string]$env_config = "$env:USERPROFILE/.openai-powershell/profile.json"
    )
    BEGIN {

        Write-Verbose ($resources.verbose_parameters_received -f ($PSBoundParameters | Out-String))
        Write-Verbose ($resources.verbose_environment_received -f (Get-ChildItem Env:OPENAI_API_* | Out-String))

        if ($environment) {
            if ($env_config -match "\.json$" -and (Test-Path $env_config -PathType Leaf)) {
                $env_config = Get-Content $env_config -Raw -Encoding UTF8 
            }

            $parsed_env_config = ($env_config | ConvertFrom-Json | ConvertTo-Hashtable).profiles | Where-Object { $_.name -eq $environment } | Select-Object -First 1

            if ($parsed_env_config) {
                if ($parsed_env_config.api_key -and (!$api_key)) { $api_key = $parsed_env_config.api_key }
                if ($parsed_env_config.model -and (!$model)) { $model = $parsed_env_config.model }
                if ($parsed_env_config.endpoint -and (!$endpoint)) { $endpoint = $parsed_env_config.endpoint }
                if ($parsed_env_config.config) { 
                    if ($config) {
                        Merge-Hashtable -table1 $config -table2 $parsed_env_config.config
                    }
                    else {
                        $config = $parsed_env_config.config
                    }
                }
                if ($parsed_env_config.headers) {

                    # foreach all the headers, if the value contains {{model}} then replace it with the model, and if the value contains {{guid}} then replace it with a new guid
                    $keys = @($parsed_env_config.headers.Keys)
                    $keys | ForEach-Object {
                        $parsed_env_config.headers[$_] = $parsed_env_config.headers[$_] -replace "{{model}}", $model
                        $parsed_env_config.headers[$_] = $parsed_env_config.headers[$_] -replace "{{guid}}", [guid]::NewGuid().ToString()
                    }

                    if ($headers) {
                        Merge-Hashtable -table1 $headers -table2 $parsed_env_config.headers
                    }
                    else {
                        $headers = $parsed_env_config.headers
                    }
                }

                if ($parsed_env_config.auth -and ($parsed_env_config.auth.type -eq "aad") -and $parsed_env_config.auth.aad) {

                    Confirm-DependencyModule -ModuleName "MSAL.ps"

                    $aad = $parsed_env_config.auth.aad
                    if ($aad.clientsecret) {
                        $aad.clientsecret = ConvertTo-SecureString $aad.clientsecret -AsPlainText -Force
                    }
                    $accesstoken = (Get-MsalToken @aad).AccessToken
                    $api_key = $accesstoken
                }

                # if user provide the functions definition, then merge the functions definition to the config
                if ($parsed_env_config.functions) {
                    if ($functions) {
                        $functions += $parsed_env_config.functions
                    }
                    else {
                        $functions = $parsed_env_config.functions
                    }
                }
            }
        }


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

            Write-Verbose  ($tools | ConvertTo-Json -Depth 10)

            if ($tools.Count -gt 0) {
                if ($null -eq $config) {
                    $config = @{}
                }
                $config["tools"] = $tools
                $config["tool_choice"] = "auto"
            }
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



        # if system is not empty and it is a file, then read the file as the system prompt
        $parsedsystem = Get-PromptContent -prompt $system -context $context
        $system = $parsedsystem.content

        $telemetries.Add("systemPromptType", $parsedsystem.type)
        $telemetries.Add("systemPromptLib", $parsedsystem.lib)

        # collect the telemetry data
        Submit-Telemetry -cmdletName $MyInvocation.MyCommand.Name -innovationName $MyInvocation.InvocationName -props $telemetries

    }

    PROCESS {

        Receive-Job -Name "check_openai_UpdateNotification" -ErrorAction SilentlyContinue

        Write-Verbose ($resources.verbose_chat_mode)

        # old version of powershell doesn't support the stream mode, functions are not supported in the stream mode
        $stream = $PSVersionTable['PSVersion'].Major -gt 5

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

        $messages += $systemPrompt

        Write-Verbose "$($systemPrompt|ConvertTo-Json -Depth 10)"
            
        while ($true) {
            Write-Verbose ($resources.verbose_chat_let_chat)

            $current = $index++
            $prompt = Read-Host -Prompt "`n[$current] $($resources.prompt)"

            Write-Verbose ($resources.verbose_prompt_received -f $prompt)
    
            if ($prompt -in ("q", "bye")) {
                Write-Verbose ($resources.verbose_chat_q_message -f $prompt)
                break
            }

            if ($prompt.StartsWith("save")) {
                if ($prompt -match "^save\s+(\S+)((?:\s+/override))?$") {
                    $profileName = $matches[1]
                    $override = $null -ne $matches[2]
                    $profile_to_save = @{
                        name     = $profileName
                        api_key  = $api_key
                        model    = $model
                        endpoint = $endpoint
                        system   = $system
                    }

                    if ($config) {
                        $profile_to_save.config = $config
                    }
                    if ($headers) {
                        $profile_to_save.headers = $headers
                    }
                    if ($functions) {
                        $profile_to_save.functions = $functions
                    }

                    # check the profile file in $userprofile directory, if not exist, then create it
                    $profileFile = Join-Path $env:USERPROFILE ".openai-powershell/profile.json"
                    if (!(Test-Path $profileFile)) {
                        New-Item -Path $profileFile -ItemType File -Force | Out-Null
                        @{profiles = @($profile_to_save) } | ConvertTo-Json -Depth 10 | Set-Content -Path $profileFile -Encoding UTF8
                    }
                    else {
                        # load the profile file, and check if the profile name is already exist, if exist and not override, then return error message, if exist and override, then override the profile. if not exist, then add the profile to the profile file
                        $existing_profiles = (Get-Content $profileFile -Raw -Encoding UTF8 | ConvertFrom-Json).profiles
                        $existing_profile = $existing_profiles | Where-Object { $_.name -eq $profileName }

                        if ($existing_profile) {
                            if ($override) {
                                # update the existing_profile with the new profile_to_save
                                $existing_profile = $profile_to_save
                                @{profiles = @($existing_profiles) } | ConvertTo-Json -Depth 10 | Set-Content -Path $profileFile -Encoding UTF8
                                Write-Host "[$current] The profile '$profileName' is overridden successfully." -ForegroundColor Green
                            }
                            else {
                                Write-Host "[$current] The profile '$profileName' is already exist, if you want to override it, please add the '/override' switch in the end of your command" -ForegroundColor Red
                            }
                        }
                        else {
                            $existing_profiles += $profile_to_save
                            @{profiles = @($existing_profiles) } | ConvertTo-Json -Depth 10 | Set-Content -Path $profileFile -Encoding UTF8
                            Write-Host "[$current] The profile '$profileName' is saved successfully." -ForegroundColor Green
                        }
                    }

                }
                else {
                    Write-Host "[$current] You want to save the profile, but the syntext is incorrect. Please try 'save your-profile-name', if you want to override the exiting profile, please add the '/override' switch in the end of your command" -ForegroundColor Red 
                }

                continue
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

            Write-Host -ForegroundColor ("blue", "red", "Green", "yellow", "gray", "black", "white" | Get-Random) ("`r$($resources.thinking) {0}" -f ("." * (Get-Random -Maximum 10 -Minimum 3))) -NoNewline
    
            $messages += [PSCustomObject]@{
                role    = "user"
                content = $prompt
            }

            Write-Verbose ($resources.verbose_prepare_messages -f ($messages | ConvertTo-Json -Depth 10))

            if ($messages.Count -gt 10) {
                $messages = @($messages[0]) + $messages[-9..-1]
            }
    
            $body = @{model = "$model"; messages = $messages; stream = $stream } 
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
    
            try {
    
                if ($stream) {
                    Write-Verbose ($resources.verbose_chat_stream_mode)
                    $callapi = Invoke-StreamWebRequest -uri $params.Uri -body $params.Body -header $header
                    # if the status of callapi is not ok, then write the error message to host and continue
                    if ($callapi.status -ne "ok") {
                        Write-Host "`r[$current] $($callapi.message)" -NoNewline -ForegroundColor Red
                        Write-Host ""
                        continue
                    }
                    
                    # otherwise, get the read of the result
                    $reader = $callapi.reader
                    # check if tools_call is null, if not, then execute the tools_call
                    $line = $reader.ReadLine()
                    $delta = ($line -replace "data: ", "" | ConvertFrom-Json).choices.delta


                    while ($delta -and ($null -eq $delta.content)) {
                        $tool_calls = @()

                        while ($true) {
                            if ($delta.tool_calls) {
                                $temp = $delta.tool_calls
                                if ($temp.id -and $temp.function) {
                                    $tool_calls += @([pscustomobject]@{
                                            index    = $temp.index
                                            id       = $temp.id
                                            type     = "function"
                                            function = @{
                                                name      = $temp.function.name
                                                arguments = $temp.function.arguments
                                            }
                                        })

                                }
                                elseif ($temp.function) {
                                    $tool_calls | Where-Object { $_.index -eq $temp.index } | ForEach-Object {
                                        $_.function.arguments += $temp.function.arguments
                                    }
                                }
                            }

                            $line = $reader.ReadLine()
                            if ($line -eq "data: [DONE]") { break }
                            $delta = ($line -replace "data: ", "" | ConvertFrom-Json).choices.delta
                        }

                        # execute functions
                        $messages += [pscustomobject]@{
                            role       = "assistant"
                            content    = ""
                            tool_calls = @($tool_calls)
                        }
                            
                        foreach ($tool in $tool_calls) {
                            Write-Host ("`r$($resources.function_call): $($tool.function.name)" + (" " * 50)) -NoNewline
                            $function_args = $tool.function.arguments | ConvertFrom-Json
                            $tool_response = Invoke-Expression ("{0} {1}" -f $tool.function.name, (
                                    $function_args.PSObject.Properties | ForEach-Object {
                                        "-{0} {1}" -f $_.Name, $_.Value
                                    }
                                ) -join " ")

                            $messages += @{
                                role         = "tool"
                                name         = $tool.function.name
                                tool_call_id = $tool.id
                                content      = $tool_response
                            }
                        }

                        $body.messages = $messages
                        $params.Body = ($body | ConvertTo-Json -Depth 10)
                        $callapi = Invoke-StreamWebRequest -uri $params.Uri -body $params.Body -header $header

                        if ($callapi.status -ne "ok") {
                            Write-Host "`r[$current] $($callapi.message)" -NoNewline -ForegroundColor Red
                            Write-Host ""
                            break
                        }

                        $reader = $callapi.reader
                        $line = $reader.ReadLine()
                        $delta = ($line -replace "data: ", "" | ConvertFrom-Json).choices.delta
                    }

                    # if the callapi status is not ok, then write the error message to host and continue
                    if ($callapi.status -ne "ok") {
                        continue
                    }

                    Write-Host ("`r" + (" " * 50)) -ForegroundColor Green -NoNewline
                    Write-Host "`r[$current] " -NoNewline -ForegroundColor Red
                    $result = $delta.content
                    Write-Host $result -NoNewline -ForegroundColor Green
                    while ($true) {
                        $line = $reader.ReadLine()
                        if ($line -eq "data: [DONE]") { break }
                        $chunk = ($line -replace "data: ", "" | ConvertFrom-Json).choices.delta.content
                        Write-Host $chunk -NoNewline -ForegroundColor Green
                        $result += $chunk
                        Start-Sleep -Milliseconds 5
                    }

                    Write-Host ""    
                    $messages += [PSCustomObject]@{
                        role    = "assistant"
                        content = $result
                    }

                    Write-Verbose ($resources.verbose_chat_message_combined -f ($messages | ConvertTo-Json -Depth 10))
                        
                }
                else {

                    Write-Verbose ($resources.verbose_chat_not_stream_mode)
                    $response = Invoke-UniWebRequest $params

                    Write-Verbose ($resources.verbose_chat_response_received -f ($response | ConvertTo-Json -Depth 10))

                    # TODO #175 将工具作为外部模块加载，而不是直接调用
                    while ($response.choices -and $response.choices[0].message.tool_calls) {
                        # add the assistant message 
                        $this_message = $response.choices[0].message
                        # $body.messages += $this_message
                        $tool_calls = $this_message.tool_calls

                        $messages += [pscustomobject]@{
                            role       = "assistant"
                            content    = ""
                            tool_calls = @($tool_calls)
                        }
                
                        foreach ($tool in $tool_calls) {
                            Write-Host ("`r$($resources.function_call): $($tool.function.name)" + (" " * 50)) -NoNewline
                            $function_args = $tool.function.arguments | ConvertFrom-Json
                            $tool_response = Invoke-Expression ("{0} {1}" -f $tool.function.name, (
                                    $function_args.PSObject.Properties | ForEach-Object {
                                        "-{0} {1}" -f $_.Name, $_.Value
                                    }
                                ) -join " ")

                            $messages += @{
                                role         = "tool"
                                name         = $tool.function.name
                                tool_call_id = $tool.id
                                content      = $tool_response
                            }
                        }
                        
                        $body.messages = $messages
                        $params.Body = ($body | ConvertTo-Json -Depth 10)
                        Write-Verbose $params.Body

                        $response = Invoke-UniWebRequest $params
                    }

                    $result = $response.choices[0].message.content
                    $messages += [PSCustomObject]@{
                        role    = "assistant"
                        content = $result
                    }
                    Write-Host ("`r" + (" " * 50)) -ForegroundColor Green -NoNewline
                    Write-Host "`r[$current] $result" -ForegroundColor Green 
                    Write-Verbose ($resources.verbose_chat_message_combined -f ($messages | ConvertTo-Json -Depth 10))
                }
            }
            catch {
                Write-Error ($_.Exception.Message)
            }
        }
    }

}
