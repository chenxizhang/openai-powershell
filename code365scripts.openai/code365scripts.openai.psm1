# import the localized resources
Import-LocalizedData -FileName "resources.psd1" -BindingVariable "resources"

# check if the openai.com is avaliable, if so, return true, otherwise return false
function Test-OpenAIConnectivity {
    $ErrorActionPreference = 'SilentlyContinue'
    $response = Invoke-WebRequest -Uri "https://platform.openai.com/docs/" -Method Head -TimeoutSec 2
    $ErrorActionPreference = 'Continue'
    return $response.StatusCode -eq 200
}


function New-OpenAICompletion {
    <#
    .SYNOPSIS
        Get completion from OpenAI API
    .DESCRIPTION
        Get completion from OpenAI API, you can use this cmdlet to get completion from OpenAI API.The cmdlet accept pipeline input. You can also assign the prompt, api_key, engine, endpoint, max_tokens, temperature, n parameters.
    .PARAMETER prompt
        The prompt to get completion from OpenAI API
    .PARAMETER api_key
        The api_key to get completion from OpenAI API. You can also set api_key in environment variable OPENAI_API_KEY or OPENAI_API_KEY_Azure (if you want to use Azure OpenAI Service API).
    .PARAMETER engine
        The engine to get completion from OpenAI API. You can also set engine in environment variable OPENAI_ENGINE or OPENAI_ENGINE_Azure (if you want to use Azure OpenAI Service API).
    .PARAMETER endpoint
        The endpoint to get completion from OpenAI API. You can also set endpoint in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_Azure (if you want to use Azure OpenAI Service API).
    .PARAMETER max_tokens
        The max_tokens to get completion from OpenAI API. The default value is 1024.
    .PARAMETER temperature
        The temperature to get completion from OpenAI API. The default value is 1, which means most creatively.
    .PARAMETER n
        If you want to get multiple completion, you can use this parameter. The default value is 1.
    .PARAMETER azure
        If you want to use Azure OpenAI API, you can use this switch.
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
    .LINK
        https://github.com/chenxizhang/openai-powershell
    .INPUTS
        System.String, you can pass one or more string to the cmdlet, and we will get the completion for you.
    #>

    [CmdletBinding()]
    [Alias("noc")]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$prompt,
        [Parameter()][string]$api_key,
        [Parameter()][string]$engine,
        [Parameter()][string]$endpoint,
        [Parameter()][int]$max_tokens = 1024,
        [Parameter()][double]$temperature = 1,
        [Parameter()][int]$n = 1,
        [Parameter()][switch]$azure
    )

    BEGIN {
        if ($azure) {
            $api_key = if ($api_key) { $api_key } else { if ($env:OPENAI_API_KEY_Azure) { $env:OPENAI_API_KEY_Azure } else { $env:OPENAI_API_KEY } }
            $engine = if ($engine) { $engine } else { $env:OPENAI_ENGINE_Azure }
            $endpoint = "{0}openai/deployments/{1}/completions?api-version=2022-12-01" -f $(if ($endpoint) { $endpoint }else { $env:OPENAI_ENDPOINT_Azure }), $engine
        }
        else {
            $api_key = if ($api_key) { $api_key } else { $env:OPENAI_API_KEY }
            $engine = if ($engine) { $engine } else { if ($env:OPENAI_ENGINE) { $env:OPENAI_ENGINE }else { "text-davinci-003" } }
            $endpoint = if ($endpoint) { $endpoint } else { if ($env:OPENAI_ENDPOINT) { $env:OPENAI_ENDPOINT }else { "https://api.openai.com/v1/completions" } }
        }

        

        $hasError = $false

        if ((!$azure) -and ((Test-OpenAIConnectivity) -eq $False)) {
            Write-Host $resources.openai_unavaliable -ForegroundColor Red
            $hasError = $true
        }


        if (!$api_key) {
            Write-Host $resources.error_missing_api_key -ForegroundColor Red
            $hasError = $true
        }

        if (!$engine) {
            Write-Host $resources.error_missing_engine -ForegroundColor Red
            $hasError = $true
        }

        if (!$endpoint) {
            Write-Host $resources.error_missing_endpoint -ForegroundColor Red
            $hasError = $true
        }

        if ($hasError) {
            break
        }
    }

    PROCESS {
    
        $params = @{
            Uri         = $endpoint
            Method      = "POST"
            Body        = @{
                model       = "$engine"
                prompt      = "$prompt"
                max_tokens  = $max_tokens
                temperature = $temperature
                n           = $n
            } | ConvertTo-Json
            Headers     = if ($azure) { @{"api-key" = "$api_key" } } else { @{"Authorization" = "Bearer $api_key" } }
            ContentType = "application/json;charset=utf-8"
        }


        try {
            $response = Invoke-RestMethod @params

            if ($PSVersionTable['PSVersion'].Major -eq 5) {
                $dstEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
                $srcEncoding = [System.Text.Encoding]::UTF8

                $response.choices | ForEach-Object {
                    $_.text = $srcEncoding.GetString([System.Text.Encoding]::Convert($srcEncoding, $dstEncoding, $srcEncoding.GetBytes($_.text)))
                }
            }
        
            # parse the response to plain text
            $response = $response.choices.text

            # write the response to console
            Write-Output $response
            # write the response to clipboard
            Set-Clipboard $response
            
        }
        catch {
            Write-Host ($_.ErrorDetails | ConvertFrom-Json).error.message -ForegroundColor Red
        }
    }

}

