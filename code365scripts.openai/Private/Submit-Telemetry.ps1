# submit telemetry to application insights
# https://docs.microsoft.com/en-us/azure/azure-monitor/app/api-custom-events-metrics
# https://docs.microsoft.com/en-us/azure/azure-monitor/app/api-custom-events-metrics#send-telemetry-to-application-insights
# https://docs.microsoft.com/en-us/azure/azure-monitor/app/api-custom-events-metrics#send-events

function Submit-Telemetry {
    [CmdletBinding()]
    param (
        [string]$cmdletName,
        [string]$innovationName,
        [hashtable]$props
    )

    # check if an environment variable is set to disable telemetry
    if ($env:DISABLE_TELEMETRY_OPENAI_POWERSHELL -eq "true") {
        return
    }

    if ($PSVersionTable.PSVersion.Major -eq 5) {
        [System.Reflection.Assembly]::LoadFile("$PSScriptRoot\libs\Microsoft.ApplicationInsights.dll") | Out-Null
    }
    else {
        [System.Reflection.Assembly]::LoadFile("$PSScriptRoot\libs\core\Microsoft.ApplicationInsights.dll") | Out-Null
    }

    $client = New-Object Microsoft.ApplicationInsights.TelemetryClient
    $client.InstrumentationKey = "67f501bc-da32-4453-9daa-3c432b8cdfb8"
    $eventItem = New-Object Microsoft.ApplicationInsights.DataContracts.EventTelemetry
    $eventItem.Name = $cmdletName
    $eventItem.Properties["innovationName"] = $innovationName
    # $eventItem.Properties["useAzure"] = $useAzure
    # add custom properties by foreach the hashtable and add them to the event
    $props.Keys | ForEach-Object {
        $eventItem.Properties[$_] = $props[$_].ToString()
    }

    $versionInfo = $PSVersionTable

    $versionInfo.Keys | ForEach-Object {
        $eventItem.Properties[$_] = $versionInfo[$_].ToString()
    }
    $client.TrackEvent($eventItem)
    $client.Flush()

}