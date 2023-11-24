function Get-FirstNonNullItemInArray($array) {
    foreach ($item in $array) {
        $value = [System.Environment]::GetEnvironmentVariable($item)
        if ($value) {
            return $value
        }
    }
    return $null
}