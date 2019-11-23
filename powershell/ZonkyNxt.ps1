. .\powershell\ClassZonkyNxt.ps1

[ZonkyNxt]$zonky = [ZonkyNxt]::new()
$zonky.connect('D:\OneDrive\Repos\ZonkyNxt\ZonkyNxt.pwd')
$zonky.get_active_investments()
Remove-Variable zonky



