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
# Working with Resouce Groups and Tags
#-----------------------------------------------------
Get-AzureLocation
Get-AzureLocation | where {$_.Name -like "*US"} | ft

$location = "westus"
$rgName = "VM-Single"
$tags = @(@{name = "product"; value="velocity"}, @{name ="client"; value="contoso"})
$rg = New-AzureRmResourceGroup -Location $location -Name $rgName -Tag $tags

#-----------------------------------------------------
# Storage
#-----------------------------------------------------
$prefix = "Cheeta"
$saName = "${prefix}storage".ToLower()
$sa = New-AzureRmStorageAccount -ResourceGroupName $rgName -Location $location -Type Standard_LRS -Name $saName -Tags $tags


#-----------------------------------------------------
# Network
#-----------------------------------------------------
$vnetName = "${prefix}-vnet"
$vnetAddr = "10.0.1.0/21"

$snet = @()
$snetName = "Subnet1"
$snetAddr = "10.0.1.0/24"
$snet += New-AzureRmVirtualNetworkSubnetConfig -Name $snetName -AddressPrefix $snetAddr
$snetName = "Subnet2"
$snetAddr = "10.0.2.0/24"
$snet += New-AzureRmVirtualNetworkSubnetConfig -Name $snetName -AddressPrefix $snetAddr
$snetName = "Subnet3"
$snetAddr = "10.0.3.0/24"
$snet += New-AzureRmVirtualNetworkSubnetConfig -Name $snetName -AddressPrefix $snetAddr

$vnet = New-AzureRmVirtualNetwork -AddressPrefix $vnetAddr -ResourceGroupName $rgName -Location $location -Name $vnetName -Subnet $snet


#-----------------------------------------------------
# Create an availability set for this environment
#-----------------------------------------------------
$asName = "${prefix}-as"
$avSet = New-AzureRMAvailabilitySet -Name $asName -ResourceGroupName $rgName -Location $location

#-----------------------------------------------------
# Public IP Address
#-----------------------------------------------------
$vipName = "${prefix}-vip3"
$dnsName = "${prefix}-dns".ToLower()
$vip = New-AzureRmPublicIpAddress -ResourceGroupName $rgName -Location $location -Name $vipName -AllocationMethod dynamic # -DomainNameLabel $dnsName 


#-----------------------------------------------------
# Network Interface on public IP
#-----------------------------------------------------
$nicName = "${prefix}-nic3"
$subnet = $vnet.Subnets | where {$_.Name -eq "SubNet1"}
$nic = New-AzureRmNetworkInterface -ResourceGroupName $rgName -Location $location -Name $nicName -PublicIpAddress $vip -Subnet $subnet

#-----------------------------------------------------
# Virtual Machine sizes
#-----------------------------------------------------
Get-AzureRmVMSize -Location $location | where {$_.NumberOfCores -lt 4 -and $_.MemoryInMB -gt 7000} | ft
$vmSize = "Standard_A2"


#-----------------------------------------------------
# Virtual Machine 
#-----------------------------------------------------
$vmName = "${prefix}-vm3"

# get the storage account
$sa = Get-AzureRMStorageAccount -Name $saName -ResourceGroupName $rgName

# get the network interface
$nic = Get-AzureRMNetworkInterface -Name $nicName -ResourceGroupName $rgName

# Create a new VM Config
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize 

# Add OS Disk to the VM Config
$diskLabel = "OSDisk"
$diskName  = "${vmName}-${diskLabel}"
$diskCont  = "vhds/"
$diskBlob  = $sa.PrimaryEndpoints.Blob.ToString() 
$diskUri   = "${diskBlob}${diskCont}${diskName}.vhd"
$vmConfig  = Set-AzureRmVMOSDisk -VM $vmConfig -Name $diskLabel -VhdUri $diskUri -CreateOption fromImage

# Add data disk(s) to the VM Config
$diskLun   = 0
$diskSize  = 1023
$diskLabel = "datadisk${diskLun}"
$diskName  = "${vmName}-${diskLabel}"
$diskCont  = "vhds/"
$diskBlob  = $sa.PrimaryEndpoints.Blob.ToString() 
$diskUri   = "${diskBlob}${diskCont}${diskName}.vhd"
$vmConfig  = Add-AzureRMVMDataDisk -VM $vmConfig -Name $disklabel -DiskSizeInGB $disksize -VhdUri $diskUri -LUN $diskLUN -CreateOption empty

# Attach network interface(s) to the VM Config
$vmConfig  = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id -Primary

#----------------------------
# WINDOWS CONFIG
#----------------------------
 # Add Source Image to the VM Config
 #$imgPublisher = "MicrosoftWindowsServer"
 #$imgOffer     = "WindowsServer"
 #$imgSkus      = "2012-R2-Datacenter"
 #$imgVersion   = "latest"
 #$vmConfig     = Set-AzureRmVMSourceImage -VM $vmConfig -PublisherName $imgPublisher -Offer $imgOffer -Skus $imgSkus -Version $imgVersion

 # Add Windows OS Profile
 #$vmUser   = "AdminUser"
 #$vmPass   = ConvertTo-SecureString "P@ssword1" -AsPlainText -Force
 #$vmCreds  = New-Object System.Management.Automation.PSCredential ($vmUser, $vmPass);
 #$vmTZone  = "Pacific Standard Time"
 #$vmConfig = Set-AzureRMVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -Credential $vmCreds -TimeZone $vmTZone -ProvisionVMAgent -EnableAutoUpdate 

#----------------------------
# LINUX CONFIG
#----------------------------
 # Add LINUX Source Image to the VM Config
 $imgPublisher = "Oracle"
 $imgOffer     = "Oracle-Linux-7"
 $imgSkus      = "OL70"
 $imgVersion   = "latest"
 $vmConfig     = Set-AzureRmVMSourceImage -VM $vmConfig -PublisherName $imgPublisher -Offer $imgOffer -Skus $imgSkus -Version $imgVersion 

 # Add LINUX OS Profile
 $vmUser   = "AdminUser"
 $vmPass   = ConvertTo-SecureString "P@ssword1" -AsPlainText -Force
 $vmCreds  = New-Object System.Management.Automation.PSCredential ($vmUser, $vmPass);
 $vmConfig = Set-AzureRMVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -DisablePasswordAuthentication -Credential $vmCreds

 # Add SSH public key
 $publicKeyFilePath = "D:\DAngeline\Documents\SSH Keys\Azure SSH Key"
 $keyData = Get-Content -Path $publicKeyFilePath
 Add-AzureRmVMSshPublicKey -VM $vmConfig -KeyData $keyData -Path "/home/${vmUser}/.ssh/authorized_keys"

# create the virtual machine
$vm = New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vmConfig -Tags $tags 
        















