function Get-PredefinedFunctions {
    param([string[]]$names)
    return Get-Content "$PSScriptRoot\functions.json" -Raw | ConvertFrom-Json | Where-Object { $_.function.name -in $names }
}

# All functions can be invoke from the Chat conversation

function get_current_weather {
    param(
        [string]$location
    )

    return "The weather in $location is 20 degrees"
}

