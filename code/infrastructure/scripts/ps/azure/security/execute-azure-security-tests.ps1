#
# Azure Resource Manager documentation definitions
#
# A function to break out parameters from an ARM template
[CmdletBinding()]
param(
  # debugAction
  [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
  [Switch]$debugAction = $false,

  # verbosePreferenceVariable
  [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
  [validateset('Stop','Inquire','Continue','Suspend','SilentlyContinue')]
  [string]$verbosePreferenceVariable = 'SilentlyContinue',

  # errorActionPreferenceVariable
  [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
  [validateset('Stop','Inquire','Continue','Suspend','SilentlyContinue')]
  [string]$errorActionPreferenceVariable = 'Stop',

  # debugPreferenceVariable
  [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
  [validateset('Stop','Inquire','Continue','Suspend','SilentlyContinue')]
  [string]$debugPreferenceVariable = 'SilentlyContinue',

  # informationPreferenceVariable
  [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
  [validateset('Stop','Inquire','Ignore','Continue','Suspend','SilentlyContinue')]
  [string]$informationPreferenceVariable = 'Continue'

)
Clear-Host
$DefaultVariables = $(Get-Variable).Name

#$null = "$actionErrorVariable"
$VerbosePreference = $verbosePreferenceVariable
$DebugPreference = $debugPreferenceVariable
$ErrorActionPreference = $errorActionPreferenceVariable
$InformationPreference = $informationPreferenceVariable
$psscriptsRoot = $PSScriptRoot

Set-PSDebug -Off
if($debugAction){
  Set-PSDebug -Trace 1
}
Import-Module PSDocs -Force

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

if ( -not (Test-path ('{0}\azure-common.psm1' -f "$psCommonDirectory")))
{
  Write-Information 'Shared PS modules can not be found, Check path {0}\azure-common.psm1.' -f $psCommonDirectory
  Exit
}

try{
  $azureCommon = ('{0}\{1}' -f  $psCommonDirectory, 'azure-common')
  Import-Module -Name $azureCommon -Force

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
    
# Set variabls from config file
$automationAccountName = $config.laAutomationAccount
$logAnalytics = $config.laWorkspaceName
$laResourceGroup = $config.laResourceGroup
$alertResourceGroup = $config.alertResourceGroup
$orgTag = $config.orgTag
$env = $config.evTag
$location = $config.primaryLocation  
$username = $config.azureAdmin
$password = $config.azureAdminPwd
$subname = 'AzureArch'
$securityEmails = $config.securityEmails
$securityPhoneNo = $config.securityPhoneNo


# Logon to Azure
Write-Information 'Logon to Azure...'
Initialize-Subscription
$subscriptionId = Get-SubscriptionId
Set-AzContext -SubscriptionId $subscriptionId
$subscriptionName = (Get-AzContext).Subscription.SubscriptionName
$resourceGroupNames = "rg-chp-adap-dev-pcus,rg-chp-mgmt-dev-pcus,rg-chp-network-dev-pcus,rg-chp-shared-dev-pcus"

# chpK: Scan the security health of your subscription
# https://chpk.azurewebsites.net/01-Subscription-Security/Readme.html#scan-the-security-health-of-your-subscription
set-AzSKSubscriptionSecurity -SubscriptionId $subscriptionId -SecurityContactEmails $securityEmails -SecurityPhoneNumber $securityPhoneNo
#Remove-AzSKSubscriptionSecurity -SubscriptionId $subscriptionId
  
# chpK: Subscription Access Control Provisioning
# https://chpk.azurewebsites.net/01-Subscription-Security/Readme.html#chpk-subscription-access-control-provisioning
set-AzSKSubscriptionRBAC -SubscriptionId $subscriptionId
#Remove-AzSKSubscriptionRBAC -SubscriptionId $subscriptionId
  
# chpK: Configure alerts for your subscription 
# https://chpk.azurewebsites.net/01-Subscription-Security/Readme.html#chpk-subscription-activity-alerts
set-AzSKAlerts -SubscriptionId $subscriptionId -SecurityContactEmails $securityEmails -SecurityPhoneNumbers $securityPhoneNo
#Remove-AzSKAlerts -SubscriptionId $subscriptionId

# chpK: Azure Security Center (ASC) configuration
# https://chpk.azurewebsites.net/01-Subscription-Security/Readme.html#setup-azure-security-center-asc-on-your-subscription
set-AzSKAzureSecurityCenterPolicies -SubscriptionId $subscriptionId -SecurityContactEmails $securityEmails -SecurityPhoneNumbers $securityPhoneNo

# chpK: Subscription Security - ARM Policy
# https://chpk.azurewebsites.net/01-Subscription-Security/Readme.html#chpk-subscription-security---arm-policy
set-AzSKARMPolicies -SubscriptionId $subscriptionId
#Remove-AzSKARMPolicies -subscriptionId $subscriptionId

# chpK: Update subscription security baseline configuration
# https://chpk.azurewebsites.net/01-Subscription-Security/Readme.html#chpk-update-subscription-security-baseline-configuration
update-AzSKSubscriptionSecurity -SubscriptionId $subscriptionId

# chpK Continuous Assurance
# https://chpk.azurewebsites.net/01-Subscription-Security/Readme.html#ca
$lawsSharedKey = Get-AzOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $alertResourceGroup -Name $logAnalytics
install-AzSKContinuousAssurance -SubscriptionId $subscriptionId -AutomationAccountLocation $config.primaryLocationName -ResourceGroupNames $resourceGroupNames -LAWSId $logAnalytics -LAWSSharedKey $lawsSharedKey

# chpK: Privileged Identity Management (PIM) helper cmdlets
# Use get-AzSKPIMConfiguration (alias 'getpim') for querying various PIM settings/status
# https://chpk.azurewebsites.net/01-Subscription-Security/Readme.html#list-your-pim-eligible-roles-listmyeligibleroles
get-AzSKPIMConfiguration -ListMyEligibleRoles

# List permanent assignments (-ListPermanentAssignments)
# https://chpk.azurewebsites.net/01-Subscription-Security/Readme.html#list-permanent-assignments-listpermanentassignments
get-AzSKPIMConfiguration -ListPermanentAssignments -SubscriptionId $subscriptionId #  [-RoleNames <Comma separated list of roles>] [-ResourceGroupName <ResourceGroupName>] [-ResourceName <ResourceName>] [-DoNotOpenOutputFolder]
# Example 1: List all permanent assignments at subscription level with 'Contributor' and 'Owner' roles.
get-AzSKPIMConfiguration -ListPermanentAssignments -SubscriptionId $subscriptionId -RoleNames "Contributor,Owner" -DoNotOpenOutputFolder
# Example 2: List all permanent assignments at 'DemoRG' resource group level with 'Contributor' role.
get-AzSKPIMConfiguration -ListPermanentAssignments -SubscriptionId $subscriptionId -RoleNames "Contributor" -ResourceGroupName $resourceGroupNames -DoNotOpenOutputFolder
# Example 3: List all permanent assignments at resource level with 'Contributor' and 'Owner' role.
get-AzSKPIMConfiguration -ListPermanentAssignments -SubscriptionId $subscriptionId -RoleNames "Contributor,Owner" -ResourceGroupName $laResourceGroup -ResourceName $logAnalytics -DoNotOpenOutputFolder


get-AzSKARMTemplateSecurityStatus -ARMTemplatePath $armTemplatesDirectory [-Recurse]
  
get-AzSKAzureServicesSecurityStatus -SubscriptionId $subscriptionId -ResourceGroupNames $resourceGroupNames
   
get-AzSKSubscriptionSecurityStatus -SubscriptionId $subscriptionId

