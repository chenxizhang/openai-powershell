Import-Module ".\code365scripts.openai\code365scripts.openai.psd1" -Force

$prompt = "what is the capital of China?"
$imageprompt = "A photo of a cat sitting on a couch."

$cmds = @'
    noc "$prompt"
    New-OpenAICompletion "$prompt" -max_tokens 100
    noc "$prompt" -temperature 0.5
    New-OpenAICompletion "$prompt" -azure
    noc "$prompt" -azure -max_tokens 200
    noc "$prompt" -azure -temperature 0.2
    noc "$prompt" -azure -n 2
    New-OpenAICompletion "$prompt" -azure -environment "SWEDEN"
    noc "$prompt" -azure -environment "xxx"
    chat -prompt "$prompt"
    chat -prompt "$prompt" -azure
    chat -prompt "$prompt" -azure -environment "SWEDEN"
    chat
    chat -stream
    image -prompt "$imageprompt" -size 0
    image -prompt "$imageprompt" -size 0 -azure
    image -prompt "$imageprompt" -size 2 -azure -dall3 -environment "SWEDEN"
'@

$cmds.Split("`n") | ForEach-Object { 
    Write-Host "Run command:`n$($ExecutionContext.InvokeCommand.ExpandString($_))" -ForegroundColor Green
    Invoke-Expression $_
    Write-Host "---------------------------------"

}