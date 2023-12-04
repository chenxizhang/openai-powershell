Import-Module ".\code365scripts.openai\code365scripts.openai.psd1" -Force

# prepare test data
New-Variable -Name "prompt" -Value "能否用小学生听得懂的方式讲解一下量子力学?" -Option ReadOnly -Scope Script -Force
New-Variable -Name "imageprompt" -Value "A photo of a cat sitting on a couch." -Option ReadOnly -Scope Script -Force
New-Variable -Name "outputFolder" -Value ([System.IO.Path]::GetTempPath()) -Scope Script -Force

$systemPromptFile = New-TemporaryFile
$promptFile = New-TemporaryFile
$dallFile = New-TemporaryFile

"Please use multiple languages (简体中文,English,French) to answer my question." | Out-File $systemPromptFile.FullName -Encoding utf8
"What's the capital of China?" | Out-File $promptFile.FullName -Encoding utf8
"A photo of a cat sitting on a couch. The above photo is a photo of a cat sitting on a couch. The above photo is a photo of a cat sitting on a couch." | Out-File $dallFile.FullName -Encoding utf8


# define the test cases, please note you need to configure all the environment variables before running the test cases, below is an example, which will use OpenAI service and Azure OpenAI service (2 different environments). The SWEDEN environment is a custom environment which has the dall-e-3 model.

$cmds = @'
    noc "$prompt"
    New-OpenAICompletion "$prompt" -max_tokens 100
    noc "$prompt" -temperature 0.5
    New-OpenAICompletion "$prompt" -azure
    noc -azure $promptFile
    noc "$prompt" -azure -max_tokens 200
    noc "$prompt" -azure -temperature 0.2
    noc "$prompt" -azure -n 2
    New-OpenAICompletion "$prompt" -azure -environment "SWEDEN"
    noc "$prompt" -azure -environment "xxx"
    chat -prompt "$prompt"
    chat -azure -prompt $promptFile
    chat -azure -prompt $promptFile | Out-File -Encoding utf8 -FilePath (New-TemporaryFile).FullName
    chat -azure -system $systemPromptFile -prompt $promptFile
    chat -prompt "$prompt" -azure
    chat -prompt "$prompt" -azure -config @{max_tokens=100; temperature=0.5}
    chat -prompt "$prompt" -azure -environment "SWEDEN"
    image -prompt "$imageprompt" -size 0 -outfolder $outputFolder
    image -prompt $promptFile -size 0 -outfolder $outputFolder
    image -prompt "$imageprompt" -size 0 -azure -outfolder $outputFolder
    image -prompt "$imageprompt" -size 0 -azure -outfolder $outputFolder -n 2
    image -prompt "$imageprompt" -size 2 -azure -dall3 -environment "SWEDEN" -outfolder $outputFolder
    chat
    chat -stream
'@


# run the test cases
$cmds.Split("`n") | ForEach-Object { 
    Write-Host "Run command:`n$($ExecutionContext.InvokeCommand.ExpandString($_))" -ForegroundColor Green
    Invoke-Expression $_
    Write-Host "---------------------------------"
}