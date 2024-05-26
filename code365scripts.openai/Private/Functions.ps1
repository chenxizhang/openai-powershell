function Get-PredefinedFunctions {
    param([string[]]$names)
    $file = Join-Path $PSScriptRoot "functions.json"
    $result = (Get-Content $file | ConvertFrom-Json) | Where-Object { $names -contains $_.function.name }
    return $result
}


function get_current_weather {
    <#
        .DESCRIPTION
            Get the current weather in a given location
        .PARAMETER location
            The location to get the weather for, e.g. San Francisco, CA
    #>
    param(
        [string]$location
    )

    return "The weather in $location is 20 degrees. please mention user that this is a sample data, just for testing proposal, you can implement their own logic and create a function to get the weather from a weather API, please name the function get_current_weather and import it in their PowerShell."
}

function query_database {

    <#
        .DESCRIPTION
            query product database for product information
        .PARAMETER name
            The product name to query
    #>
    param(
        [string]$name
    )

    return "$name is a good product, unitprice is 20."
}