[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $rClonePath = "C:\Program Files\rClone\rclone.exe",
    [Parameter()]
    [string]
    $sourcePath = "P:\Canon 90D",
    [Parameter()]
    [string]
    $destinationPath = "/Photographs",
    [Parameter()]
    [string]
    $remoteName = "backups",
    [Parameter()]
    [string]
    $action = "copy",
    [Parameter()]
    [string]
    $flags = "-P",  
    [Parameter()]
    [string]
    $logFile = "P:\rClone\mylogfile.txt",
    [Parameter()]
    [validateSet("DEBUG", "INFO", "NOTICE", "ERROR")]
    [string]
    $logLevel = "INFO"
    
)

if(!(Test-Path $rClonePath -PathType Leaf)){
    throw "rClone not found at $rClonePath"
    exit 1
}

if(!(Test-Path $sourcePath -PathType Container)){
    throw "Source path not found at $sourcePath"
    exit 1
}

if($logFile){
    # Get the directory from the log file path
    $logDirectory = Split-Path -Parent $logFile

    # Check if the directory exists
    if (-not (Test-Path $logDirectory)) {
        # If the directory doesn't exist, create it
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    }

    if(!$logLevel){ $logLevel = "INFO" }
    $logparmeters = "--log-file=`"$logFile`" --log-level `"$logLevel`""
}else{
    $logparmeters = ""
}
$argumentList = "$action $flags `"$sourcePath`" `"$remoteName`:$destinationPath`"" + " $logparmeters"

Start-Process -FilePath $rClonePath -ArgumentList $argumentList -NoNewWindow -Wait



