function Write-LogInfo ($unhandledItems, $errorsPath) {
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
}

function Get-ExceptionMessage($message){
	return ((Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " -> " + $message)
}

function Set-ProgressStarted($progressFilePath, $progressStartText, $itemname, $i){
	Add-Content -Path $progressFilePath -Value $progressStartText
	Add-Content -Path $progressFilePath -Value $item.Name
	Add-Content -Path $progressFilePath -Value $i
}

function Set-ProgressCompleted($progressFilePath, $progressEndText, $deletionReadyPath, $deletionPath, $operationType){
	Add-Content -Path $progressFilePath -Value $progressEndText
	Add-Content -Path $deletionReadyPath -Value $deletionPath
	Add-Content -Path $deletionReadyPath -Value $operationType
}