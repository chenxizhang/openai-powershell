function Get-AzureAPIVersion {    
    # ignore error handle
    $ErrorActionPreference = "SilentlyContinue"

    # check the folder in github https://github.com/Azure/azure-rest-api-specs/blob/main/specification/cognitiveservices/data-plane/AzureOpenAI/inference/stable and list the folders to get the latest version, use the Github rest API to do this.

    try {
        $url = "https://api.github.com/repos/Azure/azure-rest-api-specs/contents/specification/cognitiveservices/data-plane/AzureOpenAI/inference/stable"
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{Accept = "application/vnd.github.v3+json" } -ConnectionTimeoutSeconds 2

        # get a list of the folder name, which is the version, use the regex to get the yyyy-MM-dd in all the names, and get the latest one

        $response | ForEach-Object {
            # capture the yyyy-MM-dd part in the name, for example , "2024-01-01-preview" will be captured as "2024-01-01", "2023-01-01" will be captured as "2023-01-01".
            $version = $_.Name -match "\d{4}-\d{2}-\d{2}"
            return $(if ($version) {
                    @{
                        Version = $_.Name
                        Date    = $matches[0]
                    } 
                }
                else { 
                    @{
                        Version = $_.Name
                        Date    = "1900-01-01"
                    }
                })
        } | Where-Object { $_ -ne "" } | Sort-Object -Property Date -Descending | Select-Object -First 1 -ExpandProperty Version
    }
    catch {
        return "2024-02-01"
    }

    # restor the error handle
    $ErrorActionPreference = "Continue"

} 