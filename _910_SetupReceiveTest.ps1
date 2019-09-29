[xml]$config = Get-Content -Path ($PSScriptRoot + "\" + "Config.xml")

if($config.Root.Tests.UseSameTestContentForReceiveAndSend -eq "True"){
	$sendTargetCopyFolder = $config.Root.Send.TargetCopyFolder
	$receiveSourceFolder = $config.Root.Receive.SourceFolder
	
	if(Test-Path $receiveSourceFolder -PathType Container){
		Remove-Item $receiveSourceFolder -Recurse
	}
	New-Item -Path $receiveSourceFolder -ItemType directory
	
	Get-ChildItem -Verbose -Path $sendTargetCopyFolder | Foreach-object { 
		Copy-item -Verbose -Recurse -path $_.FullName -Destination ($receiveSourceFolder + "\" + $_.Name)
	}
}
[System.GC]::Collect()