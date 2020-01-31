# Azure Storage Account Fileshare Deployment

This template creates a Storage Account Fileshare in a Storage Account.

## Security Controls

The following security controls can be met through configuration of this template:
      [NIST Controls](security-controls.md):TBD

## File Details

Resource File: [storage-account-fileshare.json](C:\AzureDevOps\Repos\xazxitive\AzureCoE\code\infrastructure\scripts\ps\azure\arm\..\..\..\..\arm\templates/storage-account-fileshare.json + )

Metadata File: [storage-account-fileshare.metadata.json](C:\AzureDevOps\Repos\xazxitive\AzureCoE\code\infrastructure\scripts\ps\azure\arm\..\..\..\..\arm\templates/storage-account-fileshare.metadata.json + )

Test Parameters File: [storage-account-fileshare.test.parameter.json](C:\AzureDevOps\Repos\xazxitive\AzureCoE\code\infrastructure\scripts\ps\azure\arm\..\..\..\..\arm\templates/storage-account-fileshare.test.parameter.json + )

## Parameters

Parameter name | Type | Description | DefaultValue
-------------- | ---- | ----------- | ------------
ResourceGroupName | string | The name of the Resource Group. | rg-xazx-adap-dev-eus
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
StorageAccountName | string | Name of the storage account the container belongs to | -
fileShareName  | string | Name of the file share | public
publicAccess   | string | Name of the file share | public

## Resources

Resource name | Type | ApiVersion
------------- | ---- | ----------
              |      |
              |      |
              |      |
              |      |
[variables('FileShareName')] | Microsoft.Storage/storageAccounts/fileServices/shares | 2019-04-01
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
