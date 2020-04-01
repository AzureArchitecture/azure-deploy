# common variables
$template = "synapse-dw"

$TemplateFile = "$PSScriptRoot\..\..\..\..\arm\templates\$template.json"
$TemplateParameterFile = "$PSScriptRoot\..\..\..\..\arm\templates\parameters\$template.test.parameter.json"
$TemplateMetadataFile = "$PSScriptRoot\..\..\..\..\arm\templates\$template.metadata.json"

#Set Config Values
$configurationFile = "$PSScriptRoot\..\..\..\..\scripts\ps\azure\config\adap-configuration.psm1"
Import-Module -Name $configurationFile -Force 
$config = Get-Configuration
      
# Set variabls from config file
$orgTag = $config.orgTag
$suffix = $config.suffix

$ResourceGroupName = "rg-$orgTag-test-$suffix"

Describe 'Metadata Test' {
    It 'Metadata file should exist' {
        $TemplateMetadataFile | Should -Exist
    }
}
