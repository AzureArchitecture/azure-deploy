# Azure Service Bus Firewall VNet Rule Deployment

This template creates an Azure Service Bus Firewall VNet Rule in the provided Azure Service Bus Namespace.

## Security Controls

The following security controls can be met through configuration of this template:
      [NIST Controls](security-controls.md):TBD

## File Details

Resource File: [servicebus-firewall-vnetrule.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\arm\..\..\..\..\arm\templates/servicebus-firewall-vnetrule.json + )

Metadata File: [servicebus-firewall-vnetrule.metadata.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\arm\..\..\..\..\arm\templates/servicebus-firewall-vnetrule.metadata.json + )

Test Parameters File: [servicebus-firewall-vnetrule.test.parameter.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\arm\..\..\..\..\arm\templates/servicebus-firewall-vnetrule.test.parameter.json + )

## Parameters

Parameter name | Type | Description | DefaultValue
-------------- | ---- | ----------- | ------------
servicebusName | string | The name of the Service Bus Namespace to ad the VNet rule to. | -
subnetNames    | array | An array of Subnet names to add to the VNet rule. | -
vnetName       | string | Name of the VNet that contains the subnets. | -
vnetResourceGroup | string | Name of the Vnet's resource group. | -
ipRules        | array | An array of IP Addresses. | -

## Resources

Resource name | Type | ApiVersion
------------- | ---- | ----------
              |      |
              |      |
              |      |
              |      |
[variables('namespaceNetworkRuleSetName')] | Microsoft.ServiceBus/namespaces/networkruleset | 2018-01-01-preview
              |      |
              |      |
              |      |

## Use the template

### PowerShell

```powershell
New-AzResourceGroupDeployment -Name <deployment-name> -ResourceGroupName <resource-group-name> -TemplateFile <path-to-template>
```

### Azure CLI

```text
az group deployment create --name <deployment-name> --resource-group <resource-group-name> --template-file <path-to-template>
```

## Documentation

Coming Soon...
