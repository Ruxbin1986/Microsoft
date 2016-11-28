#This Powershell Script deployed a 3-Tiered Azure Virtual Network with Forced-Tunneling effectively blocking off all internet access through Azure Public Networking Infrastructure.
$location = "US West" #Resoure Deployment Location
$vnetname = "VNet-USW-0-FT" #Azure Virtual Network Name
$gwipaddress = "1.2.3.4" #Public IP Address of Edge Router
$routetablename = "RouteTable-USW-0-FT" #Azure Route Table Name
$resourcegroupname = "VnetForcedTunnelingExample" #Azure Resource Group Name
#Creates a new new Azure Resource Group, used for all Networking Resources
New-AzureRmResourceGroup -Name $resourcegroupname -Location $location
#Defines a 3-Tiered Azure Virtual Network
$s1 = New-AzureRmVirtualNetworkSubnetConfig -Name "FrontendSubnet" -AddressPrefix "10.0.1.0/26"
$s2 = New-AzureRmVirtualNetworkSubnetConfig -Name "MidendSubnet" -AddressPrefix "10.0.1.64/26"
$s3 = New-AzureRmVirtualNetworkSubnetConfig -Name "BackendSubnet" -AddressPrefix "10.0.1.128/26"
$s4 = New-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -AddressPrefix "10.0.1.192/26"
#Deploys 3-Tiered Azure Virutal Network
$vnet = New-AzureRmVirtualNetwork -Name $vnetname -Location $location -ResourceGroupName $resourcegroupname -AddressPrefix "10.0.1.0/26" -Subnet $s1,$s2,$s3,$s4
#Creates Azure Local Network Gateways for Forced Tunneling
$lng1 = New-AzureRmLocalNetworkGateway -Name "DefaultSiteHQ" -ResourceGroupName $resourcegroupname -Location $location -GatewayIpAddress $gwipaddress -AddressPrefix "192.168.1.0/24"
$lng2 = New-AzureRmLocalNetworkGateway -Name "Branch1" -ResourceGroupName $resourcegroupname -Location $location -GatewayIpAddress $gwipaddress -AddressPrefix "192.168.2.0/24"
$lng3 = New-AzureRmLocalNetworkGateway -Name "Branch2" -ResourceGroupName $resourcegroupname -Location $location -GatewayIpAddress $gwipaddress -AddressPrefix "192.168.3.0/24"
$lng4 = New-AzureRmLocalNetworkGateway -Name "Branch3" -ResourceGroupName $resourcegroupname -Location $location -GatewayIpAddress $gwipaddress -AddressPrefix "192.168.4.0/24"
#Creates a new Azure Routing Table
New-AzureRmRouteTable –Name $routetablename -ResourceGroupName $resourcegroupname –Location $location
$rt = Get-AzureRmRouteTable –Name $routetablename -ResourceGroupName $resourcegroupname
#Creates a routing configurationdefault route to forward all traffic to the Azure Virtual Network Gateway
Add-AzureRmRouteConfig -Name "DefaultRoute" -AddressPrefix "0.0.0.0/0" -NextHopType VirtualNetworkGateway -RouteTable $rt
Set-AzureRmRouteTable -RouteTable $rt
#Applies Routing Table to Azure Virtual Network
$vnet = Get-AzureRmVirtualNetwork -Name $vnetname -ResourceGroupName $resourcegroupname
Set-AzureRmVirtualNetworkSubnetConfig -Name "MidendSubnet" -VirtualNetwork $vnet -AddressPrefix "10.0.1.64/26" -RouteTable $rt
Set-AzureRmVirtualNetworkSubnetConfig -Name "BackendSubnet" -VirtualNetwork $vnet -AddressPrefix "10.0.1.128/26" -RouteTable $rt
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
