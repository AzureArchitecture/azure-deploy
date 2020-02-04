#
# Azure Resource Manager documentation definitions
#

# A function to break out resources from an ARM template
function GetTemplateResources {
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
function GetTemplateParameterValues {
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
function GetTemplateMetadata {
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
    $metadata = GetTemplateMetadata -Path $env:ARM_TEMPLATE_PATH/$env:ARM_TEMPLATE_CURRENT.metadata.json;
    $parameters = GetTemplateParameter -Path $env:ARM_TEMPLATE_PATH/$env:ARM_TEMPLATE_CURRENT.json;
    $resources = GetTemplateResources -Path  $env:ARM_TEMPLATE_PATH/$env:ARM_TEMPLATE_CURRENT.json;
    $testParameters = GetTemplateParameterValues -Path $env:ARM_TEMPLATE_PATH/parameters/$env:ARM_TEMPLATE_CURRENT.test.parameter.json;
    $jsonParameters = Get-Content -Path $env:ARM_TEMPLATE_PATH/parameters/$env:ARM_TEMPLATE_CURRENT.test.parameter.json;

    # Set document title
    Title $metadata.itemDisplayName

    # Write opening line
    $metadata.Description

      # Add each parameter to a table
    Section 'Security Controls' {
      'The following security controls can be met through configuration of this template:
      [NIST Controls](security-controls.md):' + $metadata.securityControls
    }

   Section 'File Details' {
      'Resource File: [' + $env:ARM_TEMPLATE_CURRENT + '.json](' +  $env:ARM_TEMPLATE_PATH + '/' + $env:ARM_TEMPLATE_CURRENT+ '.json + )'
      'Metadata File: [' + $env:ARM_TEMPLATE_CURRENT + '.metadata.json](' +  $env:ARM_TEMPLATE_PATH + '/' + $env:ARM_TEMPLATE_CURRENT+ '.metadata.json + )'
      'Test Parameters File: [' + $env:ARM_TEMPLATE_CURRENT + '.test.parameter.json](' +  $env:ARM_TEMPLATE_PATH + '/' + $env:ARM_TEMPLATE_CURRENT+ '.test.parameter.json + )'
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
