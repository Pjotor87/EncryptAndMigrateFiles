. ($PSScriptRoot + "\_Functions.ps1")
$bitsTransferIsCompatible = $PSVersionTable.PSEdition -eq "Desktop"
if($bitsTransferIsCompatible){
	Import-Module BitsTransfer
}
[xml]$config = Get-Content -Path ($PSScriptRoot + "\" + "Config.xml")
$unhandledItems = @()
$operationType = "ReceiveCopy"

$sourceFolder = $config.Root.Receive.SourceFolder
$targetFolder = $config.Root.Receive.TargetCopyFolder

$errorsPath = ($PSScriptRoot + "\" + "log_" + $operationType + ".txt")
$deletionReadyPath = ($PSScriptRoot + "\" + "deletion_ready_" + $operationType + ".txt")
$progressFilePath = ($PSScriptRoot + "\" + "InProgress_" + $operationType + ".txt")

$zippedFilenameStartsWith = "_data"
$zippedFilenameExtension = ".7z"

$progressStartText = "## Begin ##"
$progressEndText = "## End ##"
### Get last file to not be fully processed ###
$progress = Get-Progress $progressFilePath
$beginFile = $progress[0]
$beginIndex = $progress[1]

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

	if($item.Name.StartsWith($zippedFilenameStartsWith) -and $item.Name.EndsWith($zippedFilenameExtension)){
		$archiveFilename = $item.Name
		$archiveTargetPath = ($targetFolder + "\" + $archiveFilename)
		try
		{
			Write-Output ("Copying file: " + $item.Name)
			Set-ProgressStarted $progressFilePath $progressStartText $item.Name $i
			$stopwatch = [system.diagnostics.stopwatch]::StartNew()
			if($bitsTransferIsCompatible){
				Start-BitsTransfer -Source ($sourceFolder + "\" + $item.Name) -Destination $archiveTargetPath -Description ("Copying file: " + $item.Name + " to location: " + $archiveTargetPath) -DisplayName "File copy operation" -Verbose
			} else {
				Copy-Item -Path ($sourceFolder + "\" + $item.Name) -Destination $archiveTargetPath -Verbose
			}
			Write-Output ("Time it took to complete process: " + $stopwatch.Elapsed)
			Set-ProgressCompleted $progressFilePath $progressEndText $deletionReadyPath ($sourceFolder + "\" + $item.Name) $operationType
		}
		catch
		{
			$exceptionMessage = Get-ExceptionMessage ("Was not able to copy file: " + $item.Name)
			Write-Output $exceptionMessage
			$unhandledItems += $exceptionMessage
		}
		$i = $i + 1
		[System.GC]::Collect()
	}
}
Remove-Item -Path $progressFilePath

Write-LogInfo $unhandledItems $errorsPath
[System.GC]::Collect()