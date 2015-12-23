####
## This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
## THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
## INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
## We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that 
## You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on 
## Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, 
## including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
####
## Remove/comment the following line to enable this file run.
#EXIT
#Variables, modify as needed to change Azure Network Infrastructure naming and physical location
$resourcegroup = 'NetworkInfrastructure' #Name of the Resource Group where Azure Networking Objects will be stored
$location = 'West US' #Network Infrastructure Location
$virtualnetwork = 'VNet0' #Virtual Network Name
$localnetworkgateway = 'VNet0LocalNetworkGateway' #Local Network IP Addressing Range and On-Premise Gateway IP
$azurenetworkgatewayipaddress = 'VNet0GatewayPublicIP' #Public IP of Azure Virtual Network Gateway
$virtualnetworkgateway = 'VNet0Gateway' #Azure Virtual Network Gateway
$virutalnetworkgatewayconnection = 'VNet0GatewayConnections' #Holds the Virutal Network Gateway IP and On-Premise GW IP Addresses
$subscriptionname = 'Ruxbin' #Name of the Azure Subscription
$onpremisegw = '1.2.3.4' #Public IP Address of On-Premise Router; ex Cisco ASA
$sharedkey = 'abc123'
#Selects the Azure Subscription
Select-AzureRmSubscription -SubscriptionName $subscriptionname
#Create a Resource Group for all associated objects
New-AzureRmResourceGroup -Name $resourcegroup -Location $location
#Creates a virtual network with 3 subnets
$subnet1 = New-AzureRMVirtualNetworkSubnetConfig -Name 'InternalSubnet' -AddressPrefix '10.10.7.128/26'
$subnet2 = New-AzureRMVirtualNetworkSubnetConfig -Name 'ExternalSubnet' -AddressPrefix '10.10.7.192/27'
$subnet3 = New-AzureRMVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix '10.10.7.240/28'
New-AzureRmVirtualNetwork -Name $virtualnetwork -ResourceGroupName $resourcegroup -Location $location -AddressPrefix 10.10.7.128/25 -Subnet $subnet1, $subnet2, $subnet3
#Creates Local Network Gateway, this references your On-Premise Network
New-AzureRmLocalNetworkGateway -Name $localnetworkgateway -ResourceGroupName $resourcegroup -Location $location -GatewayIpAddress $onpremisegw -AddressPrefix '10.10.7.2/25' #@('10.0.0.0/24','20.0.0.0/24') Use this formatting for mutliple ranges
#Creates a Public IP Address for the Azure Gateway, this must be dynamically assigned and will not change
$gwpip = New-AzureRmPublicIpAddress -Name $azurenetworkgatewayipaddress -ResourceGroupName $resourcegroup -Location $location -AllocationMethod Dynamic
#Configures Azure Gateway Addressing
$vnet = Get-AzureRmVirtualNetwork -Name $virtualnetwork -ResourceGroupName $resourcegroup
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet
$gwipconfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name gwipconfig1 -SubnetId $subnet.Id -PublicIpAddressId $gwpip.Id
#Creates the Virtual Network Gateway
New-AzureRmVirtualNetworkGateway -Name $virtualnetworkgateway -ResourceGroupName $resourcegroup -Location $location -IpConfigurations $gwipconfig -GatewayType Vpn -VpnType Routebased
#Retrives the Azure Gateway Public IP Address, this is the address you will point your router at for creating the IPsec Tunnel
Get-AzureRmPublicIpAddress -Name $azurenetworkgatewayipaddress -ResourceGroupName $resourcegroup
#Establishes the VPN Tunnel
$gateway1 = Get-AzureRmVirtualNetworkGateway -Name $virtualnetworkgateway -ResourceGroupName $resourcegroup
$local = Get-AzureRmLocalNetworkGateway -Name $localnetworkgateway -ResourceGroupName $resourcegroup
New-AzureRmVirtualNetworkGatewayConnection -Name $virutalnetworkgatewayconnection -ResourceGroupName $resourcegroup -Location $location -VirtualNetworkGateway1 $gateway1 -LocalNetworkGateway2 $local -ConnectionType IPsec -RoutingWeight 10 -SharedKey $sharedkey
