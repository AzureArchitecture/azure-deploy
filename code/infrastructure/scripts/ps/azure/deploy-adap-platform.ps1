  <#
      .SYNOPSIS
      This script deploys the ADAP platform based on the values in the adap-cmdb.xlsx spreadsheet.

      .PARAMETER -azAll -adUsers -adGroups -adServicePrincipals -azPolicies -azInitiatives -azRoles -azRoleAssignments -azActionGroups -azAlerts -azBlueprints -azParameterFiles
      Switch to deploy the resources

      .PARAMETER debugAction (default off)
      Switch to enable debugging output

      .PARAMETER actionVar (default SilentlyContinue)
      Switch to enable debugging output

      .PARAMETER env (default dev)
      token for deployment (smoke, dev, prod, uat, sandbox)

      .PARAMETER suffix (default -eus)
      token for deployment

      .PARAMETER location (default centralus)
      location for Azure Blueprint deployment

      .PARAMETER alertResourceGroup (default rg-shared-dev-eus)
      Resource group to deploy Azure Alerts to

      .PARAMETER action (default create)
      Create Azure Assets or Purge Azure Assets

      .PARAMETER removeRG (default $false)
      Switch to remove resource groups during blueprint purge

      Stop: Displays the error message and stops executing.
      Inquire: Displays the error message and asks you whether you want to continue.
      Continue: (Default) Displays the error message and continues executing.
      Suspend: Automatically suspends a work-flow job to allow for further investigation. After investigation, the work-flow can be resumed.
      SilentlyContinue: No effect. The error message isn't displayed and execution continues without interruption.

      .EXAMPLE
      .\deploy-adap-platform -azBlueprints -azParameterFiles
      .\deploy-adap-platform.ps1 -adGroups -adUsers -azPolicies -azInitiatives -azAlerts -azRoles -azRoleAssignments -azBlueprints
      .\deploy-adap-platform.ps1 -azAll -deployAction create
      .\deploy-adap-platform.ps1 -azAll -location "centralus" -env "dev" -actionVerboseVariable "SilentlyContinue" -actionDebugVariable "SilentlyContinue" -actionErrorVariable "SilentlyContinue" -deployAction create
      .\deploy-adap-platform.ps1 -azBlueprints -location "centralus" -env "dev" -actionVerboseVariable "Continue" -actionDebugVariable "Continue" -actionErrorVariable "Stop" -deployAction create

  #>
  [CmdletBinding()]
  param(
    # azAll
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$azAll=$false,

    # adUsers
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$adUsers=$false,

    # adGroups
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$adGroups=$false,

    # adServicePrincipals
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$adServicePrincipals=$false,

    # azPolicies
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$azPolicies=$false,

    # azInitiatives
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$azInitiatives=$false,

    #azRoles
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$azRoles=$false,

    #azBlueprints
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$azBlueprints=$false,

    #AzRoleAssignments
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$azRoleAssignments=$false,
   
    # azActionGroups
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$azActionGroups=$false,
    
    # azAlerts
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$azAlerts=$false,

    # azRunbooks
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$azRunbooks=$false,

    # azParameterFiles
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Switch]$azParameterFiles=$true,

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
    [string]$informationPreferenceVariable = 'Continue',

    # deployAction
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [validateset('create','purge')]
    [string]$deployAction = 'create',

    # adapCMDB
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$adapCMDBfile = 'adap-cmdb.xlsm',

    # removeRG
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [switch]$removeRG=$false

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

  #Folder Locations
  $psCommonDirectory = "$psscriptsRoot\common"
  $psConfigDirectory = "$psscriptsRoot\config"
  $psAzureDirectory = "$psscriptsRoot"
  $armTemplatesDirectory = "$psscriptsRoot\..\..\..\arm\templates"
  $armAlertDirectory = "$psscriptsRoot\..\..\..\arm\alert"
  $armBluePrintDirectory = "$psscriptsRoot\..\..\..\arm\blueprint"
  $armPolicyDirectory = "$psscriptsRoot\..\..\..\arm\policy"
  $armRBACDirectory = "$psscriptsRoot\..\..\..\arm\rbac\roles"
  $armRunbookDirectory = "$psscriptsRoot\..\..\..\arm\automation\runbooks"

  $adapCMDB = "$psConfigDirectory\$adapCMDBfile"

  if ( -not (Test-path ('{0}\azure-common.psm1' -f "$psCommonDirectory")))
  {
    Write-Information 'Shared PS modules can not be found, Check path {0}\azure-common.psm1.' -f $psCommonDirectory
    Exit
  }
  ## Check path to CMDB
  if ( -not (Test-path -Path $adapCMDB))
  {
    Write-Information  'No file specified or file {0}\{1} does not exist.' -f $psConfigDirectory, $adapCMDBfile
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
  $alertResourceGroup = $config.alertResourceGroup
  $orgTag = $config.orgTag
  $env = $config.evTag
  $location = $config.primaryLocation  
  $username = $config.azureAdmin
  $password = $config.azureAdminPwd
  $subname = $config.subscriptionname 
  $adOUPath = $config.adOUPath
  
  $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
  $cred = New-Object System.Management.Automation.PSCredential ($userName, $secpasswd)
  Connect-AzAccount  -Credential $cred
  $sub = get-AzSubscription -SubscriptionName $subname
  Connect-AzAccount -Credential $cred -Tenant $sub.TenantId -SubscriptionId $sub.SubscriptionId
  Set-AzContext -SubscriptionName $subname

  # Logon to Azure
  Write-Information 'Logon to Azure...'
  Initialize-Subscription -
  $subscriptionId = Get-SubscriptionId
  Set-AzContext -SubscriptionId $subscriptionId
  $subscriptionName = (Get-AzContext).Subscription.SubscriptionName
  try{
    if($adGroups -or $adServicePrincipals -or $adUsers){
      # Logon to Azure AD with values from config file
      Write-Information 'Logon to Azure Active Directory...'
      $currentAzureContext = Get-AzContext
      Write-Information "Logon to Azure AD with values from config file: $configurationFile"
      $tenantId = $currentAzureContext.Tenant.Id
      $accountId = $currentAzureContext.Account.Id
      Connect-AzureAD -TenantId $tenantId -AccountId $accountId
    }
  }
  catch{
    Write-Host 'Logon to Azure Active Directory Failed'
    Write-Host -Message 'Press any key to exit...'
    Exit
  }

  # Start Deployment of Azure Assets
  Write-Information 'Starting deployment of Azure Assets'

  # Deploy Azure Active Directory Users
  if($adUsers -or $azAll){
    Write-Information '  Starting deployment of Azure Active Directory Users'
    Set-Location -Path "$psAzureDirectory"
    .\ad\deploy-azure-ad-users.ps1 -adapCMDB "$adapCMDB" -action $deployAction # purge or create
  }
  else
  {
    Write-Information '  Deployment of Azure Active Directory Users is disabled.'
  }

  # Deploy Azure Active Directory Groups
  if($adGroups -or $azAll){
    Write-Information '  Starting deployment of Azure Active Directory Groups'
    Set-Location -Path "$psAzureDirectory"
    .\ad\deploy-azure-ad-groups.ps1 -adapCMDB "$adapCMDB" -action $deployAction -adOnPrem # purge or create
  }
  else
  {
    Write-Information '  Deployment of Azure Active Directory Groups is disabled.'
  }

  # Deploy Azure Roles
  if($azRoles -or $azAll){
    Write-Information '  Starting deployment of Azure Roles'
    Set-Location -Path "$psAzureDirectory"
    .\role\deploy-azure-role-definitions.ps1 -adapCMDB "$adapCMDB" -rootDirectory $armRBACDirectory -subscriptionId $subscriptionId -action $deployAction # purge or create
  }
  else
  {
    Write-Information '  Deployment of Azure Active Roles is disabled.'
  }
  
  # Deploy Azure Policies
  if($azPolicies -or $azAll){
    Write-Information '  Starting deployment of Azure Policies'
    Set-Location -Path "$psAzureDirectory"
    .\policy\deploy-azure-policy-definitions.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armPolicyDirectory\policies\" -subscriptionId $subscriptionId -action $deployAction
  }
  else
  {
    Write-Information '  Deployment of Azure Policies is disabled.'
  }

  # Deploy Azure Initiatives
  if($azInitiatives -or $azAll){
    Write-Information '  Starting deployment of Azure Initiatives'
    Set-Location -Path "$psAzureDirectory"
    .\policy\deploy-azure-policy-initiatives.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armPolicyDirectory\initiatives\" -subscriptionId $subscriptionId -action $deployAction -location $location
  }
  else
  {
    Write-Information '  Deployment of Azure Policy Initiatives is disabled.'
  }

  # Deploy Azure Blueprint
  # New-AzOperationalInsightsWorkspace -Name "la-chp-dev-eus" -Location "East US" -Sku "pergb2018" -ResourceGroupName "rg-chp-shared-dev-eus" -Force
  if($azBlueprints -or $azAll){
    Write-Information '  Starting deployment of Azure Blueprints...'
    Set-Location -Path "$psAzureDirectory"
    .\blueprint\deploy-azure-blueprint-definitions.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armBluePrintDirectory" -action $deployAction -subscriptionId $subscriptionId -location $location -logAnalytics $logAnalytics -env $env -orgTag $orgTag -suffix $suffix -removeRG:$removeRG
  }
  else
  {
    Write-Information '  Deployment of Azure Blueprints is disabled.'
  }

  # Deploy Azure Role Assignments
  if($azRoleAssignments -or $azAll){
    Write-Information '  Starting deployment of Azure Role Assignments'
    Set-Location -Path "$psAzureDirectory"
    .\role\assign-azure-roles.ps1 -adapCMDB "$adapCMDB" -env $env -action $deployAction -subscriptionId $subscriptionId
  }
  else
  {
    Write-Information '  Deployment of Azure Active Role Assignments is disabled.'
  }
  
  # Deploy Azure Action Groups
  if($azActionGroups -or $azAll){
    Write-Information '  Starting deployment of Azure Action Groups...'
    Set-Location -Path "$psAzureDirectory"
    .\alert\deploy-azure-action-group-defs.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armAlertDirectory\actiongroup\" -action $deployAction -resourceGroupName $alertResourceGroup
  }
  else
  {
    Write-Information '  Deployment of Azure Action Groups is disabled.'
  }

  # Deploy Azure Alerts
  if($azAlerts -or $azAll){
    Write-Information '  Starting deployment of Azure Alerts...'
    Set-Location -Path "$psAzureDirectory"
    .\alert\deploy-azure-alert-defs.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armAlertDirectory\alerts\" -action $deployAction -resourceGroupName $alertResourceGroup
  }
  else
  {
    Write-Information '  Deployment of Azure Alerts is disabled.'
  }
  
  # Deploy Runbooks
  if($azRunbooks -or $azAll){
    Write-Information '  Starting deployment of Azure Runbooks...'
    Set-Location -Path "$psAzureDirectory"
    .\automation\deploy-azure-auto-runbooks.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armRunbookDirectory" -action $deployAction -resourceGroupName $alertResourceGroup -automationAccountName $automationAccountName
  }
  else
  {
    Write-Information '  Deployment of Azure Alerts is disabled.'
  }
  

  # Deploy Azure ARM Parameter Files
  if($azParameterFiles -or $azAll){
    Write-Information '  Starting deployment of Azure ARM Parameter Files...'
    Set-Location -Path "$psAzureDirectory"
    .\arm\create-arm-template-parameter-files.ps1 -adapCMDB "$adapCMDB" -paramDirectory "$armTemplatesDirectory\parameters"
  }
  else
  {
    Write-Information '  Creation of Azure ARM Template Files is disabled.'
  }

  Set-Location -Path $psscriptsRoot
  # Completing Deployment of Azure Assets
  Write-Information 'Completing deployment of Azure Assets'

  # Remove variable
  #((Compare-Object -ReferenceObject (Get-Variable).Name -DifferenceObject $DefaultVariables).InputObject).foreach{Remove-Variable -Name $_}