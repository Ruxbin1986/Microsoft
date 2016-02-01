$family="Windows Server 2012 R2 Datacenter"
$image=Get-AzureVMImage | where { $_.ImageFamily -eq $family } | sort PublishedDate -Descending | select -ExpandProperty ImageName -First 1
$vmname= Read-Host -Prompt "Virtual Machine Name"
$vmsize= Read-Host -Prompt "Virtual Machine Size"
$vm1=New-AzureVMConfig -Name $vmname -InstanceSize $vmsize -ImageName $image
$cred1=Get-Credential –Message "Type the name and password of the local administrator account."
$cred2=Get-Credential –Message "Now type the name (not including the domain) and password of an account that has permission to add the machine to the domain."
$domaindns= Read-Host -Prompt "Domain FQDN ex; Contoso.com"
$domacctdomain= Read-Host -Prompt "Shortname Domain, eg Contoso"
$vm1 | Add-AzureProvisioningConfig -AdminUsername $cred1.GetNetworkCredential().Username -Password $cred1.GetNetworkCredential().Password -WindowsDomain -Domain $domacctdomain -DomainUserName $cred2.GetNetworkCredential().Username -DomainPassword $cred2.GetNetworkCredential().Password -JoinDomain $domaindns
$vm1 | Set-AzureSubnet -SubnetNames "BackendSubnet"
$disksize=20
$disklabel="Database"
$lun=0
$hcaching="None"
$vm1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $disksize -DiskLabel $disklabel -LUN $lun -HostCaching $hcaching
$svcname="Ruxbin"
$vnetname="Group InfrastructureCUSW-0 VNetCUSW-0"
New-AzureVM –ServiceName $svcname -VMs $vm1 -VNetName $vnetname
