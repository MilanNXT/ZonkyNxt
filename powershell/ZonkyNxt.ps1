Add-Type -AssemblyName System.Web
. D:\OneDrive\Repos\ZonkyNxt\powershell\ClassZonkyNxt.ps1

[ZonkyNxt]$zonky = [ZonkyNxt]::new()
$zonky.connect('D:\OneDrive\Repos\ZonkyNxt\ZonkyNxt.pwd')
$zonky.get_marketplace()
$zonky.get_investments()
#Remove-Variable zonky



