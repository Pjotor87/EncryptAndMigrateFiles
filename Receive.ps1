[xml]$config = Get-Content -Path ($PSScriptRoot + "\" + "Config.xml")
Invoke-Expression "& `"$PSScriptRoot\_030_Receive_Copy.ps1`""
if($config.Root.Receive.DeleteWhenFinished -eq "True"){ Invoke-Expression "& `"$PSScriptRoot\_035_Receive_DeleteCopy.ps1`"" }
Invoke-Expression "& `"$PSScriptRoot\_040_Receive_Unzip.ps1`""
if($config.Root.Receive.DeleteWhenFinished -eq "True"){ Invoke-Expression "& `"$PSScriptRoot\_045_Receive_DeleteUnzip.ps1`"" }