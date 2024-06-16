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

    [Assistant]$assistants
    [Vector_store]$vector_stores
    [File]$files
    [Thread]$threads

    OpenAIClient([string]$apiKey, [string]$baseUri, [string]$model, [string]$apiVersion) {
        $this.apikey = $apiKey
        $this.baseUri = $baseUri
        $this.model = $model
        $this.apiVersion = $apiVersion

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

        $this.assistants = [Assistant]::new($this)
        $this.vector_stores = [Vector_store]::new($this)
        $this.files = [File]::new($this)
        $this.threads = [Thread]::new($this)
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
    [string]$urifragment

    AssistantResource([OpenAIClient]$client, [string]$urifragment) {
        $this.Client = $client
        $this.urifragment = $urifragment
    }
    [psobject[]]list() {
        return $this.Client.web($this.urifragment).data
    }
    
    [psobject]get([string]$id) {
        return $this.Client.web("$($this.urifragment)/$id")
    }

    [psobject]delete([string]$id) {
        return $this.Client.web("$($this.urifragment)/$id", "DELETE", @{})
    }

    [psobject]create([hashtable]$body) {
        return $this.Client.web("$($this.urifragment)", "POST", $body)
    }
}

class Assistant:AssistantResource {
    Assistant([OpenAIClient]$client): base($client, "assistants") {}

    <#
        .SYNOPSIS
            Create a new assistant
        .DESCRIPTION
            Create a new assistant with the given name, model, and instructions.
        .PARAMETER body
            The body must contain 'name', 'model', and 'instructions' keys. But it can also contain 'config', 'vector_store_ids', 'functions', and 'files' keys.
    #>
    [psobject]create([hashtable]$body) {
        if ($body.name -and $body.model -and $body.instructions) {
            $vector_store_ids = $body.vector_store_ids
            $functions = $body.functions
            $files = $body.files
            $config = $body.config

            if ($files) {
                # upload the files and create new vector store
                $file_ids = $this.Client.files.create(@{ "files" = $files }) | Select-Object -ExpandProperty id
                $body.Add("tools", @(
                        @{
                            "type" = "file_search"
                        }))
                        
                $body.Add("tool_resources", @{
                        "file_search" = @{
                            "vector_stores" = @(@{
                                    file_ids = @($file_ids)
                                })
                        }
                    })
            }

            if ($vector_store_ids -and $vector_store_ids.Count -gt 0) {
                $body.Add("tool_resources", @{
                        "file_search" = @{
                            "vector_store_ids" = @($vector_store_ids)
                        }
                    })
                
                $body.Add("tools", @(
                        @{
                            "type" = "file_search"
                        }))
            }

            if ($functions -and $functions.Count -gt 0) {
        
                if ($null -eq $body.tools) {
                    $body.Add("tools", @())
                }

                $functions | ForEach-Object {
                    $func = Get-FunctionJson -functionName $_
                    $body.tools += $func
                }
            }

            if ($config) {
                Merge-Hashtable -table1 $body -table2 $config
            }

            # remove files, vector_store_ids, functions, and config from the body
            $body.Remove("files")
            $body.Remove("vector_store_ids")
            $body.Remove("functions")
            $body.Remove("config")
            
            return $this.Client.web("$($this.urifragment)", "POST", $body)
        }
        
        throw "The body must contain 'name' and 'model', 'instructions' keys."
    }
}
class Vector_store:AssistantResource {
    Vector_store([OpenAIClient]$client): base($client, "vector_stores") {}

    [psobject]create([hashtable]$body) {
        <#
            .SYNOPSIS
                Create a new vector store   
            .DESCRIPTION
                Create a new vector store with the given name, file_ids, and days_to_expire.
            .PARAMETER body
                The body must contain 'name', 'file_ids', and 'days_to_expire' keys.
        #>

        # check if the body contains name, file_ids, and days_to_expire
        if ($body.name -and $body.file_ids -and $body.days_to_expire) {
            #replace the days_to_expire with expires_after
            $body.expires_after = @{
                "days"   = $body.days_to_expire
                "anchor" = "last_active_at"
            }
            $body.Remove("days_to_expire")
            return $this.Client.web("$($this.urifragment)", "POST", $body)
        }
        
        throw "The body must contain 'name', 'file_ids', and 'days_to_expire' keys."
    }
}
class File:AssistantResource {
    File([OpenAIClient]$client): base($client, "files") {}

    [psobject]create([hashtable]$body) {
        if ($body.files) {
            $files = $body.files
            return $this.upload($files)
        }

        throw "The body must contain 'files' key."
    }


    [System.Management.Automation.HiddenAttribute()]
    [psobject]upload([string[]]$fullname) {
        $url = "{0}{1}" -f $this.Client.baseUri, $this.urifragment
        if ($this.Client.baseUri -match "azure") {
            $url = "{0}?api-version=2024-05-01-preview" -f $url
        }

        $result = @()

        foreach ($file in $fullname) {
            Write-Host "process file: $file"
            # Define the purpose (e.g., "assistants", "vision", "batch", or "fine-tune")
            $purpose = "assistants"
            # Create a new web request
            $request = [System.Net.WebRequest]::Create($url)
            $request.Method = "POST"

            # add the item of headers to request.Headers
            $this.Client.headers.GetEnumerator() | Where-Object {
                $_.Key -ne "Content-Type"
            }  | ForEach-Object {
                $request.Headers.Add($_.Key, $_.Value)
            }

            # Create a boundary for the multipart/form-data content
            $boundary = [System.Guid]::NewGuid().ToString()

            # Set the content type and boundary
            $request.ContentType = "multipart/form-data; boundary=$boundary"

            $name = "{0}-{1}" -f (Get-FileHash $file).Hash, (Split-Path $file -Leaf)

            # Create the request body
            $body = @"
--$boundary
Content-Disposition: form-data; name="file"; filename="$name"
Content-Type: application/octet-stream

$(Get-Content -Path $file)

--$boundary
Content-Disposition: form-data; name="purpose"

$purpose
--$boundary--
"@


            # Convert the body to bytes
            $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)

            # Set the content length
            $request.ContentLength = $bodyBytes.Length

            # Get the request stream and write the body
            $requestStream = $request.GetRequestStream()
            $requestStream.Write($bodyBytes, 0, $bodyBytes.Length)
            $requestStream.Close()

            # Get the response
            $response = $request.GetResponse()

            # Read the response content
            $responseStream = $response.GetResponseStream()
            $reader = [System.IO.StreamReader]::new($responseStream)
            $responseContent = $reader.ReadToEnd()
            $reader.Close()

            # Print the response content
            $result += ($responseContent | ConvertFrom-Json)
        }
        return $result
    }

  
}
class Thread:AssistantResource {
    Thread([OpenAIClient]$client): base($client, "threads") {}
}