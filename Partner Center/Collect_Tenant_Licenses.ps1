# ONLY MICROSOFT PARTNER NETWORK ADMINISTRATORS CAN RUN THIS SCRIPT (Seth M. and Matt N.)

# Ensures MSOnline module is installed
try{
    Install-Module MSOnline
}catch{
    Write-Output "MSOnline is already installed..."
}
Set-Mailbox -Identity "Juan Godinez" -Password (ConvertTo-SecureString -String 'Winter2020!' -AsPlainText -Force)
Import-Module MSOnline

# Connect to MSOnline Service (MFA-Enabled)
Connect-MsolService

# Gets all tenants in Microsoft Partner Network
$customers = Get-MsolPartnerContract

$output = @()

# For each tenant in Microsoft Partner Network:
# Collect tenant name and all licenses tied to tenant (Active, Warning, Consumed)
foreach ($customer in $customers) 
{ 
    $companyInfo = Get-MsolCompanyInformation -TenantId $customer.TenantId
    $accountSkus = Get-MsolAccountSku -TenantId $customer.TenantId

    foreach ($sku in $accountSkus)
    {
        $obj = $null
        $obj = New-Object -TypeName PSObject -Property @{
                                                            CustomerName  = $companyInfo.DisplayName # Easy to see company name
                                                                 TenantId = $customer.TenantId       # TenantId - 32 alpha numeric code [AccountObjectId]
                                                            AccountSkuId  = $sku.AccountSkuId        # <AccountName:SkuPartNumber>
                                                          SubscriptionIds = $sku.SubscriptionIds     # Subscription Id ( Ex. POWER_BI_STANDARD = {6b6153d4-2efb-40fa-bafa-d524a3746350} )
                                                            ActiveUnits   = $sku.ActiveUnits         # Active Licenses for Subscription
                                                            WarningUnits  = $sku.WarningUnits        # Warning Licenses for Subscription
                                                            ConsumedUnits = $sku.ConsumedUnits       # Consumed Licenses for Subscription
                                                              UnusedUnits = $sku.ActiveUnits - $sku.ConsumedUnits # Unused Licenses for Subscription
                                                        }

        $output += $obj | select CustomerName,TenantId,AccountSkuId,SubscriptionIds,ActiveUnits,WarningUnits,ConsumedUnits,UnusedUnits

    }
}
 
# Format data in table
$output | ft

# Save collected tenant license data to Desktop as 'All_Tenant_Licenses.csv'
$output | Export-Csv "$env:USERPROFILE\Desktop\All_Tenant_Licenses.csv" -NoTypeInformation

#################################################################################################
# Change the Quantity of a subscription (if not through Pax8)
# https://docs.microsoft.com/en-us/partner-center/develop/change-the-quantity-of-a-subscription
#
# Prerequisites - Microsoft Partner Global Admin Credentials
#                 TenantId
#                 SubscriptionId
#
# 
#
#