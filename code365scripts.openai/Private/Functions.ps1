function Get-PredefinedFunctions {
    param([string[]]$names)

    return $names | ForEach-Object {
        Get-FunctionJson -functionName $_
    } | Where-Object { $_ -ne $null }
}

function Get-FunctionJson {
    param([string]$functionName)

    # if the function is not exist, return null
    if (-not (Get-Command $functionName -ErrorAction SilentlyContinue)) {
        Write-Warning "Function $functionName does not exist."
        return $null
    }

    # generate a json object based on the help content of the function
    $help = Get-Help $functionName
    $json = [pscustomobject]@{
        type     = "function"
        function = @{
            name        = $help.Name
            description = $help.description[0].Text
            parameters  = @{
                type       = "object"
                properties = Get-FunctionParameters -obj $help.parameters.parameter
                required   = @(
                    $help.parameters.parameter | Where-Object { $_.required -eq $true } | Select-Object -ExpandProperty Name
                )
            }
        }
    }
    return $json
}


function Get-FunctionParameters {
    param([psobject[]]$obj)

    $result = [PSCustomObject]@{}
    foreach ($item in $obj) {
        $result | Add-Member -MemberType NoteProperty -Name $item.Name -Value @{
            type        = $item.type.name.tolower()
            description = $item.description[0].Text
        }
    }
    return $result
}