function New-ImageGeneration {
    <#
    .SYNOPSIS
    Generate image from prompt
    .DESCRIPTION
    Generate image from prompt, use dall-e-2 model by default, dall-e-3 model can be used by specify -dall3 switch
    .OUTPUTS
    System.String[], the file(s) path of the generated image.
    .PARAMETER prompt
    The prompt to generate image, this is required. If you want to use a file as prompt, you can specify the file path here.
    .PARAMETER api_key
    The api key to access openai api, if not specified, the api key will be read from environment variable OPENAI_API_KEY. if you use azure openai service, you can specify the api key by environment variable OPENAI_API_KEY_AZURE or OPENAI_API_KEY_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_API_KEY_AZURE_PROD, OPENAI_API_KEY_AZURE_TEST, etc. 
    .PARAMETER endpoint
    The endpoint to access openai api, if not specified, the endpoint will be read from environment variable OPENAI_ENDPOINT. if you use azure openai service, you can specify the endpoint by environment variable OPENAI_ENDPOINT_AZURE or OPENAI_ENDPOINT_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_ENDPOINT_AZURE_DEV, OPENAI_ENDPOINT_AZURE_PROD, OPENAI_ENDPOINT_AZURE_TEST, etc.
    .PARAMETER n
    The number of images to generate, default is 1. For dall-e-3 model, the n can only be 1. For dall-e-2 model, the n can be 1-10(openai), 1-5(azure).
    .PARAMETER size
    The size of the image to generate, default is 2, which means 1024x1024. For dall-e-3 model, the size can only be 2-4, which means 1024x1024, 1792x1024, 1024x1792. For dall-e-2 model, the size can be 0-2 for 256x256, 512x512, 1024x1024.
    .PARAMETER outfolder
    The folder to save the generated image, default is current folder.
    .PARAMETER environment
    The environment name, if you use azure openai service, you can specify the environment by this parameter, the environment name can be any names you want, for example, dev, prod, test, etc, the environment name will be used to read the api key and endpoint from environment variable, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_ENDPOINT_AZURE_DEV, etc.
    .PARAMETER azure
    Use azure openai service, if specified, the api key and endpoint will be read from environment variable OPENAI_API_KEY_AZURE or OPENAI_API_KEY_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_API_KEY_AZURE_DEV, OPENAI_API_KEY_AZURE_PROD, OPENAI_API_KEY_AZURE_TEST, etc. and OPENAI_ENDPOINT_AZURE or OPENAI_ENDPOINT_AZURE_<environment>, the <environment> can be any names you want, for example, OPENAI_ENDPOINT_AZURE_DEV, OPENAI_ENDPOINT_AZURE_PROD, OPENAI_ENDPOINT_AZURE_TEST, etc.
    .PARAMETER dall3
    Use dall-e-3 model if specified, otherwise, use dall-e-2 model. dall-e-3 model can only generate 1024x1024, 1792x1024, 1024x1792 image, dall-e-2 model can generate 256x256, 512x512, 1024x1024 image.
    .EXAMPLE
    New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -n 1 -size 2 -outfolder "c:\temp"
    Use dall-e-2 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder.
    .EXAMPLE
    New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -n 1 -size 2 -outfolder "c:\temp" -api_key "your api key" -endpoint "your endpoint"
    Use dall-e-2 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use your own api key and endpoint.
    .EXAMPLE
    image -n 3 -prompt "A painting of a cat sitting on a chair"
    Use dall-e-2 model to generate image, the image size is 1024x1024, the generated image will be saved to current folder, generate 3 images.
    .EXAMPLE
    New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -n 1 -size 2 -outfolder "c:\temp" -azure
    Use dall-e-2 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use azure openai service.
    .EXAMPLE
    New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -n 1 -size 2 -outfolder "c:\temp" -azure -environment "dev"
    Use dall-e-2 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use azure openai service, read api key and endpoint from environment variable OPENAI_API_KEY_AZURE_DEV and OPENAI_ENDPOINT_AZURE_DEV.
    .EXAMPLE
    New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -n 1 -size 2 -outfolder "c:\temp" -azure -environment "dev" -dall3
    Use dall-e-3 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use azure openai service, read api key and endpoint from environment variable OPENAI_API_KEY_AZURE_DEV and OPENAI_ENDPOINT_AZURE_DEV.
    .EXAMPLE
    New-ImageGeneration -prompt "A painting of a cat sitting on a chair" -n 1 -size 2 -outfolder "c:\temp" -azure -prompt "c:\temp\prompt.txt"
    Use dall-e-2 model to generate image, the image size is 1024x1024, the generated image will be saved to c:\temp folder, use azure openai service, and use prompt from file c:\temp\prompt.txt
    .LINK
    https://github.com/chenxizhang/openai-powershell
    #>
    [CmdletBinding()]
    [Alias("dall")][Alias("image")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline=$true)][string]$prompt,
        [string]$api_key,
        [string]$endpoint, 
        [switch]$azure,
        [int]$n = 1, #for azure, the n can be 1-5, for openai, the n can be 1-10, for dall3, it always be 1
        [int]$size = 2,
        [string]$outfolder = ".",
        [string]$environment,
        [switch]$dall3
    )

   
    BEGIN {
        Write-Verbose "Parameter received`n$($PSBoundParameters | Out-String)"
        Write-Verbose "Environment variable detected.`n$(Get-ChildItem Env:OPENAI_* | Out-String)"

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
            Write-Error $resources.openai_unavaliable
            $hasError = $true
        }


        if (!$api_key) {
            Write-Error $resources.error_missing_api_key
            $hasError = $true
        }

        if (!$endpoint) {
            Write-Error $resources.error_missing_endpoint
            $hasError = $true
        }


    }

    PROCESS {
        if ($hasError) {
            return
        }

        # collect the telemetry data
        Submit-Telemetry -cmdletName $MyInvocation.MyCommand.Name -innovationName $MyInvocation.InvocationName -useAzure $azure

        # if the prompt is a file, read the content of the file
        if (Test-Path $prompt -PathType Leaf) {
            Write-Verbose "Prompt is a file path, read the file as prompt"
            $prompt = Get-Content $prompt -Raw -Encoding UTF8
        }

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
            "Content-Type" = "application/json;charset=utf-8"
        }

        if ($azure) {
            $headers.Add("api-key", $api_key)

            $request = Invoke-WebRequest -Method Post -Uri $endpoint -Headers $headers -Body $body
            Write-Verbose $request


            if ($dall3) {
                $url = ($request | ConvertFrom-Json).data[0].url
                $filename = [System.Guid]::NewGuid().ToString() + ".png"
                $file = [System.IO.Path]::Combine($outfolder, $filename)
                Invoke-WebRequest -Uri $url -OutFile $file
                Write-Verbose "Download completed, please check the folder: $outfolder"
                Write-Output $file # return the file path
            }
            else {
                <# Action when all if and elseif conditions are false #>
                Write-Verbose ($request.Headers | Out-String)
                $location = if ($PSVersionTable['PSVersion'].Major -le 5) { $request.Headers['operation-location'] } else { $request.Headers['operation-location'][0] }
                if ($null -eq $location) {
                    Write-Error "Generate fail "
                    return
                }
                Write-Verbose "Location received: $location"
                while ($true) {
                    $query = Invoke-RestMethod -Uri $location -Headers $headers
                    if ($query.status -eq 'succeeded') {
                        $query.result.data | Select-Object -ExpandProperty url | ForEach-Object {
                            $filename = [System.Guid]::NewGuid().ToString() + ".png"
                            $file = [System.IO.Path]::Combine($outfolder, $filename)
                            Write-Verbose "Downloading file: $file"
                            Invoke-WebRequest -Uri $_ -OutFile $file
                            Write-Output $file # return the file path
                        }

                        Write-Verbose "Download completed, please check the folder: $outfolder"
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
                $file = [System.IO.Path]::Combine($outfolder, $filename)
                Write-Verbose "Downloading file: $file"
                Invoke-WebRequest -Uri $_ -OutFile $file
                Write-Output $file # return the file path
            }

            Write-Verbose "Download completed, please check the folder: $outfolder"


        }
    }

    END {

    }
}