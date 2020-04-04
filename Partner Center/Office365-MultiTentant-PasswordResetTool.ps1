<# 

Nicholas Hickam - Office 365 Administrator Multi-Tenant Password Reset Tool

Script Outline:

  Connect to Microsoft Online (MSOnline)
  
  Grab all tentants within Integritek's Partner Contract
  
  Reset password of selected user within selected tenant

#>

# Allows script to be run in cases where Powershell scripts are blocked from running by default
Set-ExecutionPolicy RemoteSigned 

# Ensures MSOnline module is installed
try{
    Install-Module MSOnline
}catch{
    Write-Output "MSOnline is already installed..."
}

# Import MSOnline module
Import-Module MSOnline


# Connect to MSOnline Service (MFA)
Connect-MsolService

# Get all IWSIT device display names
#Get-MsolDevice -All | Select-Object DisplayName | FL

# Gather list of each tenant's Partner Contract Data (Objects: Name, DefaultDomainName, ObjectId, and TenantID)
$MSolPartnerContractData = Get-MsolPartnerContract

# Split each tenant's Partner Contract Data by specific object
$CompanyNames = $MSolPartnerContractData.Name
$DomainNames = $MSolPartnerContractData.DefaultDomainName
$ObjectIds = $MSolPartnerContractData.ObjectId
$TenantIDs = $MSolPartnerContractData.TenantId

Get-MsolSubscription -TenantId $TenantIDs[5] | FL

# Connect to Aereon's AzureAD environment
Connect-AzureAD -TenantId $TenantIDs[5]

# Gets all objects 
Get-AzureADDevice -All $true | Get-Member

# Gets a device from Active Directory
Get-AzureADDevice -All $true | Select-Object DisplayName | FT

# Disconnect from Aereon's AzureAD environment
Disconnect-AzureAD

# Start GUI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Window                          = New-Object system.Windows.Forms.Form
$Window.ClientSize               = '601,365'
$Window.text                     = "Office 365 Administrator Multi-Tenant Password Reset Tool"
$Window.TopMost                  = $true

$CompanyNameLabel                = New-Object system.Windows.Forms.Label
$CompanyNameLabel.text           = "Company:"
$CompanyNameLabel.AutoSize       = $true
$CompanyNameLabel.enabled        = $false
$CompanyNameLabel.width          = 25
$CompanyNameLabel.height         = 10
$CompanyNameLabel.location       = New-Object System.Drawing.Point(11,15)
$CompanyNameLabel.Font           = 'Microsoft Sans Serif,10'

$UserNameLabel                = New-Object system.Windows.Forms.Label
$UserNameLabel.text           = "Users:"
$UserNameLabel.AutoSize       = $true
$UserNameLabel.enabled        = $false
$UserNameLabel.width          = 25
$UserNameLabel.height         = 10
$UserNameLabel.location       = New-Object System.Drawing.Point(24,62)
$UserNameLabel.Font           = 'Microsoft Sans Serif,10'


$TenantDropDown                  = New-Object system.Windows.Forms.ComboBox
$TenantDropDown.width            = 485
$TenantDropDown.height           = 30
$TenantDropDown.location         = New-Object System.Drawing.Point(78,12)
$TenantDropDown.Font             = 'Microsoft Sans Serif,10'
$TenantDropDown.Items.AddRange($CompanyNames)


$MSolUsersDropDown                  = New-Object system.Windows.Forms.ComboBox
$MSolUsersDropDown.width            = 485
$MSolUsersDropDown.height           = 30
$MSolUsersDropDown.location         = New-Object System.Drawing.Point(78,58)
$MSolUsersDropDown.Font             = 'Microsoft Sans Serif,10'


$Reset                           = New-Object system.Windows.Forms.Button
$Reset.text                      = "Reset Password"
$Reset.width                     = 122
$Reset.height                    = 50
$Reset.location                  = New-Object System.Drawing.Point(434,130)
$Reset.Font                      = 'Microsoft Sans Serif,10'

