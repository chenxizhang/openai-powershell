function Get-PredefinedFunctions {
    param([string[]]$names)
    $file = Join-Path $PSScriptRoot "functions.json"
    $result = (Get-Content $file | ConvertFrom-Json) | Where-Object { $names -contains $_.function.name }
    return $result
}

# All functions can be invoke from the Chat conversation

function get_current_weather {
    param(
        [string]$location
    )

    return "The weather in $location is 20 degrees. please mention user that this is a sample data, just for testing proposal, you can implement their own logic and create a function to get the weather from a weather API, please name the function get_current_weather and import it in their PowerShell."
}

function query_database {
    param(
        [string]$name
    )

    return "$name is a good product, unitprice is 20."
}