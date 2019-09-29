. ($PSScriptRoot + "\_Functions.ps1")
[xml]$config = Get-Content -Path ($PSScriptRoot + "\" + "Config.xml")
$encryptionPassword = $config.Root.EncryptionPassword
$unhandledItems = @()
$operationType = "SendZip"

$sourceFolder = $config.Root.Send.SourceFolder
$targetFolder = $config.Root.Send.TargetZipFolder

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

	if(!($item.Name.StartsWith($zippedFilenameStartsWith) -and $item.Name.EndsWith($zippedFilenameExtension))){
		$archiveFilename = ($zippedFilenameStartsWith + $i.ToString() + $zippedFilenameExtension)
		$archiveTargetPath = ($targetFolder + "\" + $archiveFilename)
		try
		{
			Write-Output ("Zipping: " + $item.Name + " to: " + $archiveTargetPath)
			Set-ProgressStarted $progressFilePath $progressStartText $item.Name $i
			
			$stopwatch = [system.diagnostics.stopwatch]::StartNew()
			Invoke-Expression ("7z a -mhe=on -p'" + $encryptionPassword + "' '" + $archiveTargetPath + "' '" + $sourceFolder + "\" + $item.Name + "'")
			Write-Output ("Time it took to complete process: " + $stopwatch.Elapsed)
			
			Set-ProgressCompleted $progressFilePath $progressEndText $deletionReadyPath ($sourceFolder + "\" + $item.Name) $operationType
		}
		catch
		{
			$exceptionMessage = Get-ExceptionMessage ("Was not able to zip file: " + $item.Name)
			Write-Output $exceptionMessage
			$unhandledItems += $exceptionMessage
		}
		$i = $i + 1
	}
}
Remove-Item -Path $progressFilePath

Write-LogInfo $unhandledItems $errorsPath