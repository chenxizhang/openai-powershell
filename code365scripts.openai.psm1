# 导入本地化数据
Import-LocalizedData -FileName "resources.psd1" -BindingVariable "resources"

# 用当前日期生成的日志文件
$script:folder = "$env:APPDATA\code365scripts.openai"
if (!(Test-Path $script:folder)) {
    New-Item -ItemType Directory -Path $script:folder
}
$script:logfile = "$script:folder\OpenAI_{0}.log" -f (Get-Date -Format "yyyyMMdd")

# 检查版本是否需要更新
Start-Job -ScriptBlock {
    $folder = $args[0]
    $file = "$folder\update.txt"

    if (($env:CHECK_UPDATE_CODE365SCRIPTS -eq 0) -or (Test-Path $file)) {
        return
    }
    $module = Find-Module code365scripts.openai
    $version = $module.Version
    $current = (Get-Module code365scripts.openai -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1).Version
    if ($version -ne $current) {
        Set-Content $file -Value $module.Description -Force
    }
    else {
        if (Test-Path $file ) {
            Remove-Item $file -Force
        }
    }

}  -ArgumentList $script:folder

# 用于记录日志
function Write-Log([array]$message) {
    $message = "{0}`t{1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), ($message -join "`t")
    Add-Content $script:logfile -Value $message
}

function Test-Update() {
    if (($env:CHECK_UPDATE_CODE365SCRIPTS -eq 0) -or (!(Test-Path "$script:folder\update.txt"))) {
        return
    };

    $description = Get-Content "$script:folder\update.txt"

    $confirm = Read-Host ($resources.update_prompt -f $description)
    if ($confirm -eq "y") {
        if ($PSVersionTable['PSVersion'].Major -eq 5) {
            Update-Module code365scripts.openai -Force
        }
        else {
            Update-Module code365scripts.openai -Scope CurrentUser -Force
        }
        
        Remove-Item "$script:folder\update.txt" -Force

        # Import-Module code365scripts.openai
        break
    }

}

# 检查 openai.com 是否可以访问，使用iwr 的 HEAD 方法测试，如果返回 200 则可以访问
function Test-OpenAIConnectivity {
    # 设置全局错误处理
    $ErrorActionPreference = 'SilentlyContinue'
    # 增加超时时间 5秒 
    $response = Invoke-WebRequest -Uri "https://platform.openai.com/docs/" -Method Head -TimeoutSec 5
    # 恢复全局错误处理
    $ErrorActionPreference = 'Continue'
    return $response.StatusCode -eq 200
}


function New-OpenAICompletion {
    <#
    .EXTERNALHELP code365scripts.openai-help.xml
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

        Test-Update # 检查更新

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

        # 如果不是azure，并且 openai.com 无法访问，则报错
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
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        try {
            $response = Invoke-RestMethod @params
            $stopwatch.Stop()
            $total_tokens = $response.usage.total_tokens
            $prompt_tokens = $response.usage.prompt_tokens
            $completion_tokens = $response.usage.completion_tokens

            if ($PSVersionTable['PSVersion'].Major -eq 5) {
                $dstEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
                $srcEncoding = [System.Text.Encoding]::UTF8

                $response.choices | ForEach-Object {
                    $_.text = $srcEncoding.GetString([System.Text.Encoding]::Convert($srcEncoding, $dstEncoding, $srcEncoding.GetBytes($_.text)))
                }
            }
        
            Write-Log -message $stopwatch.ElapsedMilliseconds, $total_tokens, $prompt_tokens, $completion_tokens
            Write-Output $response
            
        }
        catch {
            Write-Host ($_.ErrorDetails | ConvertFrom-Json).error.message -ForegroundColor Red
        }
    }

}

function New-OpenAIConversation {
    <#
    .EXTERNALHELP code365scripts.openai-help.xml
    #>


    [CmdletBinding()]
    [Alias("oai")][Alias("gpt")]
    param(
        [Parameter()][string]$api_key,
        [Parameter()][string]$engine,
        [Parameter()][string]$endpoint,
        [Parameter()][int]$max_tokens = 1024,
        [Parameter()][double]$temperature = 1,
        [Parameter()][switch]$azure
    )

    BEGIN {

        Test-Update # 检查更新



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
        
        $index = 1; # 用来保存问答的序号

        $welcome = "`n{0}`n{1}" -f ($resources.welcome -f $(if ($azure) { " $($resources.azure_version) " } else { "" }), $engine), $resources.shortcuts
        
        Write-Host $welcome -ForegroundColor Yellow

        while ($true) {
            $current = $index++
            $prompt = Read-Host -Prompt "`n[$current] $($resources.prompt)"
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

            if ($prompt -eq "q") {
                break
            }

            if ($prompt -eq "m") {
                # 这是用户想要输入多行文本
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
                # 这是用户想要从文件输入
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

            $params = @{
                Uri         = $endpoint
                Method      = "POST"
                Body        = @{model = "$engine"; prompt = "$prompt"; max_tokens = $max_tokens; temperature = $temperature } | ConvertTo-Json
                Headers     = if ($azure) { @{"api-key" = "$api_key" } } else { @{"Authorization" = "Bearer $api_key" } }
                ContentType = "application/json;charset=utf-8"
            }

            try {
                $response = Invoke-RestMethod @params
                $stopwatch.Stop()
                $result = $response.choices[0].text
                $total_tokens = $response.usage.total_tokens
                $prompt_tokens = $response.usage.prompt_tokens
                $completion_tokens = $response.usage.completion_tokens
                if ($PSVersionTable['PSVersion'].Major -eq 5) {
                    $dstEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
                    $srcEncoding = [System.Text.Encoding]::UTF8
                    $result = $srcEncoding.GetString([System.Text.Encoding]::Convert($srcEncoding, $dstEncoding, $srcEncoding.GetBytes($result)))
                }
        
                Write-Host -ForegroundColor Red ("`n[$current] $($resources.response)" -f $total_tokens, $prompt_tokens, $completion_tokens )
                Write-Host $result -ForegroundColor Green

                Write-Log -message $stopwatch.ElapsedMilliseconds, $total_tokens, $prompt_tokens, $completion_tokens
            }
            catch {
                <#Do this if a terminating exception happens#>
                Write-Host ($_.ErrorDetails | ConvertFrom-Json).error.message -ForegroundColor Red
            }

        }

    }
}


