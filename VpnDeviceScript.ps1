# Microsoft Corporation
# Windows Azure Virtual Network
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
EXIT
# This configuration template applies to Microsoft RRAS running on Windows Server 2012 R2.
# It configures an IPSec VPN tunnel connecting your on-premise VPN device with the Azure gateway.
# !!! Please notice that we have the following restrictions in our support for RRAS:
# !!! 1. Only IKEv2 is currently supported
# !!! 2. Only route-based VPN configuration is supported.
# !!! 3. Admin priveleges are required in order to run this script
$vpninterfacename = 'AzureVirtualNetwork' #Name of the RRAS VPN Connection
$azurevnetgwpublicip = '1.2.3.4' #Public IP Address of Azure Virtual Network Gateway
Function Invoke-WindowsApi( 
    [string] $dllName,  
    [Type] $returnType,  
    [string] $methodName, 
    [Type[]] $parameterTypes, 
    [Object[]] $parameters 
    )
{
  ## Begin to build the dynamic assembly 
  $domain = [AppDomain]::CurrentDomain 
  $name = New-Object Reflection.AssemblyName 'PInvokeAssembly' 
  $assembly = $domain.DefineDynamicAssembly($name, 'Run') 
  $module = $assembly.DefineDynamicModule('PInvokeModule') 
  $type = $module.DefineType('PInvokeType', "Public,BeforeFieldInit") 
  $inputParameters = @() 
  for($counter = 1; $counter -le $parameterTypes.Length; $counter++) 
  { 
     $inputParameters += $parameters[$counter - 1] 
  } 
  $method = $type.DefineMethod($methodName, 'Public,HideBySig,Static,PinvokeImpl',$returnType, $parameterTypes) 
  ## Apply the P/Invoke constructor 
  $ctor = [Runtime.InteropServices.DllImportAttribute].GetConstructor([string]) 
  $attr = New-Object Reflection.Emit.CustomAttributeBuilder $ctor, $dllName 
  $method.SetCustomAttribute($attr) 
  ## Create the temporary type, and invoke the method. 
  $realType = $type.CreateType() 
  $ret = $realType.InvokeMember($methodName, 'Public,Static,InvokeMethod', $null, $null, $inputParameters) 
  return $ret
}
Function Set-PrivateProfileString( 
    $file, 
    $category, 
    $key, 
    $value) 
{
  ## Prepare the parameter types and parameter values for the Invoke-WindowsApi script 
  $parameterTypes = [string], [string], [string], [string] 
  $parameters = [string] $category, [string] $key, [string] $value, [string] $file 
  ## Invoke the API 
  [void] (Invoke-WindowsApi "kernel32.dll" ([UInt32]) "WritePrivateProfileString" $parameterTypes $parameters)
}
# Install RRAS role
Import-Module ServerManager
Install-WindowsFeature RemoteAccess -IncludeManagementTools
Add-WindowsFeature -name Routing -IncludeManagementTools
# !!! NOTE: A reboot of the machine might be required here after which the script can be executed again.
# Install S2S VPN
Import-Module RemoteAccess
if ((Get-RemoteAccess).VpnS2SStatus -ne "Installed")
{
  Install-RemoteAccess -VpnType VpnS2S
}
# Add and configure S2S VPN interface
Add-VpnS2SInterface -Protocol IKEv2 -AuthenticationMethod PSKOnly -NumberOfTries 3 -ResponderAuthenticationMethod PSKOnly -Name $vpninterfacename -Destination $azurevnetgwpublicip -IPv4Subnet @("10.10.0.0/25:100","10.10.0.128/26:100","10.10.0.240/28:100") -SharedSecret abc123
Set-VpnServerIPsecConfiguration -EncryptionType MaximumEncryption
Set-VpnS2Sinterface -Name $vpninterfacename -InitiateConfigPayload $false -Force
# Set S2S VPN connection to be persistent by editing the router.pbk file (required admin priveleges)
Set-PrivateProfileString $env:windir\System32\ras\router.pbk $azurevnetgwpublicip "IdleDisconnectSeconds" "0"
Set-PrivateProfileString $env:windir\System32\ras\router.pbk $azurevnetgwpublicip "RedialOnLinkFailure" "1"
# Restart the RRAS service
Restart-Service RemoteAccess
# Dial-in to Azure gateway
Connect-VpnS2SInterface -Name $vpninterfacename
