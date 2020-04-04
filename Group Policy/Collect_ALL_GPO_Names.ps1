Import-Module GroupPolicy
Get-GPO -All | Select-Object DisplayName | Format-List
