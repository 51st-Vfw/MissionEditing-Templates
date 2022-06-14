$ScriptDir = split-path -parent $MyInvocation.MyCommand.Definition
$BaseDir = split-path -parent $ScriptDir
$UnpackDir = "$BaseDir\miz_tmp_unpacked"
$MizUnpackScript = "$ScriptDir\mizunpack.ps1"
$MizPackScript = "$ScriptDir\mizpack.ps1"

. $MizUnpackScript $Args[0]
. $MizPackScript $Args[0]

Write-Output "Cleaning up $UnpackDir"
if (Test-Path -Path $UnpackDir) {
    Remove-Item -Force -Recurse -Path $UnpackDir
}