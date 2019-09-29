[xml]$config = Get-Content -Path ($PSScriptRoot + "\" + "Config.xml")

if($config.Root.Tests.UseSameTestContentForReceiveAndSend -eq "True"){
	$sendTargetCopyFolder = $config.Root.Send.TargetCopyFolder
	$receiveSourceFolder = $config.Root.Receive.SourceFolder
	
	$fso = New-Object -ComObject scripting.filesystemobject
	if(Test-Path $receiveSourceFolder -PathType Container){
		$fso.DeleteFolder($receiveSourceFolder)
	}
	$fso.CreateFolder($receiveSourceFolder)
	
	Get-ChildItem -Verbose -Path $sendTargetCopyFolder | Foreach-object { 
		Copy-item -Verbose -Recurse -path $_.FullName -Destination ($receiveSourceFolder + "\" + $_.Name)
	}
}