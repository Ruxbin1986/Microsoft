#Makes a copy of an Azure ASM VM and may be deployed from the Image Gallery
$vmname = ""
$cloudservice = ""
$imagename = ""
Save-AzureVMImage -ServiceName $cloudservice -Name $vmname -ImageName $imagename -OSState Specialized -ImageLabel $imagename
$sandboxImg = Get-AzureVMImage -ImageName $imagename
