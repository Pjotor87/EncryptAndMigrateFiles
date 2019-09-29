[xml]$config = Get-Content -Path ($PSScriptRoot + "\" + "Config.xml")

$largeFileCreatorFolder = ($config.Root.Tests.TestDataFolder + "\" + "Unzipped")
$largeFileCreatorPath = ($largeFileCreatorFolder + "\" + "createLargeFile.bat")
cd $largeFileCreatorFolder
Start-Process $largeFileCreatorPath
Sleep 1
cd $PSScriptRoot

$folders = @()
$folders += $config.Root.Send.SourceFolder
$folders += $config.Root.Send.TargetZipFolder
$folders += $config.Root.Send.TargetCopyFolder
$folders += $config.Root.Receive.SourceFolder
$folders += $config.Root.Receive.TargetCopyFolder
$folders += $config.Root.Receive.TargetUnzipFolder

foreach($folder in $folders){
	if(Test-Path $folder -PathType Container){
		Remove-Item $folder -Recurse
	}
	New-Item -Path $folder -ItemType directory
}

$largeFiles = @()
$largeFiles += "LargeFile.txt"
$largeFiles += "_data2.7z"
Get-ChildItem -Verbose -Path ($config.Root.Tests.TestDataFolder + "\" + "Unzipped") | Foreach-object { 
	if($config.Root.Tests.IncludeLargeFiles -ne "True" -and $largeFiles.Contains($_.Name)){
		Write-Output ("Skipping large file: " + $_.Name)
	} else {
		Copy-item -Verbose -Recurse -path $_.FullName -Destination ($config.Root.Send.SourceFolder + "\" + $_.Name)
	}
}
Get-ChildItem -Verbose -Path ($config.Root.Tests.TestDataFolder + "\" + "Zipped") | Foreach-object {
	if($config.Root.Tests.IncludeLargeFiles -ne "True" -and $largeFiles.Contains($_.Name)){
		Write-Output ("Skipping large file: " + $_.Name)
	} else {
		Copy-item -Verbose -Recurse -path $_.FullName -Destination ($config.Root.Receive.SourceFolder + "\" + $_.Name)
	}
}

Get-ChildItem -Verbose -Path $PSScriptRoot "*.txt" | foreach { Remove-Item -Verbose $_.FullName }
[System.GC]::Collect()