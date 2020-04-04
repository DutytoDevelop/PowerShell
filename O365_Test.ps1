
Try {
    # Install the MSOnline module if this is first use
    Install-Module MSOnline
}

Catch{
    Write-Host "MSOnline Module Already Installed."
}
# Add the MSOnline module to the PowerShell session
Import-Module MSOnline
# Get credentials of Azure admin
$Credentials = Get-Credential
# Connect to Azure AD
Connect-MsolService -Credential $Credentials

Write-Host "Connecting to Office 365. Will print user list on login."

Get-MsolUser

<# Exchange Online #>
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid" -Credential $Credentials -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking

Write-Host "Connecting to Exchange Online..."
 
<# Office 365 Compliance #>
$ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.compliance.protection.outlook.com/powershell-liveid" -Credential $Credentials -Authentication "Basic" -AllowRedirection
Import-PSSession $ccSession -Prefix cc
#prefix "cc" is added to all Security & Compliance Center cmdlet names so you can run cmdlets that exist in both Exchange Online and the Security & Compliance Center in the same Windows PowerShell session. For example, Get-RoleGroup becomes Get-ccRoleGroup in the Security & Compliance Center. 

Write-Host "Connecting to Office 365 Compliance..."

# Function to check if $Server is remotely accessible
Function CloseSession ($Server) {

  Try {
   Remove-PSSession $Server
   Write-Host "Successfully closed session: $Server."
   }

  Catch {
          "Failed to close session: $Server."
        }
 }
