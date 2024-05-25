function ConvertTo-HashTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$obj
    )

    process {
        $hashTable = @{}
        $obj.PSObject.Properties | ForEach-Object {
            $hashTable[$_.Name] = $_.Value
        }

        return $hashTable
    }
}