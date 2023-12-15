function Get-OnlineImageBase64Uri($url) {
    # Create a new WebClient instance
    $webClient = New-Object System.Net.WebClient

    # Download the image data
    $imageData = $webClient.DownloadData($url)

    # Convert the image data to base64
    $base64 = [System.Convert]::ToBase64String($imageData)

    # Get the image type from the URL
    $type = if ($url -match "\.(\w+)$") { $Matches[1] } else { "png" }

    # Create the data URI
    $uri = "data:image/$type;base64,$base64"

    return $uri
}

function Get-ImageBase64Uri($file) {
    # if the file is a local file path, then read the file as byte array
    if (Test-Path $file -PathType Leaf) {
        Write-Verbose "Prompt is a local file path, read the file as prompt"
        $image = [System.IO.File]::ReadAllBytes($file)
        # get extension without dot
        $type = [System.IO.Path]::GetExtension($file).TrimStart(".")
        $base64 = [System.Convert]::ToBase64String($image)
        $uri = "data:image/$type;base64,$base64"
        return $uri
    }

    if ($file -match "^https?://") {
        Write-Verbose "Prompt is a url, read the url as prompt"
        $uri = Get-OnlineImageBase64Uri -url $file

        return $uri
    }
}
