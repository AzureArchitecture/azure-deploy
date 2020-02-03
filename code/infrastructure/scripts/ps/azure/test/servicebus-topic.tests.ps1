# common variables
$ResourceGroupName = "rg-test"
$template = "service-bus-namespace"

$TemplateFile = "$PSScriptRoot\..\..\..\..\arm\templates\$template.json"
$TemplateParameterFile = "$PSScriptRoot\..\..\..\..\arm\templates\parameters\$template.test.parameter.json"
$TemplateMetadataFile = "$PSScriptRoot\..\..\..\..\arm\templates\$template.metadata.json"

Describe 'Metadata Test' {
    It 'Metadata file should exist' {
        $TemplateMetadataFile | Should -Exist
    }
}

if (Test-Path $TemplateFile){
Describe "Service Bus Topic Deployment Tests" -Tag "functional" {
  Context "When a Service Bus Topic is deployed" {
    $TemplateParameters = @{
      ServiceBusNamespaceName = "sb-chp-adap-test"
    }
    $TestTemplateParams = @{
      ResourceGroupName       = $ResourceGroupName
      TemplateFile            = $TemplateFile
      TemplateParameterObject = $TemplateParameters
    }

    $DebugPreference = 'SilentlyContinue'
    $output = Test-AzResourceGroupDeployment -ResourceGroupName "$ResourceGroupName" -TemplateFile "$TemplateFile" -TemplateParameterFile "$TemplateParameterFile" 5>&1
    write-host $output
    $DebugPreference = 'SilentlyContinue'

    It "Should be deployed successfully" {
      $output | Should Be $null
    }
  }
}
}