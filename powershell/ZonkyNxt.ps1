. .\powershell\ClassZonkyNxt.ps1

[ZonkyNxt]$zonky = [ZonkyNxt]::new()
$zonky.connect()
$zonky.get_active_investments()



