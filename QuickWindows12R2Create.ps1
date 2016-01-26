#Quickly Creates a Windows Server 2012 R2 Datacenter Virtual Machine
$cloudservice = Read-host -Prompt "Enter existing Cloud Service Name"
$vmname = Read-Host -Prompt "Enter Azure Virtual Machine Name"
$vmsize = Read-Host -Prompt "Enter Virtual Machine Size"
$user = Read-Host -Prompt "Enter local Username"
$userpw = Read-Host -Prompt "Enter local user password" -AsSecureString
$domain = Read-Host -Prompt "Enter domain for virtual machine to join"
$domainadmin = Read-Host -Prompt "Enter username that has permisions to add the machine to the domain... or something"
$domainadminpw = Read-Host -Prompt "Enter domain username's password" -AsSecureString
$vmimage = Get-AzureVMImage | Where { $_.ImageFamily -eq "Windows Server 2012 R2 Datacenter" } | sort PublishedDate -Descending | select -ExpandProperty ImageName -First 1
$vm = New-AzureVMConfig -Name $vmname -InstanceSize $vmsize -ImageName $vmimage #| Add-AzureProvisioningConfig -WindowsDomain –Password $userpw -ResetPasswordOnFirstLogon -JoinDomain $domain -Domain "contoso" -DomainUserName "domainadminuser" -DomainPassword "domainPassword"
