Invoke-Expression "& `"$PSScriptRoot\_900_ResetTestData.ps1`""
[xml]$config = Get-Content -Path ($PSScriptRoot + "\" + "Config.xml")
### Create target packaging folder ###
$packageDirectory = "dist"
$packagePath = ($PSScriptRoot + "\" + $packageDirectory)
$fso = New-Object -ComObject scripting.filesystemobject
if(Test-Path $packagePath -PathType Container){
	$fso.DeleteFolder($packagePath)
}
$fso.CreateFolder($packagePath)
### Set copying parameters ###
$itemSearchPatterns = @()
$itemSearchPatterns += "Config.xml"
$itemSearchPatterns += "*.ps1"
$itemSearchPatterns += "*.bat"
$nonHiddenFiles = @()
$nonHiddenFiles += "Config.xml"
$nonHiddenFiles += "Send.bat"
$nonHiddenFiles += "Receive.bat"
$nonHiddenFiles += "DeleteAllManually.bat"
$excludedFiles = @()
$excludedFiles += "_900_ResetTestData.ps1"
$excludedFiles += "_999_TestAll.ps1"
### Copy files to packaging folder ###
foreach($itemSearchPattern in $itemSearchPatterns){
	Get-ChildItem -Verbose -Path $PSScriptRoot $itemSearchPattern | Foreach-object { 
		if(!($excludedFiles.Contains($_.Name))){
			Copy-item -Verbose -Recurse -path $_.FullName -Destination ($packagePath + "\" + $_.Name)
			if(!($nonHiddenFiles.Contains($_.Name))){
				(get-item ($packagePath + "\" + $_.Name)).Attributes += 'Hidden'
			}
		}
	}
}
### Clear test folders ###
$folders = @()
$folders += $config.Root.Send.SourceFolder
$folders += $config.Root.Send.TargetZipFolder
$folders += $config.Root.Send.TargetCopyFolder
$folders += $config.Root.Receive.SourceFolder
$folders += $config.Root.Receive.TargetCopyFolder
$folders += $config.Root.Receive.TargetUnzipFolder

foreach($folder in $folders){
	Remove-Item $folder -Recurse
	New-Item -Path $folder -ItemType directory
}
### Remove large test file ###
$largeTestfilePath = ($config.Root.Tests.TestDataFolder + "\" + "Unzipped" + "\" + "LargeFile.txt")
Remove-Item -Path $largeTestfilePath