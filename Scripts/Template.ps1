#-----------------------------------------------------
# Working with modules
#-----------------------------------------------------
$env:PSModulePath.Split(";")

Get-module
Get-module -ListAvailable

Import-module AzureRM.Compute
Import-module AzureRM.Storage
Import-module AzureRM.Network
#Import-module AzureRM.ApiManagement
#Import-module AzureRM.Automation
#Import-module AzureRM.Backup
#Import-module AzureRM.KeyVault
#Import-module AzureRM.WebSites
#Import-module AzureRM.Resources

cd 'D:\All Projects\PowerShell\ARM-Library\scripts'

#-----------------------------------------------------
# Interactive Authentication
#-----------------------------------------------------
Add-AzureRmAccount

#-----------------------------------------------------
# non-interactive authentication
#-----------------------------------------------------
#$userName = "dennis@fullscale180.com"
#$securePassword = ConvertTo-SecureString -String "<password here>" -AsPlainText -Force
#$cred = New-Object System.Management.Automation.PSCredential($userName, $securePassword)
#Add-AzureAccount -Credential $cred 

#-----------------------------------------------------
# list tenants or subscriptions
#-----------------------------------------------------
Get-AzureRmTenant

Get-AzureRmSubscription 

#-----------------------------------------------------
# Select the Subscription by subscriptionId or by Tenant Id
#-----------------------------------------------------
$subscriptionId = "11dc728f-f13f-4a5e-ab73-a0a2563d7edd"
Select-AzureRMSubscription -SubscriptionId $subscriptionId

#$tenantid = '1b50b25c-00b2-4a8d-8911-77742e0ba0fd'  # Universal Widget
#Select-AzureRmSubscription -TenantId $tenantId

#-----------------------------------------------------
# getting Help
#-----------------------------------------------------
get-command -Module "AzureRM.Compute" 
get-command -Module "AzureRM.Compute" -Verb Get
Get-help Get-AzureRMVMIMage -Detailed

#-----------------------------------------------------
# Finding VM Images
#-----------------------------------------------------
Get-AzureRmVMImagePublisher -Location "WestUS" 
Get-AzureRmVMImageOffer     -Location "WestUS" -PublisherName "MicrosoftWindowsServer"
Get-AzureRmVMImageSku       -Location "WestUS" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer"
Get-AzureRmVMImage          -Location "WestUS" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-DataCenter" 
Get-AzureRmVMImage          -Location "WestUS" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-DataCenter" -Version "4.0.20160229"

get-help Get-AzureRmVMImage -examples

Get-AzureRmVMImageOffer -Location "WestUS" -PublisherName "Oracle"
Get-AzureRmVMImageSku -Location "WestUS" -PublisherName "Oracle" -Offer "Oracle-Linux-7" 
Get-AzureRmVMImage -Location "WestUS" -PublisherName "Oracle" -Offer "Oracle-Linux-7" -Skus "OL70"

#-----------------------------------------------------
# Finding VMs
#-----------------------------------------------------
Get-AzureRMVM | format-table 
Get-AzureRMVM -ResourceGroupName "VM-LOADBALANCED"
Get-AzureRmVM | where {$_.Name -eq "BravoX-vm1"} | ft

#-----------------------------------------------------
# Working with Resouce Groups and Tags
#-----------------------------------------------------
$location = "westus"
$rgName = "VM-StandAlone"
$tags = @(@{name = "product"; value="velocity"}, @{name ="client"; value="contoso"})
$rg = New-AzureRmResourceGroup -Location $location -Name $rgName -Tag $tags

