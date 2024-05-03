# All functions can be invoke from the Chat conversation

function Get-Weather{
    param(
        [string]$City
    )

    return "The weather in $City is 25 degrees"
}
