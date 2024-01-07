function Submit-Prompt {
    <#
    .SYNOPSIS
        Submit a prompt to the OpenAI prompt library.
    .DESCRIPTION
        Submit a prompt to the OpenAI prompt library.
    .PARAMETER description
        The description of the prompt.
    .PARAMETER content
        The content of the prompt. if the content is a file path, the content will be loaded from the file.
    .PARAMETER name
        The name of the user.
        We will try to get the name from the environment variable openai.powershell.user.name if the name parameter is not set.
        We will ask the user to input the name if the name is not set and then save the name to the environment variable openai.powershell.user.name.
    .PARAMETER email
        The email of the user.
        We will try to get the email from the environment variable openai.powershell.user.email if the email parameter is not set.
        We will ask the user to input the email if the email is not set and then save the email to the environment variable openai.powershell.user.email.
    .EXAMPLE
        Submit-Prompt -description "test" -content "test" -name "test" -email "test"
    .INPUTS
        None
    .OUTPUTS
        None
    .LINK
        https://github.com/chenxizhang/openai-powershell
    #>


    [CmdletBinding()]
    [Alias("submit")]
    param (
        [Parameter(Mandatory = $true)][string]$description,
        [Parameter(Mandatory = $true)]
        [Alias("file")]
        [string]$content,
        [Parameter()][string]$name = [System.Environment]::GetEnvironmentVariable("openai.powershell.user.name", "User"),
        [Parameter()][string]$email = [System.Environment]::GetEnvironmentVariable("openai.powershell.user.email", "User")
    )

    Write-Verbose "description: $description, content: $content, name: $name, email: $email"

    # collect the telemetry data
    Submit-Telemetry -cmdletName $MyInvocation.MyCommand.Name -innovationName $MyInvocation.InvocationName

    # if the file parameter is set, load the file as the content
    if ($PSBoundParameters.ContainsKey("content") -and (Test-Path $content)) {
        $content = Get-Content $content -Raw -Encoding UTF8
    }
    else {
        throw "The file path is invalid."
    }

    # if the name parameter is not set, we will try to get it from environment variable
    if (-not $name) {
        while (-not $name) {
            $name = Read-Host "Please input your name"
            if ($name) {
                [System.Environment]::SetEnvironmentVariable("openai.powershell.user.name", $name, "User")
            }
        }
    }

    # if the email parameter is not set, we will try to get it from environment variable
    if (-not $email) {
        #if email is empty, ask user to input, until get a vaild email
        while (-not $email) {
            $email = Read-Host "Please input your email"
            if ($email) {
                [System.Environment]::SetEnvironmentVariable("openai.powershell.user.email", $email, "User")
            }
        }
    }



    # if the content is empty or null, throw an exception
    if (-not $content) {
        throw "content is not set, you can set it by the file parameter or the content parameter."
    }

    try {
    
        $result = Invoke-RestMethod -Uri "https://aresfuncs.azurewebsites.net/api/github_submit_prompt" -Method Post -Body (@{
                message = $description
                content = $content
                name    = $name
                email   = $email
        
            } | ConvertTo-Json) -ContentType "application/json"
        

        Write-Output "Your prompt is submitted and under review, thanks for your contribution, the url is $result."

    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Error $.ErrorDetails
    }
}