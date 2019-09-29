[xml]$config = Get-Content -Path ($PSScriptRoot + "\" + "Config.xml")
cls
Write-Output "Resetting TestData..."
Invoke-Expression "& `"$PSScriptRoot\_900_ResetTestData.ps1`""
cls
Write-Output "Running entire process..."
$sendStopwatch = [system.diagnostics.stopwatch]::StartNew()
Invoke-Expression "& `"$PSScriptRoot\Send.ps1`""
$sendStopwatch.Stop()
if($config.Root.Tests.UseSameTestContentForReceiveAndSend -eq "True"){ Invoke-Expression "& `"$PSScriptRoot\_910_SetupReceiveTest.ps1`"" }
$receiveStopwatch = [system.diagnostics.stopwatch]::StartNew()
Invoke-Expression "& `"$PSScriptRoot\Receive.ps1`""
$receiveStopwatch.Stop()
Write-Output "Entire process has run!"

$originalConsoleColor = $host.ui.RawUI.ForegroundColor
$host.ui.RawUI.ForegroundColor = "Yellow"
Write-Output "TEST RESULTS"
Write-Output "------------"
Write-Output ("Time it took to send: " + $sendStopwatch.Elapsed)
Write-Output ("Time it took to receive: " + $receiveStopwatch.Elapsed)
$host.ui.RawUI.ForegroundColor = $originalConsoleColor

$testDataFolder = Get-ChildItem -Recurse -path ($config.Root.Tests.TestDataFolder + "\" + "Unzipped")
$receiveUnzippedFolder = Get-ChildItem -Recurse -path ($config.Root.Receive.TargetUnzipFolder)
$folderContentDiffrences = Compare-Object -ReferenceObject $testDataFolder -DifferenceObject $receiveUnzippedFolder
if($folderContentDiffrences -eq $null -or ($folderContentDiffrences.InputObject.Name -eq "LargeFile.txt" -and $folderContentDiffrences.SideIndicator -eq "<=")){
	$host.ui.RawUI.ForegroundColor = "Green"
	Write-Output "Folder content matched!"
} else {
	$host.ui.RawUI.ForegroundColor = "Red"
	Write-Output "Folder content did not match"
	$host.ui.RawUI.ForegroundColor = "Yellow"
	Write-Output "Comparison results:"
	$folderContentDiffrences
}
$host.ui.RawUI.ForegroundColor = $originalConsoleColor