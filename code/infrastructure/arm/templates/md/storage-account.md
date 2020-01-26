# Azure Storage Account Deployment

This template creates an Azure Storage Account in the same resource group.

## Security Controls

The following security controls can be met through configuration of this template:
      [NIST Controls](security-controls.md):CP-6.a, CP-6.b, CP-6 (1), CP-6 (2).

## File Details

Resource File: [storage-account.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/storage-account.json + )

Metadata File: [storage-account.metadata.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/storage-account.metadata.json + )

Test Parameters File: [storage-account.test.parameter.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/storage-account.test.parameter.json + )

## Parameters

Parameter name | Type | Description | DefaultValue
-------------- | ---- | ----------- | ------------
ResourceGroupName | string | The name of the Resource Group. | rg-chp-adap-dev-eus
StorageAccountName | string | The name of the storage account. | stgchpadapdeveus
AccountType    | string | The type of storage account. | Standard_LRS
StorageKind    | string | The kind of storage account. | StorageV2
AccessTier     | string | This setting is required if using Blob Storage as the storageKind, otherwise can be left blank | Hot
ApplicationName | string | Name of the application, service, or workload the resource is associated with. | ADAP
Approver       | string | Person responsible for approving costs related to this resource. | approver@company.org
BudgetAmount   | string | Money allocated for this application, service, or workload. | 0
BusinessUnit   | string | Top-level division of your company that owns the subscription or workload the resource belongs to. In smaller organizations, this tag might represent a single corporate or shared top-level organizational element. | CORP
CostCenter     | string | Business criticality of the application, workload, or service. | 8675-309
DR             | string | Business criticality of the application, workload, or service. | Mission-Critical
EndDate        | string | Date when the application, workload, or service is scheduled for retirement. | 9999-12-31
Env            | string | Deployment environment of the application, workload, or service. | Test
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
[parameters('StorageAccountName')] | Microsoft.Storage/storageAccounts | 2018-02-01
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
