function Remove-AssistantResources {
    <#
        .SYNOPSIS
            Remove an OpenAI assistant.
        .DESCRIPTION
            Remove an OpenAI assistant.
        .PARAMETER assistantId
            The ID of the assistant to remove.  
        .PARAMETER apiKey
            The OpenAI API key.
        .PARAMETER endpoint
            The OpenAI API endpoint.  
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [psobject[]]$resources,
        [string]$apiKey = $env:OPENAI_API_KEY,
        [string]$endpoint = $env:OPENAI_API_ENDPOINT
    )

    BEGIN {
        if (-not $apiKey) {
            Write-Error "API Key is required. Please provide the API key using -apiKey parameter or set the OPENAI_API_KEY environment variable."
            return
        }
        if (-not $endpoint) {
            $endpoint = "https://api.openai.com/v1/{1}/{0}"
        }

        $headers = @{
            "Content-Type" = "application/json"
            "OpenAI-Beta"  = "assistants=v2"
        }

        if ($endpoint -match "azure") {
            $headers.Add("api-key", $apiKey)
            $endpoint = $endpoint + "openai/{1}/{0}?api-version=2024-05-01-preview"
        }
        else {
            $headers.Add("Authorization", "Bearer $apiKey")
        }
    }

    PROCESS {

        foreach ($resource in $resources) {
            if ($PSCmdlet.ShouldProcess($resource.id, "Remove")) {
                $id = $resource.id
                $kind = $resource.object + "s"
                $url = $endpoint -f $id, $kind
                Invoke-RestMethod -Uri $url -Headers $headers -Method Delete -ErrorAction SilentlyContinue
            }            
        }

    }
}
