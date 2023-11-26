function Merge-Hashtable {
    [CmdletBinding()]
    param (
        [hashtable]$table1,
        [hashtable]$table2
    )

    foreach ($key in $table2.Keys) {
        if ($table1.ContainsKey($key)) {
            $table1[$key] = $table2[$key]  # 用第二个hashtable的值覆盖第一个hashtable的值
        }
        else {
            $table1.Add($key, $table2[$key])
        }
    }
}