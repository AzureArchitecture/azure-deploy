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
$armTemplatesDirectory = "$psscriptsRoot\..\..\..\..\arm\templates"
$armTemplatesMDDirectory = "$psscriptsRoot\..\..\..\..\arm\templates\md"
$armAlertDirectory = "$psscriptsRoot\..\..\..\..\arm\alert"
$armBluePrintDirectory = "$psscriptsRoot\..\..\..\..\arm\blueprint"
$armPolicyDirectory = "$psscriptsRoot\..\..\..\..\arm\policy"
$armRBACDirectory = "$psscriptsRoot\..\..\..\..\arm\rbac\roles"
$armRunbookDirectory = "$psscriptsRoot\..\..\..\..\arm\automation\runbooks"

  try{
    $azureCommon = ('{0}\{1}' -f  $psCommonDirectory, 'azure-common')
    #Import-Module -Name $azureCommon -Force
    Import-Module PSDocs -Force

    #Set Config Values
    $configurationFile = ('{0}\{1}' -f  $psConfigDirectory, 'adap-configuration')
    Import-Module -Name $configurationFile -Force
    $config = Get-Configuration
  }
  catch {
    Write-Host -ForegroundColor RED    "Error importing reguired PS modules: $azureCommon, $configurationFile"
    $PSCmdlet.ThrowTerminatingError($_)
    Exit
  }

$rootDirectory = "$armTemplatesDirectory"
$env:ARM_TEMPLATE_PATH = "$armTemplatesDirectory"

$templateName = "storage-account"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "storage-account-container"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "storage-account-fileshare"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "sql-database"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
# Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "sql-managed-instance"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "sql-server"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "servicebus-namespace"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "event-hub-namespace"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "servicebus-topic"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "servicebus-topic-authrule"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "servicebus-topic-sub"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "servicebus-queue-authrule"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
# Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "servicebus-ipfilter"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
# Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "servicebus-firewall-vnetrule"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "ip-address"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "bastion-host"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "analysis-services"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory

$templateName = "logic-app"
$env:ARM_TEMPLATE_CURRENT = $templateName
Set-Location -Path "$rootDirectory"
Invoke-PSDocument -Path $psARMScriptsDirectory/arm-template.doc.ps1 -InstanceName $templateName -OutputPath $armTemplatesMDDirectory