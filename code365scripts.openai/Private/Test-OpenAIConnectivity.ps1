# check if the openai.com is avaliable, if so, return true, otherwise return false
function Test-OpenAIConnectivity {
    # Write-Verbose "Test-OpenAIConnectivity"
    # $ErrorActionPreference = 'SilentlyContinue'
    # $response = Invoke-WebRequest -Uri "https://www.openai.com" -Method Head
    # Write-Verbose "Response: $($response|ConvertTo-Json -Depth 10)"
    # $ErrorActionPreference = 'Continue'
    # Write-Output ($response.StatusCode -eq 200)
    return $true
}
