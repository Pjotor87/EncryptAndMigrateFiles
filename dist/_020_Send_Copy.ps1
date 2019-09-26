. ($PSScriptRoot + "\_Functions.ps1")
Import-Module BitsTransfer
[xml]$config = Get-Content -Path ($PSScriptRoot + "\" + "Config.xml")
$unhandledItems = @()
$operationType = "SendCopy"

$sourceFolder = $config.Root.Send.TargetZipFolder
$targetFolder = $config.Root.Send.TargetCopyFolder

$errorsPath = ($PSScriptRoot + "\" + "log_" + $operationType + ".txt")
$deletionReadyPath = ($PSScriptRoot + "\" + "deletion_ready_" + $operationType + ".txt")
$progressFilePath = ($PSScriptRoot + "\" + "InProgress_" + $operationType + ".txt")

$zippedFilenameStartsWith = "_data"
$zippedFilenameExtension = ".7z"
$excludeFiles = @("_010_Zip.ps1", "_020_Copy.ps1", "_030_Unzip.ps1")

$progressStartText = "## Begin ##"
$progressEndText = "## End ##"
### Get last file to not be fully processed ###
$beginFile = ""
$beginIndex = "1"
if(Test-Path $progressFilePath){
	$progressFileContent = Get-Content -Path $progressFilePath
	$fileInProgressSwitch = $false
	foreach($line in $progressFileContent){
		if($line -eq $progressStartText){
			$fileInProgressSwitch = $true
		} elseif($line -eq $progressEndText){
			$fileInProgressSwitch = $false
			$beginFile = ""
		} elseif($fileInProgressSwitch -eq $true -and !($beginFile)){
			$beginFile = $line
		} elseif($fileInProgressSwitch -eq $true -and $beginFile){
			$beginIndex = $line
		}
	}
}

$items = Get-ChildItem $sourceFolder
$i = [int]$beginIndex
foreach ($item in $items){
	### Skip file if already processed ###
	if($beginFile){
		if($beginFile -ne $item.Name){
			Write-Output ("Skipping file: " + $item.Name)
			continue
		}
	}
	$beginFile = ""

	if($item.Name.StartsWith($zippedFilenameStartsWith) -and $item.Name.EndsWith($zippedFilenameExtension) -or !($excludeFiles.Contains($item.Name))){
		$archiveFilename = $item.Name
		$archiveTargetPath = ($targetFolder + "\" + $archiveFilename)
		try
		{
			Write-Output ("Copying file: " + $item.Name)
			Set-ProgressStarted $progressFilePath $progressStartText $item.Name $i
			try {
				Start-BitsTransfer -Source ($sourceFolder + "\" + $item.Name) -Destination $archiveTargetPath -Description ("Copying file: " + $item.Name + " to location: " + $archiveTargetPath) -DisplayName "File copy operation" -Verbose
			} catch {
				Write-Output ("Copying file: " + $item.Name + " to location: " + $archiveTargetPath)
				Copy-Item -Path ($sourceFolder + "\" + $item.Name) -Destination $archiveTargetPath -Verbose
			}
			Set-ProgressCompleted $progressFilePath $progressEndText $deletionReadyPath ($sourceFolder + "\" + $item.Name) $operationType
		}
		catch
		{
			$exceptionMessage = Get-ExceptionMessage ("Was not able to copy file: " + $item.Name)
			Write-Output $exceptionMessage
			$unhandledItems += $exceptionMessage
		}
		$i = $i + 1
	}
}
Remove-Item -Path $progressFilePath

Write-LogInfo $unhandledItems $errorsPath