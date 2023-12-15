function Get-ImageBase64Uri($file) {
    $image = [System.IO.File]::ReadAllBytes($file)
    # get extension without dot
    $type = [System.IO.Path]::GetExtension($file).TrimStart(".")
    $base64 = [System.Convert]::ToBase64String($image)
    $uri = "data:image/$type;base64,$base64"
    return $uri
}
