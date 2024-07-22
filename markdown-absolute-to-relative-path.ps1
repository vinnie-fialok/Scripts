$MarkdownFiles = Get-ChildItem -Path $args[0] -File -Recurse -Filter "*.md"
$CurrentDirectory = Get-Location

function AbsoluteToRelative {
    param ($path, $file)

    $absolute = "$CurrentDirectory\$path"

    if (Test-Path $absolute -PathType Leaf) {
        return (Resolve-Path -Relative -Path $absolute -RelativeBasePath $((Get-Item $file).DirectoryName)).Replace("\", "/")
    }
    else {
        return $path
    }
}

foreach ($file in $MarkdownFiles) {
    # for links to files
    (Get-Content $file.FullName) -replace "(\[.+\])\((.+)\)", { "$($_.Groups[1])($(AbsoluteToRelative $_.Groups[2].Value $file.FullName)$($_.Groups[3]))" } | Set-Content $file.FullName
    # for links to markdown documents with pointer to heading
    (Get-Content $file.FullName) -replace "(\[.+\])\((.+)(#.+)\)", { "$($_.Groups[1])($(AbsoluteToRelative $_.Groups[2].Value $file.FullName)$($_.Groups[3]))" } | Set-Content $file.FullName
}
