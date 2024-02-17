function Get-FirstNonNullItemInArray([string[]]$array) {
    foreach ($item in $array) {
        $item = $item.ToUpper()
        $value = [System.Environment]::GetEnvironmentVariable($item)
        if ($value) {
            return $value
        }
    }
    return $null
}