# Azure Analysis Services Instance Deployment

This template creates an Analysis Services Instance in the same resource group.

## Security Controls

The following security controls can be met through configuration of this template:
      [NIST Controls](security-controls.md):TBD

## File Details

Resource File: [analysis-services.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\arm\..\..\..\..\arm\templates/analysis-services.json + )

Metadata File: [analysis-services.metadata.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\arm\..\..\..\..\arm\templates/analysis-services.metadata.json + )

Test Parameters File: [analysis-services.test.parameter.json](C:\AzureDevOps\Repos\Quisitive\AzureCoE\code\infrastructure\scripts\ps\azure\arm\..\..\..\..\arm\templates/analysis-services.test.parameter.json + )

## Parameters

Parameter name | Type | Description | DefaultValue
-------------- | ---- | ----------- | ------------
analysisServicesName | string | -           | -
location       | string | -           | -
sku            | string | -           | -
admin          | string | -           | -
backupBlobContainerUri | string | -           | -
managedMode    | int  | -           | -

## Resources

Resource name | Type | ApiVersion
------------- | ---- | ----------
              |      |
              |      |
              |      |
              |      |
[parameters('analysisServicesName')] | Microsoft.AnalysisServices/servers | 2017-08-01
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
