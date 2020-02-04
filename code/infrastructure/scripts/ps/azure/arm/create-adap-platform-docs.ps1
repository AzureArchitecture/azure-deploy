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
    $azureCommon = ('{0}\{1}' -f  $psCommonDirectory, 'azure-common.psm1')
    Import-Module -Name $azureCommon -Force
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
