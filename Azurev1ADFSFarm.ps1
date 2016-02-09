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
#Retrives lastest Windows Server 2012 R2 Image
$family= "Windows Server 2012 R2 Datacenter"
$image=Get-AzureVMImage | where { $_.ImageFamily -eq $family } | sort PublishedDate -Descending | select -ExpandProperty ImageName -First 1
#Display to the user the image and date selected
Get-AzureVMImage | where { $_.ImageName -eq $image } | fl ImageFamily, PublishedDate
#Provisioning New Cloud Services
Write-Host "Provisioning New Cloud Services"
New-AzureService -ServiceName $adfscsname -Location $location
New-AzureService -ServiceName $adfscsname -Location $location
Write-Host "Cloud Services Provisioned, creating VMs..."
