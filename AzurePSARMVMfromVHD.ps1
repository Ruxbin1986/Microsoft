$ResourceGroupName = "example"
$location = "eastus"
$StorageAccount = "storage"
$InterfaceName = "Netint14"
$Subnet1Name = "FrontSubnet"
$VNetName = "vnetUSEast"
$VMName = "Example01"
$osdisk = "osdisk1"
$vnet = Get-AzureRmVirtualNetwork -Name VNetUSEast -ResourceGroupName ""
$Interface = New-AzureRmNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location "eastus" -SubnetId $VNet.Subnets[0].Id
$VMSize = "Standard_A2"
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
$StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName "okok"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDisk + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $osdisk -VhdUri $OSDiskUri -CreateOption Attach -Windows
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine 
