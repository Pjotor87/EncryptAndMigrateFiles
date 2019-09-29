[xml]$config = Get-Content -Path ($PSScriptRoot + "\" + "Config.xml")

if($config.Root.Send.ZipFromSourceFolder -eq "True"){ Invoke-Expression "& `"$PSScriptRoot\_010_Send_Zip.ps1`"" }
[System.GC]::Collect()
if($config.Root.Send.DeleteWhenFinished -eq "True"){ Invoke-Expression "& `"$PSScriptRoot\_015_Send_DeleteZip.ps1`"" }
[System.GC]::Collect()
if($config.Root.Send.CopyFromZipToTargetFolder -eq "True"){ Invoke-Expression "& `"$PSScriptRoot\_020_Send_Copy.ps1`"" }
[System.GC]::Collect()
if($config.Root.Send.DeleteWhenFinished -eq "True"){ Invoke-Expression "& `"$PSScriptRoot\_025_Send_DeleteCopy.ps1`"" }
[System.GC]::Collect()