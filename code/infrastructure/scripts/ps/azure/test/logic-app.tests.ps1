# common variables
$ResourceGroupName = "rg-test"
$template = "logic-app"

$TemplateFile = "$PSScriptRoot\..\..\..\..\arm\templates\$template.json"
$TemplateParameterFile = "$PSScriptRoot\..\..\..\..\arm\templates\parameters\$template.test.parameter.json"
$TemplateMetadataFile = "$PSScriptRoot\..\..\..\..\arm\templates\$template.metadata.json"

Describe 'Metadata Test' {
    It 'Metadata file should exist' {
        $TemplateMetadataFile | Should -Exist
    }
}

if (Test-Path $TemplateFile){
Describe "Logic App Deployment Tests" -Tag "functional" {
  Context "When Logic App is deployed" {
    $TemplateParameters = @{
      logicAppName = "adaplogicAppTest"
    }
    $TestTemplateParams = @{
      ResourceGroupName       = $ResourceGroupName
      TemplateFile            = $TemplateFile
      TemplateParameterObject = $TemplateParameters
    }

    $DebugPreference = 'SilentlyContinue'
    $output = Test-AzResourceGroupDeployment -ResourceGroupName "$ResourceGroupName" -TemplateFile "$TemplateFile" -TemplateParameterFile "$TemplateParameterFile" 5>&1
    write-host $output
    if ($output) {
        write-host $output.details.details.message
    }
    $DebugPreference = 'SilentlyContinue'

    It "Should be deployed successfully" {
      $output | Should Be $null
    }
  }
}
}
