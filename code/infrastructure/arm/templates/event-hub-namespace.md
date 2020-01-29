# Event Hub Namespace 
(event-hub-namespace.json)

## Introduction

This template is used to create [Event Hub Namespace](https://docs.microsoft.com/en-us/azure/templates/microsoft.eventhub/allversions).

## Security Controls

The following security controls can be met through configuration of this template:

* [Controls](event-hub-namespace-controls.md): CP-6.a, CP-6.b, CP-6 (1), CP-6 (2).  

## Parameter format

```JSON
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "EventHubNamespaceName": {
      "value": "ehns-xazx-adap-test-eus"
    },
    "ResourceGroupName": {
      "value": "rg-xazx-adap-dev-eus"
    },
    "SkuName": {
      "value": "Basic"
    },
    "SkuTier": {
      "value": "Basic"
    },
    "SkuCapacity": {
      "value": "1"
    },
    "maximumThroughputUnits": {
      "value": "0"
    },
    "zoneRedundant": {
      "value": false
    },
    "isAutoInflateEnabled": {
      "value": false
    },
    "Default Tags": {
      "value": "..."
    }
  }
}
```

## Parameter Values

|Name        |Type   |Required |Value                               |
|------------|-------|---------|------------------------------------|
|StorageAccountName     |string |Yes       | The name the Azure Storage Account.|
|ResourceGroupName| string |Yes | The name of the resource group to create the storage account in.|
|storageAccountPrefix|string|Yes| A prefix to add to the storage account name.  Note any prefix over 11 characters will be truncated.|
|AccountType |enum   |Yes | The type of storage account.  - Standard_LRS, Standard_GRS, Standard_RAGRS, Standard_ZRS, Premium_LRS, Premium_ZRS, Standard_GZRS, Standard_RAGZRS
|StorageKind|enum| Yes| Indicates the type of storage account. - Storage, StorageV2, BlobStorage|

## Default Settings
|Name        |Type   |Value |Description                               |
|------------|-------|---------|------------------------------------|
|supportsHttpsTrafficOnly|bool|True|Allows https traffic only to storage service if sets to true.|
|advancedThreatProtectionEnabled| bool|True|Indicates if advanced threat protection should be enabled.  Advanced Threat Protection provides an additional layer of security intelligence that detects unusual and potentially harmful attempts to access or exploit storage accounts.  Note additinal costs will occur if turned on. See [Storage Advanced threat Protection](https://docs.microsoft.com/en-us/azure/storage/common/storage-advanced-threat-protection) for more details.|

## Tags ##
- **Display Name**-A description of the azure resource or service.
- **Application name**-Name of the application, service, or workload the resource is associated with.
- **Approver name**-Person responsible for approving costs related to this resource.
- **Budget required/approved**-Money allocated for this application, service, or workload.
- **Business unit**-Top-level division of your company that owns the subscription or workload the resource belongs to. In smaller organizations, this tag might represent a single corporate or shared top-level organizational element.
- **Cost center**-Accounting cost center associated with this resource.
- **Disaster recovery**-Business criticality of the application, workload, or service.
- **End date of the project**-Date when the application, workload, or service is scheduled for retirement.
- **Environment**-Deployment environment of the application, workload, or service.
- **Owner name**-Owner of the application, workload, or service.
- **Requester name**-User who requested the creation of this application.
- **Service class**-Service level agreement level of the application, workload, or service.
- **Start date of the project**-Date when the application, workload, or service was first deployed.

## Documentation
| Topic | Reference |
| --- | --- |
|Event Hub Namespace Documentation| https://docs.microsoft.com/en-us/azure/storage/|
||Event Hub Namespace Introduction| https://docs.microsoft.com/en-us/azure/storage/common/storage-introduction|

## Replication & Scalability

| Topic | Reference |
| --- | --- |
|Azure Storage Replication| https://azure.microsoft.com/en-us/documentation/articles/storage-redundancy/|
|Azure Storage Scalability and Performance Targets| https://docs.microsoft.com/e-us/azure/storage/common/storage-scalability-targets|
|What to do if an Azure Storage outage occurs| https://docs.microsoft.com/en-us/azure/storage/common/storage-disaster-recovery-guidance|


## History

|Date       | Change                |
|-----------|-----------------------|
|20191231 | Inital Version|
|20200110 | Updated documentation|
