# Azure Bastion Host Deployment

This template creates an Azure Bastion Host in the same Shared resource group.

## Security Controls

The following security controls can be met through configuration of this template:
      [NIST Controls](security-controls.md):TBD

## File Details

Resource File: [bastion-host.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/bastion-host.json + )

Metadata File: [bastion-host.metadata.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/bastion-host.metadata.json + )

Test Parameters File: [bastion-host.test.parameter.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/bastion-host.test.parameter.json + )

## Parameters

Parameter name | Type | Description | DefaultValue
-------------- | ---- | ----------- | ------------
SharedResourceGroupName | string | The name of the Resource Group. | rg-azs-shared-dev-eus
NetworkResourceGroupName | string | The name of the Resource Group. | rg-azs-network-dev-eus
virtualNetworkName | string | The name of the virtual network for the Bastion Host. | vnet-azs-dev
bastionHostName | string | The name of the Bastion Host. | bast-azs-shared-dev-eus
subnetName     | string | The id of the Bastion Host subnet. | AzureBastionSubnet
publicIpAddressName | string | The name of the Bastion Host public IP address. | -
ApplicationName | string | Name of the application, service, or workload the resource is associated with. | ADAP
Approver       | string | Person responsible for approving costs related to this resource. | approver@company.org
BudgetAmount   | string | Money allocated for this application, service, or workload. | 0
BusinessUnit   | string | Top-level division of your company that owns the subscription or workload the resource belongs to. In smaller organizations, this tag might represent a single corporate or shared top-level organizational element. | CORP
CostCenter     | string | Business criticality of the application, workload, or service. | 8675-309
DR             | string | Business criticality of the application, workload, or service. | Mission-Critical
EndDate        | string | Date when the application, workload, or service is scheduled for retirement. | 9999-12-31
Env            | string | Deployment environment of the application, workload, or service. | test
Owner          | string | Owner of the application, workload, or service. | owner@company.org
Requester      | string | User who requested the creation of this application. | requester@company.org
ServiceClass   | string | Service level agreement level of the application, workload, or service. | Gold
StartDate      | string | Date when the application, workload, or service was first deployed. | 2020-01-01

## Resources

Resource name | Type | ApiVersion
------------- | ---- | ----------
              |      |
              |      |
              |      |
              |      |
System.Object[] | System.Object[] | System.Object[]
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
