#-----------------------------------------------------
# Import utilities module
#-----------------------------------------------------
Import-module AzureRM.Compute
Import-module AzureRM.Storage
Import-module AzureRM.Network
#Import-module AzureRM.ApiManagement
#Import-module AzureRM.Automation
#Import-module AzureRM.Backup
#Import-module AzureRM.KeyVault
#Import-module AzureRM.WebSites
#Import-module AzureRM.Resources


#-----------------------------------------------------
# Authenticate
#-----------------------------------------------------
Add-AzureRmAccount

#-----------------------------------------------------
# Select the Subscription by subscriptionId or by Tenant Id
#-----------------------------------------------------
$subscriptionId = "11dc728f-f13f-4a5e-ab73-a0a2563d7edd"
Select-AzureRMSubscription -SubscriptionId $subscriptionId

#$tenantid = '1b50b25c-00b2-4a8d-8911-77742e0ba0fd'  # Universal Widget
#Select-AzureRmSubscription -TenantId $tenantId

#-----------------------------------------------------
# Create a new deployment
#-----------------------------------------------------
$deployName = "AzureDeploy"
$location = "westus"
$tags = @(@{ Name = "product"; Value = "test" } )



### A single standalone VM
$rgName = "VM-StandAlone" 
$parameters = @{"Prefix" = "AlphaX";}
$rg = New-AzureRMResourceGroup -name $rgName -location $location -tags $tags
New-AzureRMResourceGroupDeployment -ResourceGroupName $rgName -Name $deployName -TemplateFile .\StandAloneVirtualMachines.json -TemplateParameterObject $parameters 

### Load Balanced set of VMs
$rgName = "VM-LoadBalanced" 
$parameters = @{"Prefix" = "BravoX"; "VmInstances" = 1;}
$rg = New-AzureRMResourceGroup -name $rgName -location $location -tags $tags
New-AzureRMResourceGroupDeployment -ResourceGroupName $rgName -Name $deployName -TemplateFile .\LoadBalancedVirtualMachines.json -TemplateParameterObject $parameters 

### Load Balanced set of VMs with a Jumpbox
$rgName = "VM-LoadBalancedWithJumpbox" 
$parameters = @{"Prefix" = "CharlieX"; "VmInstances" = 1;}
$rg = New-AzureRMResourceGroup -name $rgName -location $location -tags $tags
New-AzureRMResourceGroupDeployment -ResourceGroupName $rgName -Name $deployName -TemplateFile .\LoadBalancedVirtualMachinesWithJumpbox.json -TemplateParameterObject $parameters 

### Load Balanced set of multi-Nic VMs multiple
$rgName = "VM-LoadBalancedMultiNic" 
$parameters = @{"Prefix" = "DeltaX"; "VmInstances" = 1;}
$rg = New-AzureRMResourceGroup -name $rgName -location $location -tags $tags
New-AzureRMResourceGroupDeployment -ResourceGroupName $rgName -Name $deployName -TemplateFile .\LoadBalancedMultiNicVirtualMachines.json -TemplateParameterObject $parameters 

### Load Balanced VM scaleset
$rgName = "VM-LoadBalancedScaleSet" 
$parameters = @{"Prefix" = "DeltaX"; "VmInstances" = 1;}
$rg = New-AzureRMResourceGroup -name $rgName -location $location -tags $tags
New-AzureRMResourceGroupDeployment -ResourceGroupName $rgName -Name $deployName -TemplateFile .\VirtualMachineScaleSet.json -TemplateParameterObject $parameters 


