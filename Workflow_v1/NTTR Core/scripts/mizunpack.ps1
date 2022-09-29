# if not executing update below, you'll need to logout and back in in windows to pick up the new path
# [Environment]::SetEnvironmentVariable("7zip", "C:\Program Files\7-Zip\7z.exe", "User")

$BaseDir = split-path -parent $MyInvocation.MyCommand.Definition
$BaseDir = split-path -parent $BaseDir
$UnpackDir = "$BaseDir\miz_tmp_unpacked"

$MissionFile = $BaseDir + "\" + $Args[0]

Write-Output "Unpacking src: $MissionFile"
Write-Output "          dst: $UnpackDir"

$7zip = [Environment]::GetEnvironmentVariable('7zip', 'User')
if ($7zip -ne $null) {
    Write-Output "7zip (environment): $7zip"
} else {
    $7zip = "C:\Program Files\7-Zip\7z.exe"
    Write-Output "7zip (default): $7zip"
}

# blow away any existing unpack directory before extracting the .miz.

Set-Location -Path $BaseDir
if (Test-Path -Path $UnpackDir) {
    Remove-Item -Force -Recurse -Path $UnpackDir
}
New-Item -Force -Path $UnpackDir -ItemType Directory
Set-Location -Path $UnpackDir
. $7zip x -r -y $MissionFile
Set-Location -Path $BaseDir