function New-ChatGPTConversation {

    <#
    .SYNOPSIS
        Create a new ChatGPT conversation
    .DESCRIPTION
        Create a new ChatGPT conversation, You can chat with the openai service just like chat with a human.
    .PARAMETER api_key
        Your OpenAI API key, you can also set it in environment variable OPENAI_API_KEY or OPENAI_API_KEY_Azure if you use Azure OpenAI API.
    .PARAMETER engine
        The engine to use for this request, you can also set it in environment variable OPENAI_ENGINE or OPENAI_ENGINE_Azure if you use Azure OpenAI API.
    .PARAMETER endpoint
        The endpoint to use for this request, you can also set it in environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_Azure if you use Azure OpenAI API.
    .PARAMETER azure
        if you use Azure OpenAI API, you can use this switch.
    .PARAMETER system
        The system prompt, this is a string, you can use it to define the role you want it be, for example, "You are a chatbot, please answer the user's question according to the user's language."
    .PARAMETER stream
        If you want to stream the response, you can use this switch. Please note, we only support this feature in new Powershell (6.0+).
    .PARAMETER prompt
        If you want to get result immediately, you can use this parameter to define the prompt. It will not start the chat conversation.
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
        [switch]$azure,
        [string]$system = "You are a chatbot, please answer the user's question according to the user's language.",
        [string]$prompt = "",
        [switch]$stream
    )
    BEGIN {
        if ($azure) {
            $api_key = if ($api_key) { $api_key } else { if ($env:OPENAI_API_KEY_Azure) { $env:OPENAI_API_KEY_Azure } else { $env:OPENAI_API_KEY } }
            $engine = if ($engine) { $engine } else { if ($env:OPENAI_CHAT_ENGINE_Azure) { $env:OPENAI_CHAT_ENGINE_Azure }else { "gpt-3.5-turbo" } }
            $endpoint = if ($endpoint) { $endpoint } else { "{0}openai/deployments/$engine/chat/completions?api-version=2023-03-15-preview" -f $env:OPENAI_ENDPOINT_Azure }
        }
        else {
            $api_key = if ($api_key) { $api_key } else { $env:OPENAI_API_KEY }
            $engine = if ($engine) { $engine } else { if ($env:OPENAI_CHAT_ENGINE) { $env:OPENAI_CHAT_ENGINE }else { "gpt-3.5-turbo" } }
            $endpoint = if ($endpoint) { $endpoint } else { "https://api.openai.com/v1/chat/completions" }
        }

        $hasError = $false

        if ((!$azure) -and ((Test-OpenAIConnectivity) -eq $False)) {
            Write-Host $resources.openai_unavaliable -ForegroundColor Red
            $hasError = $true
        }


        if (!$api_key) {
            Write-Host $resources.error_missing_api_key -ForegroundColor Red
            $hasError = $true
        }

        if (!$engine) {
            Write-Host $resources.error_missing_engine -ForegroundColor Red
            $hasError = $true
        }

        if (($PSVersionTable['PSVersion'].Major -le 5) -and $stream) {
            # only new powershell support stream
            Write-Host $resources.powershell_version_unsupported -ForegroundColor Red
            $hasError = $true
        }

        if ($hasError) {
            break
        }
    }

    PROCESS {

        if ($prompt.Length -gt 0) {
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
                Body        = @{model = "$engine"; messages = $messages } | ConvertTo-Json
                Headers     = if ($azure) { @{"api-key" = "$api_key" } } else { @{"Authorization" = "Bearer $api_key" } }
                ContentType = "application/json;charset=utf-8"
            }

            $response = Invoke-RestMethod @params
            $result = $response.choices[0].message.content
            Write-Output $result 

        }
        else {
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
            
            while ($true) {
                $current = $index++
                $prompt = Read-Host -Prompt "`n[$current] $($resources.prompt)"
                $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
                if ($prompt -eq "q") {
                    break
                }
    
                if ($prompt -eq "m") {
    
                    $prompt = Read-MultiLineInputBoxDialog -Message $resources.multi_line_prompt -WindowTitle $resources.multi_line_prompt -DefaultText ""
                    if ($null -eq $prompt) {
                        Write-Host $resources.cancel_button_message
                        continue
                    }
                    else {
                        Write-Host "$($resources.multi_line_message)`n$prompt"
                    }
                }
    
                if ($prompt -eq "f") {
    
                    $file = Read-OpenFileDialog -WindowTitle $resources.file_prompt
    
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
    
                $params = @{
                    Uri         = $endpoint
                    Method      = "POST"
                    Body        = @{model = "$engine"; messages = ($systemPrompt + $messages[-5..-1]); stream = if ($stream) { $true }else { $false } } | ConvertTo-Json
                    Headers     = if ($azure) { @{"api-key" = "$api_key" } } else { @{"Authorization" = "Bearer $api_key" } }
                    ContentType = "application/json;charset=utf-8"
                }
    
                try {
    
                    if ($stream) {
                        $stopwatch.Stop()
                        Write-Verbose "Stopped watcher"
    
                        $client = New-Object System.Net.Http.HttpClient
                        $body = $params.Body
    
                        Write-Verbose $body
    
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
    
                        Write-Verbose "Got task stream"
    
                        $result = "" # message from the api
                        Write-Host -ForegroundColor Red "`n[$current] " -NoNewline
    
                        while ($true) {
                            $line = $reader.ReadLine()
                            Write-Verbose $line
    
                            if (($line -eq $null) -or ($line -eq "data: [DONE]")) { break }
    
                            $chunk = ($line -replace "data: ", "" | ConvertFrom-Json).choices.delta.content
                            Write-Host $chunk -NoNewline -ForegroundColor Green
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
    
                        Set-Clipboard $result
                        Write-Host ""
    
                    }
                    else {
                        $response = Invoke-RestMethod @params
                        $stopwatch.Stop()
                        $result = $response.choices[0].message.content
                        $total_tokens = $response.usage.total_tokens
                        $prompt_tokens = $response.usage.prompt_tokens
                        $completion_tokens = $response.usage.completion_tokens
        
        
                        if ($PSVersionTable['PSVersion'].Major -le 5) {
                            $dstEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
                            $srcEncoding = [System.Text.Encoding]::UTF8
                            $result = $srcEncoding.GetString([System.Text.Encoding]::Convert($srcEncoding, $dstEncoding, $srcEncoding.GetBytes($result)))
                        }
        
                        $messages += [PSCustomObject]@{
                            role    = "assistant"
                            content = $result
                        }
                
        
                        Write-Host -ForegroundColor Red ("`n[$current] $($resources.response)" -f $total_tokens, $prompt_tokens, $completion_tokens )
                        Set-Clipboard $result
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


function Read-OpenFileDialog([string]$WindowTitle, [string]$InitialDirectory, [string]$Filter = "All files (*.*)|*.*", [switch]$AllowMultiSelect) {
    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = $WindowTitle
    if (![string]::IsNullOrWhiteSpace($InitialDirectory)) { $openFileDialog.InitialDirectory = $InitialDirectory }
    $openFileDialog.Filter = $Filter
    if ($AllowMultiSelect) { $openFileDialog.MultiSelect = $true }
    $openFileDialog.ShowHelp = $true    # Without this line the ShowDialog() function may hang depending on system configuration and running from console vs. ISE.
    $openFileDialog.ShowDialog() > $null
    if ($AllowMultiSelect) { return $openFileDialog.Filenames } else { return $openFileDialog.Filename }
}

function Read-MultiLineInputBoxDialog([string]$Message, [string]$WindowTitle, [string]$DefaultText) {
    <#
    .SYNOPSIS
    Prompts the user with a multi-line input box and returns the text they enter, or null if they cancelled the prompt.

    .DESCRIPTION
    Prompts the user with a multi-line input box and returns the text they enter, or null if they cancelled the prompt.

    .PARAMETER Message
    The message to display to the user explaining what text we are asking them to enter.

    .PARAMETER WindowTitle
    The text to display on the prompt window's title.

    .PARAMETER DefaultText
    The default text to show in the input box.

    .EXAMPLE
    $userText = Read-MultiLineInputDialog "Input some text please:" "Get User's Input"

    Shows how to create a simple prompt to get mutli-line input from a user.

    .EXAMPLE
    # Setup the default multi-line address to fill the input box with.
    $defaultAddress = @'
    John Doe
    123 St.
    Some Town, SK, Canada
    A1B 2C3
    '@

    $address = Read-MultiLineInputDialog "Please enter your full address, including name, street, city, and postal code:" "Get User's Address" $defaultAddress
    if ($address -eq $null)
    {
        Write-Error "You pressed the Cancel button on the multi-line input box."
    }

    Prompts the user for their address and stores it in a variable, pre-filling the input box with a default multi-line address.
    If the user pressed the Cancel button an error is written to the console.

    .EXAMPLE
    $inputText = Read-MultiLineInputDialog -Message "If you have a really long message you can break it apart`nover two lines with the powershell newline character:" -WindowTitle "Window Title" -DefaultText "Default text for the input box."

    Shows how to break the second parameter (Message) up onto two lines using the powershell newline character (`n).
    If you break the message up into more than two lines the extra lines will be hidden behind or show ontop of the TextBox.

    .NOTES
    Name: Show-MultiLineInputDialog
    Author: Daniel Schroeder (originally based on the code shown at http://technet.microsoft.com/en-us/library/ff730941.aspx)
    Version: 1.0
#>
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms

    # Create the Label.
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Size(10, 10)
    $label.Size = New-Object System.Drawing.Size(280, 20)
    $label.AutoSize = $true
    $label.Text = $Message

    # Create the TextBox used to capture the user's text.
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Size(10, 40)
    $textBox.Size = New-Object System.Drawing.Size(575, 200)
    $textBox.AcceptsReturn = $true
    $textBox.AcceptsTab = $false
    $textBox.Multiline = $true
    $textBox.ScrollBars = 'Both'
    $textBox.Text = $DefaultText

    # Create the OK button.
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Size(415, 250)
    $okButton.Size = New-Object System.Drawing.Size(75, 25)
    $okButton.Text = $resources.dialog_okbutton_text
    $okButton.Add_Click({ $form.Tag = $textBox.Text; $form.Close() })

    # Create the Cancel button.
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Size(510, 250)
    $cancelButton.Size = New-Object System.Drawing.Size(75, 25)
    $cancelButton.Text = $resources.dialog_cancelbutton_text
    $cancelButton.Add_Click({ $form.Tag = $null; $form.Close() })

    # Create the form.
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $WindowTitle
    $form.Size = New-Object System.Drawing.Size(610, 320)
    $form.FormBorderStyle = 'FixedSingle'
    $form.StartPosition = "CenterScreen"
    $form.AutoSizeMode = 'GrowAndShrink'
    $form.Topmost = $True
    $form.AcceptButton = $okButton
    $form.CancelButton = $cancelButton
    $form.ShowInTaskbar = $true

    # Add all of the controls to the form.
    $form.Controls.Add($label)
    $form.Controls.Add($textBox)
    $form.Controls.Add($okButton)
    $form.Controls.Add($cancelButton)

    # Initialize and show the form.
    $form.Add_Shown({ $form.Activate() })
    $form.ShowDialog() > $null  # Trash the text of the button that was clicked.

    # Return the text that the user entered.
    return $form.Tag
}