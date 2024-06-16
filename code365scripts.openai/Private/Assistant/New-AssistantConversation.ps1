function New-AssistantConversation {
    [CmdletBinding()]
    param(
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$assistantId,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT
    )

    # create an new thread
    $thread = New-Thread -apiKey $apiKey -endpoint $endpoint -ErrorAction SilentlyContinue 

    if (-not $thread) {
        Write-Error "Failed to create a new thread."
        return
    }

    while ($true) {
        # read user input until user input q or bye
        $prompt = Read-Host -Prompt "You"
        if ($prompt -eq "q" -or $prompt -eq "bye") {
            break
        }
        # create user message and send it to the assistant
        $userMessage = @{
            role    = "user"
            content = $prompt
        }
        New-ThreadMessage -apiKey $apiKey -endpoint $endpoint -threadId $thread.id -message $userMessage | Out-Null
        # run the thread
        $run = New-ThreadRun -apiKey $apiKey -endpoint $endpoint -threadId $thread.id -assistantId $assistantId
        # get the run result
        $respnose = Get-ThreadMessage -apiKey $apiKey -endpoint $endpoint -threadId $thread.id -runId $run.id

        Write-Host "Assistant:$respnose"
    }
}