$PasswordLabel                   = New-Object system.Windows.Forms.Label
$PasswordLabel.text              = "Password:"
$PasswordLabel.AutoSize          = $true
$PasswordLabel.width             = 25
$PasswordLabel.height            = 10
$PasswordLabel.location          = New-Object System.Drawing.Point(114,134)
$PasswordLabel.Font              = 'Microsoft Sans Serif,10'

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Confirm Password:"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(65,170)
$Label1.Font                     = 'Microsoft Sans Serif,10'


$ConfirmPassword                 = New-Object system.Windows.Forms.MaskedTextBox
$ConfirmPassword.multiline       = $false
$ConfirmPassword.width           = 228
$ConfirmPassword.height          = 20
$ConfirmPassword.location        = New-Object System.Drawing.Point(184,163)
$ConfirmPassword.Font            = 'Microsoft Sans Serif,10'

$Password                        = New-Object system.Windows.Forms.MaskedTextBox
$Password.multiline              = $false
$Password.width                  = 228
$Password.height                 = 20
$Password.location               = New-Object System.Drawing.Point(183,131)
$Password.Font                   = 'Microsoft Sans Serif,10'

$PasswordPolicyAlert             = New-Object system.Windows.Forms.Label
$PasswordPolicyAlert.text        = "Password Policy:"
$PasswordPolicyAlert.AutoSize    = $true
$PasswordPolicyAlert.visible     = $true
$PasswordPolicyAlert.width       = 25
$PasswordPolicyAlert.height      = 10
$PasswordPolicyAlert.location    = New-Object System.Drawing.Point(224,196)
$PasswordPolicyAlert.Font        = 'Microsoft Sans Serif,10,style=Underline'

$PasswordPolicyBox               = New-Object system.Windows.Forms.TextBox
$PasswordPolicyBox.multiline     = $true
$PasswordPolicyBox.text          = 

"The password must contain at least one lowercase letter
The password must contain at least one uppercase letter
The password must contain at least one non-alphanumeric character
The password cannot contain any spaces, tabs, or line breaks
The length of the password must be 8-16 characters
The user name cannot be contained in the password"

$PasswordPolicyBox.width         = 571
$PasswordPolicyBox.height        = 128
$PasswordPolicyBox.enabled       = $false
$PasswordPolicyBox.location      = New-Object System.Drawing.Point(12,218)
$PasswordPolicyBox.Font          = 'Microsoft Sans Serif,10'

$Window.controls.AddRange(@($CompanyNameLabel,$UserNameLabel,$TenantDropDown,$UserSelectionLabel,$MSolUsersDropDown,$Reset,$PasswordLabel,$Label1,$ConfirmPassword,$Password,$PasswordPolicyAlert,$PasswordPolicyBox))

$Reset.Add_Click({ resetPassword })

$TenantDropDown.Add_SelectedValueChanged({ updateUsersAndDisplayPassPolicy })

function updateUsersAndDisplayPassPolicy { 

    try{
        Write-Host $TenantDropDown.SelectedItem.ToString()
        Write-Host $TenantDropDown.SelectedIndex.ToString()
    }catch{
        Write-Host "Fails Here"
    }
    
    try{
        $MSolUsersDropDown.Items.Clear()
    }catch{
    }

    $MSolUsers = Get-MsolUser -TenantId $TenantIDs[$TenantDropDown.SelectedIndex] -All
    try{
        $MSolUsernames = $MSolUsers.UserPrincipalName
        $MSolUsersDropDown.Items.AddRange($MSolUsernames)
    }catch{
        $MSolUsersDropDown.Items.Clear()
    }

}


function resetPassword {

    if($Password.text -eq $ConfirmPassword.text){
        Write-Host $TenantIDs[$TenantDropDown.SelectedIndex]
        Set-MsolUserPassword -UserPrincipalName $MSolUsersDropDown.SelectedItem -TenantId $TenantIDs[$TenantDropDown.SelectedIndex] -NewPassword $Password.text
    }

}

#Write your logic code here

[void]$Window.ShowDialog()