Import-Module ".\code365scripts.openai\code365scripts.openai.psd1" -Force

New-Variable -Name "prompt" -Value "Which city is the capital of China?" -Option ReadOnly -Scope Script -Force
New-Variable -Name "imageprompt" -Value "A photo of a cat sitting on a couch." -Option ReadOnly -Scope Script -Force

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
    chat -prompt "$prompt" -azure -config @{max_tokens=100; temperature=0.5}
    chat -prompt "$prompt" -azure -environment "SWEDEN"
    chat
    chat -stream
    image -prompt "$imageprompt" -size 0 -outfolder "c:\temp"
    image -prompt "$imageprompt" -size 0 -azure -outfolder "c:\temp"
    image -prompt "$imageprompt" -size 2 -azure -dall3 -environment "SWEDEN" -outfolder "c:\temp"
'@

$cmds.Split("`n") | ForEach-Object { 
    Write-Host "Run command:`n$($ExecutionContext.InvokeCommand.ExpandString($_))" -ForegroundColor Green
    Invoke-Expression $_
    Write-Host "---------------------------------"

}