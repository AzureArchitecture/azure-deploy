#
# Azure Resource Manager documentation definitions
#

# A function to break out resources from an ARM template
function Get-TemplateResources {
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {
        $template = Get-Content $Path | ConvertFrom-Json;
        foreach ($property in $template.resources.PSObject.Properties) {
            [PSCustomObject]@{
              Name = $property.Value.name
              Type = $property.Value.type
              ApiVersion = $property.Value.apiVersion
            }
        }
    }
}

# A function to break out parameters from an ARM template
function GetTemplateParameter {
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {
        $template = Get-Content $Path | ConvertFrom-Json;
        foreach ($property in $template.parameters.PSObject.Properties) {
            [PSCustomObject]@{
              Name = $property.Name
              Type = $property.Value.type
              Description = If($property.Value.metadata.description){$property.Value.metadata.description} else {"-"}
              DefaultValue = If($property.Value.DefaultValue){$property.Value.DefaultValue} else {"-"}
            }
        }
    }
}
# A function to get the parameter values from an ARM template
function Get-TemplateParameterValues {
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {
        $template = Get-Content $Path | ConvertFrom-Json;
        foreach ($property in $template.parameters.PSObject.Properties) {
            [PSCustomObject]@{
                Name = $property.Name
                Value = $property.Value.metadata.value
            }
        }
    }
}

# A function to import metadata
function Get-TemplateMetadata {
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {
        $metadata = Get-Content $Path | ConvertFrom-Json;
        return $metadata;
    }
}

# Description: A definition to generate markdown for an ARM template
document 'arm-template' {
    $metadata = Get-TemplateMetadata -Path $env:METADATA_PATH/azuredeploy.metadata.json;
    $parameters = GetTemplateParameter -Path $env:TEMPLATE_PATH/azuredeploy.json;
    $resources = Get-TemplateResources -Path  $env:TEMPLATE_PATH/azuredeploy.json;
    $jsonParameters = Get-Content -Path $env:TEMPLATE_PATH/azuredeploy.parameters.json;

    # TOC
    Section 'TOC' {
      '[[_TOC_]]
'
    }

    # Set document title
    Title "Alert Definition: $env:templateName"

    # Write opening line
    $metadata.Description

      # Add each parameter to a table
    Section 'Security Controls' {
      'The following security controls can be met through configuration of this template:
      [NIST Controls](security-controls.md):' + $metadata.securityControls
    }

   Section 'File Details' {
      'Resource File: [' + 'azuredeploy' + '.json](' +  $env:TEMPLATE_PATH + '/' + 'azuredeploy' + '.json + )'
      'Metadata File: [' + 'azuredeploy' + '.metadata.json](' +  $env:METADATA_PATH + '/' + 'azuredeploy' + '.metadata.json + )'
      'Parameters File: [' + 'azuredeploy' + '.parameter.json](' +  $env:TEMPLATE_PATH + '/' + 'azuredeploy' + '.parameters.json + )'
    }

    # Add each parameter to a table
    Section 'Parameters' {
      $parameters | Table -Property @{ Name = 'Parameter name'; Expression = { $_.Name }},Type, Description,DefaultValue
      #$parameters | Table -Property Name, Type
    }

      # Add each Resources to a table
    Section 'Resources' {
      $resources | Table -Property @{ Name = 'Resource name'; Expression = { $_.Name }},Type,ApiVersion
    }

    # Generate example command line
    Section 'Use the template' {
        Section 'PowerShell' {
            'New-AzResourceGroupDeployment -Name <deployment-name> -ResourceGroupName <resource-group-name> -TemplateFile <path-to-template>' | Code powershell
        }

        Section 'Azure CLI' {
            'az group deployment create --name <deployment-name> --resource-group <resource-group-name> --template-file <path-to-template>' | Code text
        }
    }

      # Documentation
    Section 'Documentation' {
      'Coming Soon...'
    }
}
