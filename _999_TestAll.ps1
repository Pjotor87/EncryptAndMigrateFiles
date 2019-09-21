cls
Write-Output "Resetting TestData..."
Invoke-Expression "& `"$PSScriptRoot\_900_ResetTestData.ps1`""
cls
Write-Output "Running entire process..."
Invoke-Expression "& `"$PSScriptRoot\Send.ps1`""
Invoke-Expression "& `"$PSScriptRoot\Receive.ps1`""
Write-Output "Entire process has run!"