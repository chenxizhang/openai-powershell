function New-ImageGeneration {
    [CmdletBinding()]
    [Alias("dall")][Alias("image")]
    param(
        [parameter(Mandatory = $true)][string]$prompt,
        [string]$api_key,
        [string]$endpoint, 
        [Parameter(ParameterSetName = "Azure")][switch]$azure,
        [int]$n = 1, #for azure, the n can be 1-5, for openai, the n can be 1-10, for dall3, it always be 1
        [int]$size = 2,
        [string]$outfolder = ".",
        [Parameter( ParameterSetName = “Azure”)][string]$environment,
        [switch]$dall3
    )

   
    BEGIN {
        Write-Verbose "Parameter received. api_key: $api_key, endpoint: $endpoint, azure: $azure, n: $n, size: $size"

        Write-Verbose "Enviornment variable detected. OPENAI_API_KEY: $env:OPENAI_API_KEY, OPENAI_API_KEY_AZURE: $env:OPENAI_API_KEY_AZURE,  OPENAI_ENDPOINT: $env:OPENAI_ENDPOINT, OPENAI_ENDPOINT_AZURE: $env:OPENAI_ENDPOINT_AZURE"

        if ($azure) {
            $api_key = if ($api_key) { $api_key } else { Get-FirstNonNullItemInArray("OPENAI_API_KEY_AZURE_$environment", "OPENAI_API_KEY_AZURE") }
            $endpoint = if ($endpoint) { $endpoint } else { "{0}openai/$(if($dall3){"deployments/Dalle3"}else{})/images/generations$(if($dall3){}else{":submit"})?api-version=$(if($dall3){"2023-12-01-preview"} else{"2023-06-01-preview"})" -f (Get-FirstNonNullItemInArray("OPENAI_ENDPOINT_AZURE_$environment", "OPENAI_ENDPOINT_AZURE")) }
        }
        else {
            $api_key = if ($api_key) { $api_key } else { $env:OPENAI_API_KEY }
            $endpoint = if ($endpoint) { $endpoint } else { "https://api.openai.com/v1/images/generations" }
        }

        Write-Verbose "Parameter parsed. api_key: $api_key, endpoint: $endpoint"

        $hasError = $false

        if ((!$azure) -and ((Test-OpenAIConnectivity) -eq $False)) {
            Write-Host $resources.openai_unavaliable -ForegroundColor Red
            $hasError = $true
        }


        if (!$api_key) {
            Write-Host $resources.error_missing_api_key -ForegroundColor Red
            $hasError = $true
        }

        if (!$endpoint) {
            Write-Host $resources.error_missing_endpoint -ForegroundColor Red
            $hasError = $true
        }

        if ($hasError) {
            break
        }
    }

    PROCESS {

        $sizes = @("256x256", "512x512", "1024x1024", "1792x1024", "1024x1792")

        if ($size -gt 4) {
            $size = 2
        }

        $body = @{
            prompt = $prompt
            n      = if ($dall3) { 1 }else { $n }
            size   = $sizes[$size]
            model  = if ($dall3) { "dall-e-3" } else { "dall-e-2" }
        } | ConvertTo-Json -Depth 10


        $headers = @{
            "Content-Type" = "application/json"
        }

        if ($azure) {
            $headers.Add("api-key", $api_key)

            $request = Invoke-WebRequest -Method Post -Uri $endpoint -Headers $headers -Body $body
            Write-Verbose $request


            if ($dall3) {
                $url = ($request | ConvertFrom-Json).data[0].url
                $filename = [System.Guid]::NewGuid().ToString() + ".png"
                $file = [System.IO.Path]::Join($outfolder, $filename)
                Invoke-WebRequest -Uri $url -OutFile $file
                Write-Host "Download completed, please check the folder: $outfolder"

            }
            else {
                <# Action when all if and elseif conditions are false #>
                $location = $request.Headers['operation-location'][0]
                if ($null -eq $location) {
                    Write-Host "Generate fail " -ForegroundColor Red
                    return
                }
                Write-Verbose "Location received: $location"
                while ($true) {
                    $query = Invoke-RestMethod -Uri $location -Headers $headers
                    if ($query.status -eq 'succeeded') {
                        $query.result.data | Select-Object -ExpandProperty url | ForEach-Object {
                            $filename = [System.Guid]::NewGuid().ToString() + ".png"
                            $file = [System.IO.Path]::Join($outfolder, $filename)
                            Write-Verbose "Downloading file: $file"
                            Invoke-WebRequest -Uri $_ -OutFile $file
                        }

                        Write-Host "Download completed, please check the folder: $outfolder"
                        break
                    }
                    else {
                        Start-Sleep -Seconds 1
                    }

                }
            }

        }
        else {
            # call openai api to generate image
            $headers.Add("Authorization", "Bearer $api_key")
            $request = Invoke-RestMethod -Method Post -Uri $endpoint -Headers $headers -Body $body
            $request.data | Select-Object -ExpandProperty url | ForEach-Object {
                $filename = [System.Guid]::NewGuid().ToString() + ".png"
                $file = [System.IO.Path]::Join($outfolder, $filename)
                Write-Verbose "Downloading file: $file"
                Invoke-WebRequest -Uri $_ -OutFile $file
            }

            Write-Host "Download completed, please check the folder: $outfolder"


        }
    }

    END {

    }
}