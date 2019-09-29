param([string]$operationTypeToDelete="")

$unhandledItems = @()
$operationType = "Delete"
$operationTypes = @("SendZip", "SendCopy", "ReceiveCopy", "ReceiveUnzip")

if($operationTypes.Contains($operationTypeToDelete)){

$errorsPath = ($PSScriptRoot + "\" + "log_" + $operationType + "_" + $operationTypeToDelete + ".txt")
$progressFilePath = ($PSScriptRoot + "\" + "InProgress_" + $operationType + "_" + $operationTypeToDelete + ".txt")
$deletionReadyPath = ($PSScriptRoot + "\" + "deletion_ready_" + $operationTypeToDelete + ".txt")

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
		}
	}
}

$items = Get-Content -Path $deletionReadyPath
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

	if(Test-Path $item){
		try
		{
			Write-Output ("Deleting file: " + $item)
			Add-Content -Path $progressFilePath -Value $progressStartText
			Add-Content -Path $progressFilePath -Value $item
			Add-Content -Path $progressFilePath -Value $i
			Remove-Item -Path $item -Verbose -Confirm:$false -Recurse
			Add-Content -Path $progressFilePath -Value $progressEndText
		}
		catch
		{
			Write-Output ((Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " -> Was not able to delete file: " + $item)
			$unhandledItems += ((Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " -> Was not able to delete file: " + $item)
		}
		$i = $i + 1
	}
}
Remove-Item -Path $progressFilePath
Remove-Item -Path $deletionReadyPath

Write-Output "Script finished!"
if($unhandledItems.Count -gt 0){
	Write-Output "- - - - - E R R O R   S U M M A R Y - - - - -"
	foreach ($unhandledItem in $unhandledItems){ Write-Output ($unhandledItem) }
	Write-Output "- - - - - E R R O R   S U M M A R Y - - - - -"
	Add-Content -Path $errorsPath -Value "- - - - - E R R O R   S U M M A R Y - - - - -"
	foreach ($unhandledItem in $unhandledItems){ Add-Content -Path $errorsPath -Value ($unhandledItem) }
	Add-Content -Path $errorsPath -Value "- - - - - E R R O R   S U M M A R Y - - - - -"
	Write-Output ("Error logs saved to file: " + $errorsPath)
} else {
	Write-Output "No errors when running script!"
}

} else {
	Write-Output "Bad operationTypeToDelete parameter value passed to PowerShell Script"
}
[System.GC]::Collect()