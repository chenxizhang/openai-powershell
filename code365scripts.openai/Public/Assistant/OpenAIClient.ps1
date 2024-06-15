class OpenAIClient {
    [System.Management.Automation.HiddenAttribute()]
    [string]$apikey
    [System.Management.Automation.HiddenAttribute()]
    [string]$baseUri
    [System.Management.Automation.HiddenAttribute()]
    [string]$model
    [System.Management.Automation.HiddenAttribute()]
    [hashtable]$headers
    [System.Management.Automation.HiddenAttribute()]
    [string]$apiVersion

    [Assistant]$assistant

    OpenAIClient([string]$apiKey, [string]$baseUri, [string]$model, [string]$apiVersion = "2024-05-01-preview") {
        $this.apikey = $apiKey
        $this.baseUri = $baseUri
        $this.model = $model
        $this.apiVersion = $apiVersion

        $this.init()
    }

    OpenAIClient() {
        $this.apikey = $env:OPENAI_API_KEY
        $this.baseUri = if ($env:OPENAI_API_ENDPOINT) { $env:OPENAI_API_ENDPOINT } else { "https://api.openai.com/v1/" }
        $this.model = if ($env:OPENAI_API_MODEL) { $env:OPENAI_API_MODEL } else { "gpt-4o" }
        $this.apiVersion = if ($env:OPENAI_API_VERSION) { $env:OPENAI_API_VERSION } else { "2024-05-01-preview" }

        $this.init()
    }

    [System.Management.Automation.HiddenAttribute()]
    [void]init() {
        # check the apikey, endpoint and model, if empty, then return error
        $this.headers = @{
            "Content-Type" = "application/json"
            "OpenAI-Beta"  = "assistants=v2"
        }

        if ($this.baseUri -match "azure") {
            $this.headers.Add("api-key", $this.apikey)
            $this.baseUri = $this.baseUri + "openai/"
        }
        else {
            $this.headers.Add("Authorization", "Bearer $($this.apikey)")
            $this.apiVersion = ""
        }

        $this.assistant = [Assistant]::new($this)
    }

    [psobject]web(
        [string]$urifragment, 
        [string]$method = "GET", 
        [psobject]$body = $null) {
        $url = "{0}{1}" -f $this.baseUri, $urifragment
        if ($this.apiVersion -ne "") {
            $url = "{0}?api-version={1}" -f $url, $this.apiVersion
        }

        if ($method -eq "GET" -or $null -eq $body) {
            return Invoke-RestMethod -Method $method -Uri $url -Headers $this.headers
        }
        else {
            return Invoke-RestMethod -Method $method -Uri $url -Headers $this.headers -Body ($body | ConvertTo-Json)
        }
    }

    [psobject]web($urifragment) {
        return $this.web($urifragment, "GET", @{})
    }
}


class AssistantResource {
    [System.Management.Automation.HiddenAttribute()]
    [OpenAIClient]$Client
    [System.Management.Automation.HiddenAttribute()]
    [string]$urlfragment

    AssistantResource([OpenAIClient]$client) {
        $this.Client = $client
    }

    AssistantResource() {
        $this.Client = [OpenAIClient]::new()
    }

    [psobject[]]list() {
        return $this.Client.web($this.urlfragment).data
    }
    
    [psobject]get([string]$id) {
        return $this.Client.web("$($this.urlfragment)/$id")
    }

    [psobject]delete([string]$id) {
        # remove all the assistants
        return $this.Client.web("$($this.urlfragment)/$id", "DELETE", @{})
    }

    [psobject]create([string]$name, [string]$model, [string]$instructions) {
        $body = @{
            "name"         = $name
            "model"        = $model
            "instructions" = $instructions
        }

        return $this.Client.web("$($this.urlfragment)", "POST", $body)
    }
}

class Assistant : AssistantResource {
    [System.Management.Automation.HiddenAttribute()]
    [string]$urlfragment = "assistants"

    [psobject]create([string]$name, [string]$model, [string]$instructions) {
        $body = @{
            "name"         = $name
            "model"        = $model
            "instructions" = $instructions
        }

        return $this.Client.web("$($this.urlfragment)", "POST", $body)
    }
}
