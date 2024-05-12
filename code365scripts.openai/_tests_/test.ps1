Import-Module  (Join-Path -Path "." -ChildPath "code365scripts.openai\code365scripts.openai.psd1") -Force

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
    chat -prompt $prompt
    gpt "what's the capital of china?"
    gpt -prompt $prompt -api_key $env:KIMI_API_KEY -endpoint kimi -model moonshot-v1-32k
    chat
    chat -system "帮我翻译文字从中文到英文"
    chat -functions get_current_weather
    chat -functions get_current_weather,query_database
'@


# run the test cases
$cmds.Split("`n") | ForEach-Object { 
    Write-Host "Run command:`n$($ExecutionContext.InvokeCommand.ExpandString($_))" -ForegroundColor Green
    Invoke-Expression $_
    Write-Host "---------------------------------"
}