#Quickly Creates a Windows Server 2012 R2 Datacenter Virtual Machine
$cloudservice = Read-host -Prompt "Enter existing Cloud Service Name"
#Virtual Machine Name
$vmname = Read-Host -Prompt "Enter Azure Virtual Machine Name"
#Virtual Machine Size; Medium Recommended
$vmsize = Read-Host -Prompt "Enter Virtual Machine Size"
#Local Machine Username
$localuser = Read-Host -Prompt "Enter local Username"
#Local Machine Username Password
$localuserpw = Read-Host -Prompt "Enter local user password" -AsSecureString
#Domain Name
$domain = "xxxx"
#Complete FQDN
$fqdn = "xxxxx"
#Domain Administrator
$domainadmin = Read-Host -Prompt "Enter username that has permisions to add the machine to the domain... or something"
#Domain Administrator Password
$domainadminpw = Read-Host -Prompt "Enter domain username's password" -AsSecureString
#Selects the most recent Azure Windows 2012 R2 VM Image
$vmimage = Get-AzureVMImage | Where { $_.ImageFamily -eq "Windows Server 2012 R2 Datacenter" } | sort PublishedDate -Descending | select -ExpandProperty ImageName -First 1
#Creates a new Azure Virtual Machine Configuration
$vm = New-AzureVMConfig -Name $vmname -InstanceSize $vmsize -ImageName $vmimage
#Adds a provisioning configuration to the VM; joining the Domain
$vm | Add-AzureProvisioningConfig -AdminUsername $localuser -WindowsDomain –Password $localuserpw -JoinDomain $fqdn -Domain $domain -DomainUserName $domainadmin -DomainPassword $domainadminpw | New-AzureVM -ServiceName $cloudservice