function New-ChatGPTConversation {
    [CmdletBinding()]
    [Alias("chatgpt")][Alias("chat")]
    param(
        [Parameter()][string]$api_key,
        [Parameter()][string]$engine,
        [string]$endpoint, # 这是openai的服务基地址，如果不指定，则使用默认地址
        [switch]$azure,
        [string]$system = "你是一个ChatGPT聊天机器人,请根据用户的语言回答。"
    )
    BEGIN {

        Test-Update # 检查更新

        if ($azure) {
            $api_key = if ($api_key) { $api_key } else { if ($env:OPENAI_API_KEY_Azure) { $env:OPENAI_API_KEY_Azure } else { $env:OPENAI_API_KEY } }
            $engine = if ($engine) { $engine } else { if ($env:OPENAI_CHAT_ENGINE_Azure) { $env:OPENAI_CHAT_ENGINE_Azure }else { "gpt-3.5-turbo" } }
            $endpoint = if ($endpoint) { $endpoint } else { "{0}openai/deployments/$engine/chat/completions?api-version=2023-03-15-preview" -f $env:OPENAI_ENDPOINT_AZURE }
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

        if ($hasError) {
            break
        }
    }

    PROCESS {
        $index = 1; # 用来保存问答的序号
        $welcome = "`n{0}`n{1}" -f ($resources.welcome_chatgpt -f $(if ($azure) { " $($resources.azure_version) " } else { "" }), $engine), $resources.shortcuts

        Write-Host $welcome -ForegroundColor Yellow

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
                # 这是用户想要输入多行文本
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
                # 这是用户想要从文件输入
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
                Body        = @{model = "$engine"; messages = ($systemPrompt + $messages[-5..-1]) } | ConvertTo-Json
                Headers     = if ($azure) { @{"api-key" = "$api_key" } } else { @{"Authorization" = "Bearer $api_key" } }
                ContentType = "application/json;charset=utf-8"
            }

            try {
                $response = Invoke-RestMethod @params
                $stopwatch.Stop()
                $result = $response.choices[0].message.content
                $total_tokens = $response.usage.total_tokens
                $prompt_tokens = $response.usage.prompt_tokens
                $completion_tokens = $response.usage.completion_tokens


                if ($PSVersionTable['PSVersion'].Major -eq 5) {
                    $dstEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
                    $srcEncoding = [System.Text.Encoding]::UTF8
                    $result = $srcEncoding.GetString([System.Text.Encoding]::Convert($srcEncoding, $dstEncoding, $srcEncoding.GetBytes($result)))
                }

                $messages += [PSCustomObject]@{
                    role    = "assistant"
                    content = $result
                }
        

                Write-Host -ForegroundColor Red ("`n[$current] $($resources.response)" -f $total_tokens, $prompt_tokens, $completion_tokens )
                Write-Host $result -ForegroundColor Green

                Write-Log -message $stopwatch.ElapsedMilliseconds, $total_tokens, $prompt_tokens, $completion_tokens
            }
            catch {
                Write-Host $_.ErrorDetails -ForegroundColor Red
            }
        }
    }

}

function Get-OpenAILogs([switch]$all) {
    # .EXTERNALHELP code365scripts.openai-help.xml

    Test-Update # 检查更新
    
    if ($all) {
        Get-ChildItem -Path $script:folder | Get-Content | ConvertFrom-Csv -Delimiter "`t" -Header Time, Duration, TotalTokens, PromptTokens, CompletionTokens | Format-Table
    }
    else {
        Get-Content $script:logfile | ConvertFrom-Csv -Delimiter "`t" -Header Time, Duration, TotalTokens, PromptTokens, CompletionTokens | Format-Table
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