Set-StrictMode -Version latest
Add-Type -AssemblyName System.Web
#. D:\OneDrive\Repos\ZonkyNxt\powershell\ClassZonkyNxt.ps1
. D:\Repo\ZonkyNxt\powershell\ClassZonkyNxt.ps1

$zonky = [ZonkyNxt]::new()
#$zonky.connect('D:\OneDrive\Repos\ZonkyNxt\ZonkyNxt.pwd')
$zonky.connect('D:\Users\Milan\OneDrive\Repos\ZonkyNxt\ZonkyNxt.pwd')
$zonky.GetMarketplace()
$zonky.GetInvestments()
#Remove-Variable zonky

