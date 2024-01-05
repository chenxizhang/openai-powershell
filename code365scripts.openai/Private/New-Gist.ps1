# create gist on github, or gitee
function New-Gist {
    [CmdletBinding()]
    param (
        [Parameter()][string]$access_token,
        [Parameter(Mandatory = $true)][string]$description,
        [Parameter(Mandatory = $true)]
        [string]$content,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("github", "gitee")]
        [string]$provider = "github"
    )

    # if the access_token is not set, we will try to get it from environment variable
    if (-not $access_token) {
        $access_token = Get-FirstNonNullItemInArray("${provider}_gist_access_token", "gist_access_token", "${provider}key")
    }

    if (-not $access_token) {
        throw "access_token is not set, you can set it by one of following environment variables: ${provider}_gist_access_token, gist_access_token, ${provider}key. You can create the access_token from $(if($provider -eq 'github'){'https://github.com/settings/tokens'}else{'https://gitee.com/profile/personal_access_tokens'})."
    }

    $filename = "openai_powershell_prompt_library_$(Get-Date -Format 'yyyyMMddHHmmss').md"

    switch ($provider) {
        "github" { 
            $url = "https://api.github.com/gists"
            $body = @{
                description = $description
                public      = $true
                files       = @{
                    "$filename" = @{
                        content = $content
                    }
                }
            }
            $headers = @{
                Accept        = "application/vnd.github+json"
                Authorization = "Bearer $access_token"
            }

            $result = Invoke-RestMethod -Uri $url -Method Post -Body ($body | ConvertTo-Json) -Headers $headers -ContentType "application/json"

            Write-Output $result.url
        }
        "gitee" { 
            $url = "https://gitee.com/api/v5/gists"
            $body = @{
                access_token = $access_token
                description  = $description
                public       = $true
                files        = @{
                    "$filename" = @{
                        content = $content
                    }
                }
            }

            $result = Invoke-RestMethod -Uri $url -Method Post -Body ($body | ConvertTo-Json) -ContentType "application/json"
            Write-Output $result.url
        }
    }
}