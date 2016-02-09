Write-Host "----------------------------------------------------------------------"
Write-Host "Azure v1/ASM ADFS-Farm Provisioner Script"
Write-Host "This script will provision the following environment"
Write-Host "2x WAP, 2x ADFS, 2x DCs w/ load balancing elements"
Write-Host "Roles/Features will be installed but will require manual Configuration"
Write-Host "Assumes 2S2/Express Route is configured with appropriate Azure VNET DNS Settings"
Write-Host "Assumes Correct Azure Subscription and Storage Account selected"
Write-Host "----------------------------------------------------------------------"
$adfsname0 = Read-Host "Enter the name of the first Azure ADFS Server"
$adfsname1 = Read-Host "Enter the name of the second Azure ADFS Server"
$adfsavname = Read-Host "Enter the name of the ADFS Server Availiblity Set"
$wapname0 = Read-Host "Enter the name of the first Azure WAP Server"
$wapname1 = Read-Host "Enter the name of the second Azure WAP Server"
$wapavname = Read-Host "Enter the name of the WAP Server Availibility Set"
$adfscsname = Read-Host "Enter the name of the ADFS Cloud Service, example Contoso"
$wapcsname = Read-host "Enter the name of the WAP Cloud Service"
$vnetname = Read-host "Enter the name of Azure Virtual Network"
$location = Read-host "Enter location, example West US"
$vnetbackend = Read-host "Enter the name of backend subnet, ADFS Servers will be deployed here"
$vnetfrontend = Read-host "Enter the name of the frontend subnet, WAP Servers will be deployed here"
$credlocal=Get-Credential –Message "Type the name and password of the local administrator account."
$creddomain=Get-Credential –Message "Now type the name (not including the domain) and password of an account that has permission to add the machine to the domain."
$domaindns= Read-Host -Prompt "Domain FQDN ex; Contoso.com"
$domacctdomain= Read-Host -Prompt "Shortname Domain, eg Contoso"
$instancesize = "Medium"
#Retrives lastest Windows Server 2012 R2 Image
$family= "Windows Server 2012 R2 Datacenter"
$image=Get-AzureVMImage | where { $_.ImageFamily -eq $family } | sort PublishedDate -Descending | select -ExpandProperty ImageName -First 1
#Display to the user the image and date selected
Get-AzureVMImage | where { $_.ImageName -eq $image } | fl ImageFamily, PublishedDate
#Provisioning New Cloud Services
Write-Host "Provisioning New Cloud Services"
New-AzureService -ServiceName $adfscsname -Location $location
New-AzureService -ServiceName $wapcsname -Location $location
Write-Host "Cloud Services Provisioned, creating VMs..."
#Creates VM Objects
Write-Host "Creating VM Configuration Objects..."
$adfs0= New-AzureVMConfig -Name $adfsname0 -InstanceSize "Standard_D1" -ImageName $image -AvailabilitySetName $adfsavname
$adfs1= New-AzureVMConfig -Name $adfsname1 -InstanceSize "Standard_D1" -ImageName $image -AvailabilitySetName $adfsavname
$wap0= New-AzureVMConfig -Name $wapname0 -InstanceSize "Standard_D1" -ImageName $image -AvailabilitySetName $wapavname
$wap1= New-AzureVMConfig -Name $wapname1 -InstanceSize "Standard_D1" -ImageName $image -AvailabilitySetName $wapavname
#Add Provisioing Configuration
Write-Host "Creating VM Provisioning Objects"
$adfs0 | Add-AzureProvisioningConfig -AdminUsername $credlocal.GetNetworkCredential().Username -Password $credlocal.GetNetworkCredential().Password -WindowsDomain -Domain $domacctdomain -DomainUserName $creddomain.GetNetworkCredential().Username -DomainPassword $creddomain.GetNetworkCredential().Password -JoinDomain $domaindns
$adfs1 | Add-AzureProvisioningConfig -AdminUsername $credlocal.GetNetworkCredential().Username -Password $credlocal.GetNetworkCredential().Password -WindowsDomain -Domain $domacctdomain -DomainUserName $creddomain.GetNetworkCredential().Username -DomainPassword $creddomain.GetNetworkCredential().Password -JoinDomain $domaindns
$wap0 | Add-AzureProvisioningConfig -Windows -AdminUsername $credlocal.GetNetworkCredential().Username -Password $credlocal.GetNetworkCredential().Password
$wap1 | Add-AzureProvisioningConfig -Windows -AdminUsername $credlocal.GetNetworkCredential().Username -Password $credlocal.GetNetworkCredential().Password
#Defines appropriate subnet
$adfs0 | Set-AzureSubnet -SubnetNames $vnetbackend
$adfs1 | Set-AzureSubnet -SubnetNames $vnetbackend
$wap0 | Set-AzureSubnet -SubnetNames $vnetfrontend
$wap1 | Set-AzureSubnet -SubnetNames $vnetfrontend
Write-Host "Deploying VMs..."
#Deploys VMs
New-AzureVM –ServiceName $adfscsname -VMs $adfs0 -VNetName $vnetname
New-AzureVM –ServiceName $adfscsname -VMs $adfs1 -VNetName $vnetname
New-AzureVM –ServiceName $wapcsname -VMs $wap0 -VNetName $vnetname
New-AzureVM –ServiceName $wapcsname -VMs $wap1 -VNetName $vnetname
