[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]
    $RclonePath = '.\rclone.exe',
    [Parameter(Mandatory=$false)]
    [string]
    $RcloneConfigPath = '.\rclone.conf',
    [Parameter(Mandatory=$false)]
    [string]
    $RcloneAction = 'move',
    [Parameter(Mandatory=$false)]
    [string]
    $RcloneLocalSRCPath = 'C:\temp\rclone\X\Data',
    [Parameter(Mandatory=$false)]
    [string]
    $RcloneLocalDSTPath = 'C:\temp\rclone\X\Archive',
    [Parameter(Mandatory=$false)]
    [string]
    $RcloneProgress = '--progress' ,
    [Parameter(Mandatory=$false)]
    [string]
    $RcloneDontPreserveMetadata = '--metadata',
    [Parameter(Mandatory=$false)]
    [string]
    $RcloneDryRun = $true ,
    [Parameter(Mandatory=$false)]
    [string]
    $RcloneLogPath = 'C:\temp\rclone\log.txt',
    [Parameter()]
    [validateSet("DEBUG", "INFO", "NOTICE", "ERROR")]
    [string]
    $RcloneLogLevel = "NOTICE",
    [Parameter(Mandatory=$false)]
    [string]
    $RcloneMinAge = '2y'

)

if(-not (Test-Path -Path $RclonePath -PathType Leaf)){
    Write-Error "Rclone.exe not found at $RclonePath"
    exit    
}

if(-not (Test-Path -Path $RcloneConfigPath -PathType Leaf)){
    Write-Error "Rclone.conf not found at $RcloneConfigPath"
    exit    
}

if(-not (Test-Path -Path $RcloneLocalSRCPath -PathType Container)){
    Write-Error "Source Path: $RcloneLocalSRCPath"
    exit    
}

if(-not (Test-Path -Path $RcloneLocalDSTPath -PathType Container)){
    Write-Error "Destination Path: $RcloneLocalDSTPath"
    exit    
}

$argumentList = $RcloneAction

if($RcloneProgress){
    Write-Output "Progress enabled"
    $argumentList= $argumentList + " --progress"
}

if(-not ($RcloneDontPreserveMetadata)){
    Write-Output "Preserve metadata disabled"
}else {
    Write-Output "Preserve metadata enabled"
    $argumentList = $argumentList + " --metadata"

}

if ($RcloneDryRun){
    Write-Output "Dry run enabled"
    $argumentList = $argumentList + " --dry-run"
}

if ($RcloneLogPath){
    $argumentList = $argumentList + " --log-file=`"$RcloneLogPath`"" + " --log-level `"$RcloneLogLevel`""
}


if ($RcloneMinAge){
    $argumentList = $argumentList + " --min-age $RcloneMinAge"
}


$argumentList = $argumentList  + " `"$RcloneLocalSRCPath`" `"$RcloneLocalDSTPath`""

Start-Process -FilePath $RclonePath -ArgumentList $argumentList -NoNewWindow -Wait


switch ($LastExitCode) {
    0 { Write-Host -ForegroundColor Green "success" }
    1 { Write-Host -ForegroundColor Red "Syntax or usage error" }
    2 { Write-Host -ForegroundColor Red "Error not otherwise categorised" }
    3 { Write-Host -ForegroundColor Red "Directory not found" }
    4 { Write-Host -ForegroundColor Red "File not found" }
    5 { Write-Host -ForegroundColor Red "Temporary error (one that more retries might fix) (Retry errors)" }
    6 { Write-Host -ForegroundColor Red "Less serious errors (like 461 errors from dropbox) (NoRetry errors)" }
    7 { Write-Host -ForegroundColor Red "Fatal error (one that more retries won't fix, like account suspended) (Fatal errors)" }
    8 { Write-Host -ForegroundColor Red "Transfer exceeded - limit set by --max-transfer reached" }
    9 { Write-Host -ForegroundColor Red "Operation successful, but no files transferred" }
    10 { Write-Host -ForegroundColor Red "Duration exceeded - limit set by --max-duration reached" }
   
    Default { Write-Host -ForegroundColor Red "Unknown Error, exitcode $LastExitCode" }
}


