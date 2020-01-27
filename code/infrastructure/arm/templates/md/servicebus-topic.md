# Azure Service Bus Topic Deployment

This template creates an Azure Service Bus Topic in the provided Azure Service Bus Namespace.

## Security Controls

The following security controls can be met through configuration of this template:
      [NIST Controls](security-controls.md):TBD

## File Details

Resource File: [servicebus-topic.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/servicebus-topic.json + )

Metadata File: [servicebus-topic.metadata.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/servicebus-topic.metadata.json + )

Test Parameters File: [servicebus-topic.test.parameter.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\reports\..\..\..\..\arm\templates/servicebus-topic.test.parameter.json + )

## Parameters

Parameter name | Type | Description | DefaultValue
-------------- | ---- | ----------- | ------------
ServiceBusNamespaceName | string | Name of an existing Service Bus namespace to add the topic to | -
ServiceBusTopicName | string | Topic name to add to Service Bus | -
messageDefaultTTL | string | Default time to live (defaults to 90 days) | P90D
topicMaxSizeMb | int  | Default topic max size (in Mb) | 1024
ResourceGroupName | string | The name of the Resource Group. | rg-azs-adap-dev-eus
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
[concat(parameters('ServiceBusNamespaceName'), '/', parameters('ServiceBusTopicName'))] | Microsoft.ServiceBus/namespaces/topics | 2017-04-01
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
