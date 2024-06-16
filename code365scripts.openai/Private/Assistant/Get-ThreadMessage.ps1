function Get-ThreadMessage {
    [CmdletBinding()]
    param(
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [string]$threadId,
        [string]$runId
    )


    # check the run status until it is completed
    $run = Get-ThreadRun -apiKey $apiKey -endpoint $endpoint -threadId $threadId -runId $runId
    while ($run.status -ne "completed") {
        Write-Verbose ("Run status: {0}" -f $run.status)

        if($run.status -eq "failed") {
            Write-Host ("Run failed: {0}" -f $run.last_error.message) -ForegroundColor Red
            return
        }

        # The status of the run, which can be either queued, in_progress, requires_action, cancelling, cancelled, failed, completed, incomplete, or expired.

        if ($run.status -eq "requires_action") {
            $tool_calls = $run.required_action.submit_tool_outputs.tool_calls
            if ($tool_calls -and $tool_calls.Count -gt 0) {
                $tool_output = @()

                foreach ($tool_call in $tool_calls) {
                    $call_id = $tool_call.id
                    $function = $tool_call.function
                    $function_args = $function.arguments | ConvertFrom-Json
                    $exp = "{0} {1}" -f $function.name, (($function_args.PSObject.Properties | ForEach-Object {
                                "-{0} '{1}'" -f $_.Name, $_.Value
                            }) -join " ")
                    Write-Verbose "calling function with arguments: $exp"
                    $call_response = Invoke-Expression $exp

                    $tool_output += @{
                        tool_call_id = $call_id
                        output       = $call_response
                    }
                }

                Submit-ToolCallOutput -apiKey $apiKey -endpoint $endpoint -threadId $threadId -runId $runId -data $tool_output
            }

        }
        
        Start-Sleep -Seconds 1
        $run = Get-ThreadRun -apiKey $apiKey -endpoint $endpoint -threadId $threadId -runId $runId
    }

    if (-not $apiKey) {
        Write-Error "API Key is required. Please provide the API key using -apiKey parameter or set the OPENAI_API_KEY environment variable."
        return
    }
    if (-not $endpoint) {
        $endpoint = "https://api.openai.com/v1/threads/${threadId}/messages?limit=1"
    }

    $headers = @{
        "Content-Type" = "application/json"
        "OpenAI-Beta"  = "assistants=v2"
    }

    if ($endpoint -match "azure") {
        $headers.Add("api-key", $apiKey)
        $endpoint = $endpoint + "openai/threads/${threadId}/messages?api-version=2024-05-01-preview&limit=1"
    }
    else {
        $headers.Add("Authorization", "Bearer $apiKey")
    }

    # check the run status, make sure it is completed
    $result = (Invoke-RestMethod -Uri $endpoint -Headers $headers -Method Get).data | Select-Object id, role, content

    $result.content.text.value
}


function Submit-ToolCallOutput {
    [CmdletBinding()]
    param(
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [string]$threadId,
        [string]$runId,
        [psobject]$data
    )
        
    if (-not $apiKey) {
        Write-Error "API Key is required. Please provide the API key using -apiKey parameter or set the OPENAI_API_KEY environment variable."
        return
    }
    if (-not $endpoint) {
        $endpoint = "https://api.openai.com/v1/threads/${threadId}/runs/${runId}/submit_tool_outputs"
    }

    $headers = @{
        "Content-Type" = "application/json"
        "OpenAI-Beta"  = "assistants=v2"
    }

    if ($endpoint -match "azure") {
        $headers.Add("api-key", $apiKey)
        $endpoint = $endpoint + "openai/threads/${threadId}/runs/${runId}/submit_tool_outputs?api-version=2024-05-01-preview"
    }
    else {
        $headers.Add("Authorization", "Bearer $apiKey")
    }

    Invoke-RestMethod -Uri $endpoint -Headers $headers -Method Post -Body (@{tool_outputs = @($data) } | ConvertTo-Json) 
}


function Get-ThreadRun {
    [CmdletBinding()]
    param(
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT,
        [string]$threadId,
        [string]$runId
    )

    if (-not $apiKey) {
        Write-Error "API Key is required. Please provide the API key using -apiKey parameter or set the OPENAI_API_KEY environment variable."
        return
    }
    if (-not $endpoint) {
        $endpoint = "https://api.openai.com/v1/threads/${threadId}/runs/${runId}"
    }

    $headers = @{
        "Content-Type" = "application/json"
        "OpenAI-Beta"  = "assistants=v2"
    }

    if ($endpoint -match "azure") {
        $headers.Add("api-key", $apiKey)
        $endpoint = $endpoint + "openai/threads/${threadId}/runs/${runId}?api-version=2024-05-01-preview"
    }
    else {
        $headers.Add("Authorization", "Bearer $apiKey")
    }
    $result = Invoke-RestMethod -Uri $endpoint -Headers $headers -Method Get 
    return $result
}


