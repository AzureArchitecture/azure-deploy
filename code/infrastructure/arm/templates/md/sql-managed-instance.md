# Azure SQL Managed Instance Deployment

This template creates an Azure SQL Managed Instance in the same resource group.

## Security Controls

The following security controls can be met through configuration of this template:
      [NIST Controls](security-controls.md):TBD

## File Details

Resource File: [sql-managed-instance.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/sql-managed-instance.json + )

Metadata File: [sql-managed-instance.metadata.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/sql-managed-instance.metadata.json + )

Test Parameters File: [sql-managed-instance.test.parameter.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/sql-managed-instance.test.parameter.json + )

## Parameters

Parameter name | Type | Description | DefaultValue
-------------- | ---- | ----------- | ------------
ResourceGroupName | string | The name of the Resource Group. | rg-azs-adap-dev-eus
administratorLogin | string | SQL Managed Instance Administrator name. | -
administratorLoginPassword | securestring | SQL Managed Instance Administrator password. | -
managedInstanceName | string | SQL Managed Instance name. | -
virtualNetworkResourceGroupName | string | SQL Managed Instance Virtual Network Resource Group name. | -
virtualNetworkName | string | SQL Managed Instance Virtual Network name. | -
subnetName     | string | SQL Managed Instance Virtual Network Subnet name. | -
skuName        | string | SQL Managed Instance SKU name. | GP_Gen5
skuEdition     | string | SQL Managed Instance SKU Edition name. | GeneralPurpose
storageSizeGb  | int  | SQL Managed Instance Storage Size in GB. | 32
vCores         | int  | SQL Managed Instance number of vCores. | 4
licenseType    | string | SQL Managed Instance License Type name. | LicenseIncluded
hardwareFamily | string | SQL Managed Instance Hardware Family name. | Gen5
dnsZonePartner | string | SQL Managed Instance DNS Zone Partner name. | -
collation      | string | SQL Managed Instance Collation name. | SQL_Latin1_General_CP1_CI_AS
proxyOverride  | string | SQL Managed Instance Proxy Override. | -
publicDataEndpointEnabled | bool | SQL Managed Instance Public Data Endpoint enabled. | -
timezoneId     | string | SQL Managed Instance Time Zone Id. | UTC
ApplicationName | string | Name of the application, service, or workload the resource is associated with. | ADAP
Approver       | string | Person responsible for approving costs related to this resource. | approver@company.org
BudgetAmount   | string | Money allocated for this application, service, or workload. | 0
BusinessUnit   | string | Top-level division of your company that owns the subscription or workload the resource belongs to. In smaller organizations, this tag might represent a single corporate or shared top-level organizational element. | CORP
CostCenter     | string | Business criticality of the application, workload, or service. | 8675-309
DR             | string | Business criticality of the application, workload, or service. | Mission-Critical
EndDate        | string | Date when the application, workload, or service is scheduled for retirement. | 9999-12-31
Env            | string | Deployment environment of the application, workload, or service. | dev
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
[parameters('managedInstanceName')] | Microsoft.Sql/managedInstances | 2015-05-01-preview
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
