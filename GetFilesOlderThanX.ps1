# Angiv stien der skal kigges i
$targetFolder = "C:\PATH-HERE" # lav en read-host her ;) --MAthias
# Angiv antal måneder den skal kigge tilbage i
$months = 4

$destinationFolder = "$env:USERPROFILE\Desktop\Script"
$outputFile = "$destinationFolder\Output.txt"

if (-not (Test-Path $destinationFolder)) {
    New-Item -Path $destinationFolder -ItemType Directory | Out-Null
}

if (-not (Test-Path $outputFile)) {
    New-Item -Path $outputFile -ItemType File | Out-Null
}

$subtractMonths = (Get-Date).AddMonths(-$months)
$files = Get-ChildItem -Path $targetFolder -Recurse | Where-Object { $_.LastWriteTime -ge $subtractMonths }

function Show-Tree($items, $indent = "   ") {
    foreach ($item in $items) {
        $icon = if ($item.PSIsContainer) { "📂" } else { "📄" }
        $fileEntry = "$indent$icon $($item.Name) (Modified: $($item.LastWriteTime))"
        Write-Output $fileEntry
        $fileEntry | Out-File -Append -FilePath $outputFile
    }
}

@"
=========================================
Modified Files Report - Last $months Months
=========================================

"@ | Out-File $outputFile

$groupedByFolder = $files | Group-Object DirectoryName

foreach ($folder in $groupedByFolder) {
    $folderHeader = @"
---------------------------------------------------
📂 Folder: $($folder.Name)
---------------------------------------------------
"@
    Write-Output $folderHeader
    $folderHeader | Out-File -Append -FilePath $outputFile

    Show-Tree $folder.Group

    # Copy the folder and its contents to the destination folder
    $destinationPath = Join-Path -Path $destinationFolder -ChildPath (Split-Path -Leaf $folder.Name)
    Copy-Item -Path $folder.Name -Destination $destinationPath -Recurse -Force
}

# Ensure root files (files not in subfolders) are also copied
$rootFiles = Get-ChildItem -Path $targetFolder -File | Where-Object { $_.LastWriteTime -ge $subtractMonths }
foreach ($file in $rootFiles) {
    Copy-Item -Path $file.FullName -Destination $destinationFolder -Force
}

Write-Output "✅ Folders and root files copied successfully to: $destinationFolder"
Write-Output "✅ Tree structure saved to: $outputFile"
