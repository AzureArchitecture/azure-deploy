# Az.Security
Powershell Module for working with Azure Security

Clone/Download the files from the repository into a specific folder and then run the script ".\Import-Az.Security.ps1".  

This will import all of the modules correctly so they can be executed like any standard powershell command.  

A module for retrieving information from the Microsoft.Security API. This module leverages the Get-AzResource cmdlet to return data from the API, so you will need to Login-AzAccount for these functions to work.

```
Get-Command -Module AzSecurity

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Get-AzSecurityAlert                           1.0        AzSecurity
Function        Get-AzSecurityDataCollection                  1.0        AzSecurity
Function        Get-AzSecurityPolicy                          1.0        AzSecurity
Function        Get-AzSecurityStatus                          1.0        AzSecurity
Function        Get-AzSecurityTask                            1.0        AzSecurity
```
## Get-AzSecurityAlert
```
NAME
    Get-AzSecurityAlert

SYNTAX
    Get-AzSecurityAlert [-Subscription] <Object> [[-ResourceType] {Microsoft.Compute/availabilitySets | Microsoft.Compute/virtualMachines | Microsoft.Compute/virtualMachines/extensions |
    Microsoft.Network/connections | Microsoft.Network/loadBalancers | Microsoft.Network/localNetworkGateways | Microsoft.Network/networkInterfaces | Microsoft.Network/networkSecurityGroups |
    Microsoft.Network/publicIPAddresses | Microsoft.Network/virtualNetworkGateways | Microsoft.Network/virtualNetworks | Microsoft.Storage/storageAccounts | microsoft.insights/alertrules |
    Microsoft.Sql/servers | Microsoft.Sql/servers/databases | Microsoft.ClassicStorage/storageAccounts | microsoft.cdn/profiles | microsoft.cdn/profiles/endpoints | Microsoft.ClassicCompute/domainNames |
    microsoft.insights/autoscalesettings | microsoft.backup/BackupVault | microsoft.insights/components | Microsoft.Web/certificates | Microsoft.Web/serverFarms | Microsoft.Web/sites |
    SuccessBricks.ClearDB/databases | Microsoft.OperationalInsights/workspaces | Microsoft.OperationsManagement/solutions}]  [<CommonParameters>]


ALIASES
    None


REMARKS
    None
```

## Get-AzSecurityDataCollection
```
NAME
    Get-AzSecurityDataCollection

SYNTAX
    Get-AzSecurityDataCollection [-Subscription] <Object> [-ResourceGroupName] <string> [-VMName] <string> [-ResultType] {patch | baseline | antimalware}  [<CommonParameters>]


ALIASES
    None


REMARKS
    None
```

## Get-AzSecurityPolicy
```
NAME
    Get-AzSecurityPolicy

SYNTAX
    Get-AzSecurityPolicy [-Subscription] <Object> [[-Name] <string>]  [<CommonParameters>]


ALIASES
    None


REMARKS
    None
```

## Get-AzSecurityStatus
```
NAME
    Get-AzSecurityStatus

SYNTAX
    Get-AzSecurityStatus [-Subscription] <Object> [[-ResourceType] {Microsoft.Compute/availabilitySets | Microsoft.Compute/virtualMachines | Microsoft.Compute/virtualMachines/extensions |
    Microsoft.Network/connections | Microsoft.Network/loadBalancers | Microsoft.Network/localNetworkGateways | Microsoft.Network/networkInterfaces | Microsoft.Network/networkSecurityGroups |
    Microsoft.Network/publicIPAddresses | Microsoft.Network/virtualNetworkGateways | Microsoft.Network/virtualNetworks | Microsoft.Storage/storageAccounts | microsoft.insights/alertrules |
    Microsoft.Sql/servers | Microsoft.Sql/servers/databases | Microsoft.ClassicStorage/storageAccounts | microsoft.cdn/profiles | microsoft.cdn/profiles/endpoints | Microsoft.ClassicCompute/domainNames |
    microsoft.insights/autoscalesettings | microsoft.backup/BackupVault | microsoft.insights/components | Microsoft.Web/certificates | Microsoft.Web/serverFarms | Microsoft.Web/sites |
    SuccessBricks.ClearDB/databases | Microsoft.OperationalInsights/workspaces | Microsoft.OperationsManagement/solutions}]  [<CommonParameters>]


ALIASES
    None


REMARKS
    None
```

## Get-AzSecurityTask
```
NAME
    Get-AzSecurityTask

SYNTAX
    Get-AzSecurityTask [-Subscription] <Object>  [<CommonParameters>]


ALIASES
    None


REMARKS
    None
```
