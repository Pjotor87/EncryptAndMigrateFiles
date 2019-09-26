function Get-ExceptionMessage($message){
	return ((Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " -> " + $message)
}

function Write-LogInfo ($unhandledItems, $errorsPath) {
	Write-Output "Script finished!"
	if($unhandledItems.Count -gt 0){
		$errorSummarStartMessage = "- - - - - E R R O R   S U M M A R Y   S T A R T - - - - -"
		$errorSummarEndMessage =   "- - - - - - E R R O R   S U M M A R Y   E N D - - - - - -"
		
		Write-Output $errorSummarStartMessage
		foreach ($unhandledItem in $unhandledItems){ Write-Output ($unhandledItem) }
		Write-Output $errorSummarEndMessage
		
		Add-Content -Path $errorsPath -Value $errorSummarStartMessage
		foreach ($unhandledItem in $unhandledItems){ Add-Content -Path $errorsPath -Value ($unhandledItem) }
		Add-Content -Path $errorsPath -Value $errorSummarEndMessage
		
		Write-Output ("Error logs saved to file: " + $errorsPath)
	} else {
		Write-Output "No errors when running script!"
	}
}

### Set - File is not fully processed ###
function Set-ProgressStarted($progressFilePath, $progressStartText, $itemname, $i){
	Add-Content -Path $progressFilePath -Value $progressStartText
	Add-Content -Path $progressFilePath -Value $item.Name
	Add-Content -Path $progressFilePath -Value $i
}

### Set - File is fully processed ###
function Set-ProgressCompleted($progressFilePath, $progressEndText, $deletionReadyPath, $deletionPath, $operationType){
	Add-Content -Path $progressFilePath -Value $progressEndText
	Add-Content -Path $deletionReadyPath -Value $deletionPath
	Add-Content -Path $deletionReadyPath -Value $operationType
}

### Get last file not fully processed ###
function Get-Progress($progressFilePath){
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
	
	return @($beginFile, $beginIndex)
}