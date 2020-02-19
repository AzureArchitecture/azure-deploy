  <#
      .SYNOPSIS
      This script deploys the ADAP platform based on the values in the adap-cmdb.xlsx spreadsheet.

      .PARAMETER -azAll -adUsers -adGroups -azPolicies -azInitiatives -azRoles -azRoleAssignments -azActionGroups -azAlerts -azBlueprints -azParameterFiles
      Switch to deploy the resources

      .PARAMETER debugAction (default off)
      Switch to enable debugging output

      .PARAMETER actionVar (default SilentlyContinue)
      Switch to enable debugging output

      .PARAMETER env (default dev)
      token for deployment (smoke, dev, prod, uat, sandbox)

      .PARAMETER suffix (default eus)
      token for deployment

      .PARAMETER location (default centralus)
      location for Azure Blueprint deployment

      .PARAMETER alertResourceGroup (default rg-yazy-shared-dev-cus)
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
      .\deploy-adap-platform -orgTag "yazy" -deployAction "audit" -azAll
      .\deploy-adap-platform.ps1 -adGroups -adUsers -azPolicies -azInitiatives -azAlerts -azRoles -azRoleAssignments -azBlueprints
      .\deploy-adap-platform.ps1 -azAll -deployAction create
      .\deploy-adap-platform.ps1 -azAll -location "centralus" -env "dev" -actionVerboseVariable "SilentlyContinue" -actionDebugVariable "SilentlyContinue" -actionErrorVariable "SilentlyContinue" -deployAction create
      .\deploy-adap-platform.ps1 -azBlueprints -location "centralus" -env "dev" -actionVerboseVariable "Continue" -actionDebugVariable "Continue" -actionErrorVariable "Stop" -deployAction create

  #>
  param(
    # ortTag
    [string]$orgTag="yazy",

    # envTag
    [string]$envTag="dev",

    # suffix
    [string]$suffix="pcus",

    # deployAction
    [validateset('create','purge')]
    [string]$deployAction = 'create',

    # adapCMDB
    [string]$adapCMDBfile = 'adap-cmdb.xlsm',

    # azParameterFiles
    [Switch]$azParameterFiles=$false,

    # azMdFiles
    [Switch]$azMdFiles=$false,

    # azAll
    [Switch]$azAll=$false,

    # adUsers
    [Switch]$adUsers=$false,

    # adGroups
    [Switch]$adGroups=$true,

    # azPolicies
    [Switch]$azPolicies=$false,

    # azInitiatives
    [Switch]$azInitiatives=$false,

    #azRoles
    [Switch]$azRoles=$false,

    #azBlueprints
    [Switch]$azBlueprints=$false,

    #AzRoleAssignments
    [Switch]$azRoleAssignments=$false,

    # azActionGroups
    [Switch]$azActionGroups=$false,

    # azAlerts
    [Switch]$azAlerts=$false,

    # azRunbooks
    [Switch]$azRunbooks=$false,

    # debugAction
    [Switch]$debugAction = $false,

    # removeRG
    [switch]$removeRG=$false,


    # verbosePreferenceVariable
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [validateset('Stop','Inquire','Continue','Suspend','SilentlyContinue')]
    [string]$verbosePreferenceVariable = 'SilentlyContinue',

    # errorActionPreferenceVariable
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [validateset('Stop','Inquire','Continue','Suspend','SilentlyContinue')]
    [string]$errorActionPreferenceVariable = 'Stop',

    # debugPreferenceVariable
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [validateset('Stop','Inquire','Continue','Suspend','SilentlyContinue')]
    [string]$debugPreferenceVariable = 'SilentlyContinue',

    # informationPreferenceVariable
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [validateset('Stop','Inquire','Ignore','Continue','Suspend','SilentlyContinue')]
    [string]$informationPreferenceVariable = 'Continue',

    # confirmPreferenceVariable
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [validateset('None','Low','Medium','High')]
    [string]$confirmPreferenceVariable = 'None'

  )

  Set-Location -Path "$PSScriptRoot"
  #Clear-Host
  # Set variables
  $VerbosePreference = $verbosePreferenceVariable
  $DebugPreference = $debugPreferenceVariable
  $ErrorActionPreference = $errorActionPreferenceVariable
  $InformationPreference = $informationPreferenceVariable
  $WarningPreference = $verbosePreferenceVariable
  $ConfirmPreference = $confirmPreferenceVariable
  $psscriptsRoot = $PSScriptRoot

  #Folder Locations
  $rootAzuredeploy = "$psscriptsRoot\..\..\..\..\..\"
  $psInfrastructureDirectory = "$psscriptsRoot\..\..\..\..\"
  $psCommonDirectory = "$psscriptsRoot\common"
  $psConfigDirectory = "$psscriptsRoot\config"
  $psAzureDirectory = "$psscriptsRoot"
  $armTemplatesDirectory = "$psscriptsRoot\..\..\..\arm\templates"
  $armAlertDirectory = "$psscriptsRoot\..\..\..\arm\alert"
  $armBluePrintDirectory = "$psscriptsRoot\..\..\..\arm\blueprint"
  $armPolicyDirectory = "$psscriptsRoot\..\..\..\arm\policy"
  $armRBACDirectory = "$psscriptsRoot\..\..\..\arm\rbac\roles"
  $armRunbookDirectory = "$psscriptsRoot\..\..\..\arm\automation\runbooks"

   # Set Excel Spreadsheet
  $adapCMDB = "$psConfigDirectory\$envTag-$adapCMDBfile"

  ## Check path to CMDB
  if ( (Test-path -Path $adapCMDB) -and (Test-path ('{0}\azure-common.psm1' -f "$psCommonDirectory")))
  {
    try{
      $azureCommon = ('{0}\{1}' -f  $psCommonDirectory, 'azure-common.psm1')
      Import-Module -Name $azureCommon -Force 

      #Set Config Values
      $configurationFile = ('{0}\{1}' -f  $psConfigDirectory, 'adap-configuration.psm1')
      Import-Module -Name $configurationFile -Force 
      $config = Get-Configuration
      
      # Set variabls from config file
      $orgTagDefault = $config.orgTag
      $location = $config.primaryLocation
      $locationName = $config.primaryLocationName
      $adOUPath = $config.adOUPath
      $subscriptionIdZero = "00000000-0000-0000-0000-000000000000"
      $tenantDomain = $configurationFile.tenentDomain
    }
    catch {
      Write-Host -ForegroundColor RED    "Error importing reguired PS modules: $azureCommon, $configurationFile"
      $PSCmdlet.ThrowTerminatingError($_)
      Exit
    }
  }
  else
    {
    Write-Information  'No file specified or file {0}\{1} does not exist.' -f $psConfigDirectory, $adapCMDBfile
    Exit
  }
  
     
    $testRG = "rg-test"
    $smokeRG = "rg-smoke"
    $mgmtRG = "rg-$orgTag-mgmt-$envTag-$suffix"
    $networkRG = "rg-$orgTag-network-$envTag-$suffix"
    $sharedRG = "rg-$orgTag-shared-$envTag-$suffix"
    $adapRG = "rg-$orgTag-adap-$envTag-$suffix"
    $onpremRG = "rg-$orgTag-onprem-$envTag-$suffix"

    $automationAccountName = "auto-$orgTag-shared-$envTag-$suffix"
    $logAnalytics = "la-$orgTag-$envTag-$suffix"
    $laResourceGroup = "rg-$orgTag-shared-$envTag-$suffix"
    $alertResourceGroup = "rg-$orgTag-shared-$envTag-$suffix"

   # Only run this the first time through.
  if (!$firstRunCheck) {
    # load PS modules
    Import-Module "Az"
    Load-Module "Az.Blueprint"
    Load-Module "AzureAD"
    Load-Module "Azure.Storage"
    Load-Module "Pester"
    Load-Module "PSDocs"
    Load-Module "PsISEProjectExplorer"
    Load-Module "ImportExcel"
    
    Get-ChildItem $rootAzuredeploy -recurse | Unblock-File 
    try{
      Set-ExecutionPolicy Unrestricted -Confirm:0 -Force -ErrorAction SilentlyContinue
    }
    Catch
    {}
    
    # Logon to Azure
    Write-Information 'Logon to Azure (MFA)...'
    Initialize-Subscription -Force
    
    # Logon to Azure AD
    try{
        Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
        # Logon to Azure AD with values from config file
        Write-Information 'Logon to Azure Active Directory...'
        $currentAzureContext = Get-AzContext
        Write-Information "Logon to Azure AD"
        $tenantId = $currentAzureContext.Tenant.Id
        $accountId = $currentAzureContext.Account.Id
        Connect-AzureAD -TenantId $tenantId -AccountId $accountId
    }
    catch{
      Write-Host 'Logon to Azure Active Directory Failed'
      Write-Host -Message 'Press any key to exit...'
      Exit
    }
    $firstRunCheck = $true
  }
  
  Set-Location -Path "$rootAzuredeploy"

  # update orgTags in yml and json files.
  Write-Information "Pre-Deployment - Updating $orgTagDefault to $orgTag."
  If ($orgTagDefault -ne $orgTag){
    Update-StringInFile -searchStr $orgTagDefault -replaceStr $orgTag -rootDirectory $rootAzuredeploy -fileExtension "json"
    Update-StringInFile -searchStr $orgTagDefault -replaceStr $orgTag -rootDirectory $rootAzuredeploy -fileExtension "yml"
    Update-StringInFile -searchStr $orgTagDefault -replaceStr $orgTag -rootDirectory $rootAzuredeploy -fileExtension "psm1"
  }
  else {
    Write-Information "OrgTag are the same $orgTagDefault to $orgTag - no changes needed."
  }

 
  Set-Location -Path "$psscriptsRoot"  
  $subscriptionId = Get-SubscriptionId
       
  # Start Deployment of Azure Assets
  Write-Information 'Starting deployment of Azure Assets'
  
    # Deploy Azure ARM Parameter Files
  if($azParameterFiles -or $azAll){
    Write-Information '  Starting deployment of Azure ARM Parameter Files...'
    Set-Location -Path "$psAzureDirectory"
    .\arm\create-arm-template-parameter-files.ps1 -adapCMDB "$adapCMDB" -paramDirectory "$armTemplatesDirectory\parameters" -env $envTag
  }
  else
  {
    Write-Information '  Creation of Azure ARM Template Files is disabled.'
  }
  
      # Create Markdown Files
  if($azMdFiles -or $azAll){
    Set-Location -Path "$psAzureDirectory"
    Write-Information '  updating arm markdown docs...'
    .\arm\create-adap-platform-docs.ps1 
  }
  else
  {
    Write-Information '  Creation of Azure Markdown Files is disabled.'
  }
  
  # Deploy Azure Active Directory Users
  if($adUsers -or $azAll){
    Write-Information '  Starting deployment of Azure Active Directory Users'
    Set-Location -Path "$psAzureDirectory"
    .\ad\deploy-azure-ad-users.ps1 -adapCMDB "$adapCMDB" -action $deployAction
  }
  else
  {
    Write-Information '  Deployment of Azure Active Directory Users is disabled.'
  }

  # Deploy Azure Active Directory Groups
  if($adGroups -or $azAll){
    Write-Information '  Starting deployment of Azure Active Directory Groups'
    Set-Location -Path "$psAzureDirectory"
    .\ad\deploy-azure-ad-groups.ps1 -adapCMDB "$adapCMDB" -action $deployAction -onPremAD
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

  if (($azAll -or $azInitiatives) -and $azBlueprints -or $azAll){
    # need to sleep for 5 minutes to allow inititives to flush cache
    Write-Information '  Need to sleep for 5 minutes to allow Policy Initiatives to flush cache'
    #Start-Countdown -Seconds 300 -Message "    Need to sleep for 5 minutes to allow Policy Initiatives to flush cache"
  }

  if($azBlueprints -or $azAll){
    Write-Host $locationName
    Write-Information '  Starting deployment of Azure Blueprints...'
    Update-StringInFile -searchStr $subscriptionIdZero -replaceStr $subscriptionId -rootDirectory $armBluePrintDirectory -fileExtension "json"
    Set-Location -Path "$psAzureDirectory"
    .\blueprint\deploy-azure-blueprint-definitions.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armBluePrintDirectory" -action $deployAction -subscriptionId $subscriptionId -location "$locationName" -logAnalytics $logAnalytics -env $envTag -orgTag $orgTag -suffix $suffix -removeRG:$removeRG -testRG $testRG -smokeRG $smokeRG -mgmtRG $mgmtRG -networkRG $networkRG -sharedRG $sharedRG -adapRG $adapRG -onpremRG $onpremRG
    Update-StringInFile -searchStr $subscriptionId -replaceStr $subscriptionIdZero -rootDirectory $armBluePrintDirectory -fileExtension "json"
  }
  else
  {
    Write-Information '  Deployment of Azure Blueprints is disabled.'
  }
  
  if ($azBlueprints -or $azAll){
    # need to sleep for 10 minutes to allow blueprint deployment  to complete
    Write-Information '  Need to sleep for 10 minutes to allow blueprint deployment to complete.'
    #Start-Countdown -Seconds 600 -Message "Waiting 10 minutes to allow blueprint deployment to complete."
  }

  # Deploy Azure Role Assignments
  if($azRoleAssignments -or $azAll){
    Write-Information '  Starting deployment of Azure Role Assignments'
    Set-Location -Path "$psAzureDirectory"
    .\role\assign-azure-roles.ps1 -adapCMDB "$adapCMDB" -env $envTag -action $deployAction -subscriptionId $subscriptionId
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

    
  Set-Location -Path $psscriptsRoot
  # Completing Deployment of Azure Assets
  Write-Information 'Completing deployment of Azure Assets'

  # Remove variable
  #((Compare-Object -ReferenceObject (Get-Variable).Name -DifferenceObject $DefaultVariables).InputObject).foreach{Remove-Variable -Name $_}
