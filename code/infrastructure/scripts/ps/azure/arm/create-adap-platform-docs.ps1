#
# Azure Resource Manager documentation definitions
#
# A function to break out parameters from an ARM template
 [CmdletBinding()]
  param(
)

$psscriptsRoot = $PSScriptRoot
#Folder Locations
$psCommonDirectory = "$psscriptsRoot\..\common"
$psARMScriptsDirectory = "$psscriptsRoot\..\arm"
$psConfigDirectory = "$psscriptsRoot\..\config"
$psAzureDirectory = "$psscriptsRoot\..\"
$infrastructureDirectory = "$psscriptsRoot\..\..\..\..\"
$mdDirectory = "$psscriptsRoot\..\..\..\..\..\..\md"
$armTemplatesDirectory = "$psscriptsRoot\..\..\..\..\arm\templates"
$armAlertDirectory = "$psscriptsRoot\..\..\..\..\arm\alert"
$armAlertsDirectory = "$psscriptsRoot\..\..\..\..\arm\alert\alerts"
$armBluePrintDirectory = "$psscriptsRoot\..\..\..\..\arm\blueprint"
$armPolicyDirectory = "$psscriptsRoot\..\..\..\..\arm\policy"
$armPoliciesDirectory = "$psscriptsRoot\..\..\..\..\arm\policy\policies"
$armRBACDirectory = "$psscriptsRoot\..\..\..\..\arm\rbac\roles"
$armRunbookDirectory = "$psscriptsRoot\..\..\..\..\arm\automation\runbooks"

$armTemplatesMDDirectory = "$mdDirectory\arm"
$actionGroupsMDDirectory = "$mdDirectory\actiongroups"
$alertsMDDirectory = "$mdDirectory\alerts"
$policiesMDDirectory = "$mdDirectory\policies"
$rbacMDDirectory = "$mdDirectory\rbac"

  try{
    $azureCommon = ('{0}\{1}' -f  $psCommonDirectory, 'azure-common.psm1')
    Import-Module -Name $azureCommon -Force
    Import-Module PSDocs -Force

    #Set Config Values
    $configurationFile = ('{0}\{1}' -f  $psConfigDirectory, 'adap-configuration')
    Import-Module -Name $configurationFile -Force
    $config = Get-Configuration
  }
  catch {
    Write-Host -ForegroundColor RED    "Error importing required PS modules: $azureCommon, $configurationFile"
    $PSCmdlet.ThrowTerminatingError($_)
    Exit
  }

# Create ARM Template MD Files
$rootDirectory = "$armTemplatesDirectory"
$mdDirectory = $armTemplatesMDDirectory
Set-Location -Path "$rootDirectory"
$env:METADATA_PATH = $rootDirectory
# $files = Get-ChildItem $rootDirectory\*.json
foreach($file in Get-ChildItem $rootDirectory\*.json)
{
  if (-not $file.Name | Select-String -Pattern "metadata" -SimpleMatch){
  $fileName = $file.Name.Replace(".json","")
  $env:TEMPLATE_CURRENT = $fileName
  $templateName = $fileName
  $env:templateName = $fileName
  $env:TEMPLATE_PATH = "$rootDirectory"
  Write-Information  "    Creating Azure ARM Template markdown document for $fileName"
  Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $mdDirectory
  }
}
Exit
   
# Create Policy MD Files
$rootDirectory = "$armPolicyDirectory\policies"
$mdDirectory = $policiesMDDirectory
Set-Location -Path "$rootDirectory"
$env:METADATA_PATH = $rootDirectory
foreach($parentDir in Get-ChildItem -Directory)
{
  foreach($childDir in Get-ChildItem -Path $parentDir -Directory)
  {
    $env:TEMPLATE_CURRENT = $childDir
    $templateName = $childDir.Name
    $env:templateName = $childDir.Name
    $env:TEMPLATE_PATH = "$rootDirectory\$parentDir\$childDir"
    Write-Information  "    Creating Azure Policy markdown document for $childDir"
    Invoke-PSDocument -Path $psARMScriptsDirectory/create-policy-md.ps1 -InstanceName $templateName -OutputPath $mdDirectory
  }
}
Write-Information  "    "

# Create Action Group MD Files
$rootDirectory = "$armAlertDirectory\actiongroup"
$mdDirectory = $actionGroupsMDDirectory
Set-Location -Path "$rootDirectory"
$env:METADATA_PATH = $rootDirectory
foreach($parentDir in Get-ChildItem -Directory)
{
  foreach($childDir in Get-ChildItem -Path $parentDir -Directory)
  {
    $env:ACTION_GROUP_CURRENT = $childDir
    $templateName = $childDir.Name
    $env:templateName = $childDir.Name
    $env:ACTION_GROUP_PATH = "$rootDirectory\$parentDir\$childDir"
    Write-Information  "    Creating Azure Action Group markdown document for $childDir"
    Invoke-PSDocument -Path $psARMScriptsDirectory/create-action-group-md.ps1 -InstanceName $templateName -OutputPath $mdDirectory
  }
}
Write-Information  "    "

# Create Alert MD Files
$rootDirectory = "$armAlertDirectory\alerts"
$mdDirectory = $alertsMDDirectory
Set-Location -Path "$rootDirectory"
$env:METADATA_PATH = $rootDirectory
foreach($parentDir in Get-ChildItem -Directory)
{
  foreach($childDir in Get-ChildItem -Path $parentDir -Directory)
  {
    $env:TEMPLATE_CURRENT = $childDir
    $templateName = $childDir.Name
    $env:templateName = $childDir.Name
    $env:TEMPLATE_PATH = "$rootDirectory\$parentDir\$childDir"
    Write-Information  "    Creating Azure Alert markdown document for $childDir"
    Invoke-PSDocument -Path $psARMScriptsDirectory/create-alert-md.ps1 -InstanceName $templateName -OutputPath $mdDirectory
  }
}


Exit
Write-Information  "    "






$rootDirectory = "$armTemplatesDirectory"
$env:ARM_TEMPLATE_PATH = "$armTemplatesDirectory"

$templateName = "storage-account"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "storage-account-container"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "storage-account-fileshare"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "sql-database"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
# Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "sql-managed-instance"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "sql-server"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "servicebus-namespace"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "event-hub-namespace"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "servicebus-topic"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "servicebus-topic-authrule"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "servicebus-topic-sub"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "servicebus-queue-authrule"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
# Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "servicebus-ipfilter"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
# Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "servicebus-firewall-vnetrule"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "ip-address"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "bastion-host"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "analysis-services"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "keyvault"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "logic-app"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "synapse-dw"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "stream-analytics-job"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "data-factory"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."

$templateName = "data-lake-store"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/create-arm-template-md.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory
Write-Information "    Creating $templateName.md file."
