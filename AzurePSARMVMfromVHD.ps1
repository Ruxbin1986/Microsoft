$ResourceGroup = "example"
$location = "eastus"
$StorageAccount = "storage"
$VMName = "Example01"
$Interface = $VMname + "NIC"
$Subnet = "FrontSubnet"
$VNet = "vnetUSEast"
$osdisk = "osdisk1"
$vnet = Get-AzureRmVirtualNetwork -Name $vnet -ResourceGroupName $resourcegroup
$Interface = New-AzureRmNetworkInterface -Name $Interface -ResourceGroupName $ResourceGroup -Location "eastus" -SubnetId $VNet.Subnets[0].Id
$VMSize = "Standard_A2"
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
$StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroup
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDisk + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $osdisk -VhdUri $OSDiskUri -CreateOption Attach -Windows
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine
