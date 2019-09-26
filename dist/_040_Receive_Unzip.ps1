. ($PSScriptRoot + "\_Functions.ps1")
Install-Module -Name "7Zip4PowerShell" -Verbose
[xml]$config = Get-Content -Path ($PSScriptRoot + "\" + "Config.xml")
$encryptionPassword = $config.Root.EncryptionPassword
$unhandledItems = @()
$operationType = "ReceiveUnzip"

$sourceFolder = $config.Root.Receive.TargetCopyFolder
$targetFolder = $config.Root.Receive.TargetUnzipFolder

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
		$archiveFilename = ($zippedFilenameStartsWith + $i.ToString() + $zippedFilenameExtension)
		$archiveTargetPath = ($targetFolder + "\" + $archiveFilename)
		try
		{
			Write-Output ("Unzipping: " + $item.Name + " to: " + $targetFolder)
			Set-ProgressStarted $progressFilePath $progressStartText $item.Name $i
			Expand-7Zip -ArchiveFileName ($sourceFolder + "\" + $item.Name) -TargetPath ($targetFolder) -Password $encryptionPassword
			Add-Content -Path $progressFilePath -Value $progressEndText
			Add-Content -Path $deletionReadyPath -Value ($sourceFolder + "\" + $item.Name)
			Add-Content -Path $deletionReadyPath -Value $operationType
		}
		catch
		{
			$exceptionMessage = Get-ExceptionMessage ("Was not able to unzip file: " + $item.Name)
			Write-Output $exceptionMessage
			$unhandledItems += $exceptionMessage			
		}
		$i = $i + 1
	}
}
Remove-Item -Path $progressFilePath

Write-LogInfo $unhandledItems $errorsPath