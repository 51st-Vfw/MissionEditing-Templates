# if not executing update below, you'll need to logout and back in in windows to pick up the new path
# [Environment]::SetEnvironmentVariable("7z", "C:\Program Files\7-Zip", "User")

$BaseDir = split-path -parent $MyInvocation.MyCommand.Definition
$BaseDir = split-path -parent $BaseDir
$UnpackDir = "$BaseDir\miz_tmp_unpacked"
$MissionFile = $BaseDir + "\" + $Args[0]

Write-Output "Packing src: $UnpackDir"
Write-Output "        dst: $MissionFile"

$7zip = [Environment]::GetEnvironmentVariable('7zip', 'User')
if ($7zip -ne $null) {
    Write-Output "7zip (environment): $7zip"
} else {
    $7zip = "C:\Program Files\7-Zip\7z.exe"
    Write-Output "7zip (default): $7zip"
}

if (-not (Test-path -Path $UnpackDir)) {
    Write-Output "Aborting, missing $UnpackDir"
    return
}

$MasterAudioDir = "$BaseDir\miz_master_audio"
$MasterBriefDir = "$BaseDir\miz_master_brief"
$MasterKboardDir = "$BaseDir\miz_master_kboard"
$MasterScriptDir = "$BaseDir\miz_master_scripts"

$UnpDefaultDir = "$UnpackDir\l10n\DEFAULT"
$UnpKboardDir = "$UnpackDir\KNEEBOARD\IMAGES"

function Copy-MizMasterFiles {
    param (
        [string] $MasterDir,
        [string] $MasterFiles,
        [string] $UnpackDir
    )
    if (Test-Path -Path $MasterFiles) {
        Write-Output "Injecting src: $MasterFiles"
        Write-Output "          dst: $UnpackDir"
        if (-not (Test-Path -Path $UnpackDir)) {
            New-Item -Force -Path $UnpackDir -ItemType Directory
        }
        Copy-Item -Force $MasterFiles $UnpackDir
    } else {
        Write-Output "Skipping $MasterFiles"
    }
}

# copy the audio, briefing, and script master files from the master directories to the unpacked mission

Copy-MizMasterFiles -MasterDir $MasterAudioDir -MasterFiles "$MasterAudioDir\*.wav" -UnpackDir $UnpDefaultDir
Copy-MizMasterFiles -MasterDir $MasterAudioDir -MasterFiles "$MasterAudioDir\*.ogg" -UnpackDir $UnpDefaultDir

Copy-MizMasterFiles -MasterDir $MasterBriefDir -MasterFiles "$MasterBriefDir\*.jpg" -UnpackDir $UnpDefaultDir
Copy-MizMasterFiles -MasterDir $MasterBriefDir -MasterFiles "$MasterBriefDir\*.png" -UnpackDir $UnpDefaultDir

Copy-MizMasterFiles -MasterDir $MasterScriptDir -MasterFiles "$MasterScriptDir\*.lua" -UnpackDir $UnpDefaultDir

# copy the kneeboards, since these are not linked in the .miz, we will blow away the kneeboard directory first.

if (Test-Path -Path $UnpKboardDir) {
    Remove-Item -Force -Recurse -Path $UnpKboardDir
}
Copy-MizMasterFiles -MasterDir $MasterKboardDir -MasterFiles "$MasterKboardDir\*.jpg" -UnpackDir $UnpKboardDir
Copy-MizMasterFiles -MasterDir $MasterKboardDir -MasterFiles "$MasterKboardDir\*.png" -UnpackDir $UnpKboardDir

# move existing .miz to recycle bin

if (Test-Path -Path $MissionFile) {
    $Shell = New-Object -ComObject 'Shell.Application'
    $MissionItem = Get-Item -Path $MissionFile
    $Shell.NameSpace($BaseDir).ParseName($MissionItem.Name).InvokeVerb("delete")
}

# create .miz by packing contents of $UnpackDir directory via 7z to $MissionFile

Write-Output "Creating Archive src: $UnpackDir"
Write-Output "                 dst: $MissionFile"

Set-Location -Path $UnpackDir
. $7zip a -r -y -tzip $MissionFile *
Set-Location -Path $BaseDir
