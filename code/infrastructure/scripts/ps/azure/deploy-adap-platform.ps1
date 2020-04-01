  <#
      .SYNOPSIS
      This script deploys the scaffolding in Azure based on the values in the CMDB spreadsheet.

      .PARAMETER force
      This switch will force the logon of the user as well installing and loading of powershell modules.
      Example: -force
      
      .PARAMETER azureEnvironment 
      Azure Cloud for deployment. This determines what Azure Cloud to deploy to, which also impacts other assets such as location and what resources are available. 
      Example: -azureEnvironment AzureCloud

      .PARAMETER orgTag 
      Organization string for deployment. This is used to create resources in Azure that are globally unique. 
      Example: -orgTag adw

      .PARAMETER location 
      Enter the Azure Location for the deployment. All resources and resource groups will be created in this Azure Region. 
      Example: -location eastus

      .PARAMETER envTag 
      Environment string for deployment. This is used to create resources in Azure that are globally unique. 
      Example: -envTag dev

      .PARAMETER suffix
      Token for deployment. This is used to create resources in Azure that are globally unique. 
      Example: -suffix eus2

      .PARAMETER onPremAD
      This switch is used to indicate that you want to deploy the Active Directory user and Security Groups to an on-premise Active Directory. 
      Example: -onPremAD

      .PARAMETER adOUPath
      "If this is on onpremise Active Directory deployment, you must supply the OU path for the accounts. 
      Example: -adOUPath ''OU=Azure''"
      
      .PARAMETER deployAction
      This parameter is used to either create or remove the Azure Resources. 
      Example: -deployAction create

      .PARAMETER removeRG
      This switch is used to indicate that you want to remove the Azure Resource Groups. It is only valid if deployAction -eq remove. 
      Example: -removeRG

      .PARAMETER adapCMDBfile
       This is the file that contains the values that will create the parameter files for deployment. 
       Example: -adapCMDB dev-adap-cmdb.xlsm

      .PARAMETER azParameterFiles
      This switch is used to indicate that you want to create the parameter files from the excel spreadsheet. 
      Example: -azParameterFiles

      .PARAMETER azMdFiles
      This switch is used to indicate that you want to create the documentation markdown files. 
      Example: -azMdFiles
      
      .PARAMETER azAll
      This switch is used to indicate that you want to execute all sections of this PowerShell Script. 
      Example: -azAll

      .PARAMETER adUsers
      This switch is used to indicate that you want to create test users that are found in the Excel Spreadsheet. 
      Example: -adUsers

      .PARAMETER adGroups
      This switch is used to indicate that you want to create Azure Active Directory Security Groups that are found in the Excel Spreadsheet. 
      Example: -adGroups

      .PARAMETER azPolicies
      This switch is used to indicate that you want to create Azure Policies that are found in the Excel Spreadsheet. 
      Example: -azPolicies

      .PARAMETER azInitiatives
      This switch is used to indicate that you want to create Azure Initiatives that are found in the Excel Spreadsheet. 
      Example: -azInitiatives
   
      .PARAMETER azRoles
      This switch is used to indicate that you want to create Azure Roles that are found in the Excel Spreadsheet. 
      Example: -azRoles

      .PARAMETER azBlueprints
      This switch is used to indicate that you want to create Azure Blueprints that are found in the Excel Spreadsheet. 
      Example: -azBlueprints

      .PARAMETER azRoleAssignments
      This switch is used to indicate that you want to create Azure Role Assignments that are found in the Excel Spreadsheet. 
      Example: -azRoleAssignments

      .PARAMETER azActionGroups
      This switch is used to indicate that you want to create Azure Action Groups that are found in the Excel Spreadsheet. 
      Example: -azActionGroups

      .PARAMETER azAlerts
      This switch is used to indicate that you want to create Azure Alerts that are found in the Excel Spreadsheet. 
      Example: -azAlerts

      .EXAMPLE
      .\deploy-adap-platform -force -azureEnvironment AzureCloud -orgTag "qui" -location "eastus" -envTag "dev" -suffix "eus" -adapCMDBfile "dev-adap-cmdb.xlsm" -deployAction "create" -azAll
      .\deploy-adap-platform -azureEnvironment AzureCloud -orgTag "qui" -location "eastus" -envTag "dev" -suffix "eus" -adapCMDBfile "dev-adap-cmdb.xlsm" -deployAction "remove" -removeRG -azAll
      .\deploy-adap-platform -azureEnvironment AzureCloud -orgTag "qui" -location "eastus" -envTag "dev" -suffix "eus" -adapCMDBfile "dev-adap-cmdb.xlsm" -deployAction "create" -azParameterFiles -azMdFiles

  #>
  param(
  # force
    [Parameter(ValueFromPipelinebyPropertyName=$true,HelpMessage='This switch is used to indicate that you want to force the user to logon and also to refresh the PowerShell Modules if neede. Example: -force')]
    [Switch]$force,
    # azureEnvironment
    [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$true,HelpMessage="Enter the Azure Environment . This is the Azure Cloud type ('AzureCloud','AzureChinaCloud','AzureUSGovernment','AzureGermanyCloud') . Example: -azureEnvironment ''AzureCloud''")]
    [ValidateLength(1,80)]
    [validateset('AzureCloud','AzureChinaCloud','AzureUSGovernment','AzureGermanyCloud')]
    [string]$azureEnvironment,
    # orgTag
    [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$true,HelpMessage="Enter organization string between 1 and 4 characters. This is used to create resources in Azure that are globally unique. Example: -orgTag ''adw''")]
    [ValidateLength(1,4)]
    [string]$orgTag,
    # location
    [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$true,HelpMessage="Enter the Azure Location for the deployment. All resources and resource groups will be created in this Azure Region. Example: -location ''eastus''")]
    [validateset('canadacentral','canadaeast','centralus','eastus','eastus2','northcentralus','southcentralus','westcentralus','westus','westus2','usgovvirginia','usgoviowa','usgovtexas','usgovarizona')]
    [string]$location,
    # envTag
    [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$true,HelpMessage="Enter 3 character environment string. This is used to create resources in Azure that are globally unique. Example: -envTag ''dev''")]
    [ValidateLength(3,3)]
    [string]$envTag,
    # suffix
    #[Parameter(Mandatory=$True,HelpMessage="Enter resource suffix string between 1 and 4 characters. This is used to create resources in Azure that are globally unique. Example: -suffix ''eus2''")]
    #[ValidateLength(1,4)]
    #[string]$suffix,
    # deployAction 
    [Parameter(Mandatory=$True,HelpMessage="Enter deployment action: create or purge. This switch is used to either create or remove the Azure Resources. Example: -deployAction ''create''")]
    [validateset('create','remove')]
    [string]$deployAction,
    # onPremAD
    [Parameter(HelpMessage='This switch is used to indicate that you want to deploy the Active Directory user and Security Groups to an on-premise Active Directory.. Example: -onPremAD')]
    [switch]$onPremAD=$false,
    # adOUPath
    [Parameter(Mandatory=$False,HelpMessage="If this is on onpremise Active Directory deployment, you must supply the OU path for the accounts. Example: -adOUPath ''OU=Azure''")]
    [string]$adOUPath,
    # removeRG
    [Parameter(HelpMessage='This switch is used to indicate that you want to remove the Azure Resource Groups. It is only valid if deployAction -eq remove. Example: -removeRG')]
    [switch]$removeRG=$false,
    # adapCMDB
    [Parameter(Mandatory=$True,HelpMessage="Enter the CMD file name for deployment metatdata. This is the file that contains the values that will create the parameter files for deployment. Example: -adapCMDB ''dev-adap-cmdb.xlsm''")]
    [string]$adapCMDBfile,
    # azParameterFiles
    [Parameter(HelpMessage='This switch is used to indicate that you want to create the Azure ARM Template Parameter files. Example: -azParameterFiles')]
    [Switch]$azParameterFiles,
    # azMdFiles
    [Parameter(HelpMessage='This switch is used to indicate that you want to create the documentation markdown files. Example: -azMdFiles')]
    [Switch]$azMdFiles,
    # azAll
    [Parameter(HelpMessage='This switch is used to indicate that you want to execute all sections of this PowerShell Script. Example: -azAll')]
    [Switch]$azAll,
    # adUsers
    [Parameter(HelpMessage='This switch is used to indicate that you want to create test users that are found in the Excel Spreadsheet. Example: -adUsers')]
    [Switch]$adUsers,
    # adGroups
    [Parameter(HelpMessage='This switch is used to indicate that you want to create Azure Active Directory Security Groups that are found in the Excel Spreadsheet. Example: -adGroups')]
    [Switch]$adGroups,
    # azPolicies
    [Parameter(HelpMessage='This switch is used to indicate that you want to create Azure Policies that are found in the Excel Spreadsheet. Example: -azPolicies')]
    [Switch]$azPolicies,
    # azInitiatives
    [Parameter(HelpMessage='This switch is used to indicate that you want to create Azure Initiatives that are found in the Excel Spreadsheet. Example: -azInitiatives')]
    [Switch]$azInitiatives,
    # azRoles
    [Parameter(HelpMessage='This switch is used to indicate that you want to create Azure Roles that are found in the Excel Spreadsheet. Example: -azRoles')]
    [Switch]$azRoles,
    # azBlueprints
    [Parameter(HelpMessage='This switch is used to indicate that you want to create Azure Blueprints that are found in the Excel Spreadsheet. Example: -azBlueprints')]
    [Switch]$azBlueprints,
    # azRoleAssignments
    [Parameter(HelpMessage='This switch is used to indicate that you want to create Azure Role Assignments that are found in the Excel Spreadsheet. Example: -azRoleAssignments')]
    [Switch]$azRoleAssignments,
    # azActionGroups
    [Parameter(HelpMessage='This switch is used to indicate that you want to create Azure Action Groups that are found in the Excel Spreadsheet. Example: -azActionGroups')]
    [Switch]$azActionGroups,
    # azAlerts
    [Parameter(HelpMessage='This switch is used to indicate that you want to create Azure Alerts that are found in the Excel Spreadsheet. Example: -azAlerts')]
    [Switch]$azAlerts
  )

  Set-Location -Path "$PSScriptRoot"
  # Set variables
  $VerbosePreference = 'SilentlyContinue' # 'Stop','Inquire','Continue','Suspend','SilentlyContinue'
  $DebugPreference = 'SilentlyContinue' # 'Stop','Inquire','Continue','Suspend','SilentlyContinue'
  $ErrorActionPreference = 'SilentlyContinue' # 'Stop','Inquire','Continue','Suspend','SilentlyContinue'
  $InformationPreference = 'Continue' # 'Stop','Inquire','Ignore','Continue','Suspend','SilentlyContinue'
  $WarningPreference = 'SilentlyContinue' # 'Stop','Inquire','Continue','Suspend','SilentlyContinue'
  $ConfirmPreference = 'None' # 'None','Low','Medium','High'
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
  $variablesDirectory = "$rootAzuredeploy\devops\pipelines\variables"

   # Set Excel Spreadsheet
  $adapCMDB = "$psConfigDirectory\$adapCMDBfile"

    ## Set suffix from location variable
  if ($location)
  {
    $jsonSource = Get-Content -Raw -Path .\common\azure-location-abbr.json
    $locObj = $jsonSource | ConvertFrom-Json
    try {
      $suffix =  $locObj.Geo | Where-Object { $_.Location -eq $location } | Select-Object -ExpandProperty Abbr
    }
    catch {
      Write-Host -ForegroundColor RED    "Error setting reguired suffix from location: $location"
      $PSCmdlet.ThrowTerminatingError($_)
      Exit
    }
    
  }

  ## Check path to CMDB
  if ( (Test-path -Path $adapCMDB) -and (Test-path -Path ('{0}\azure-common.psm1' -f "$psCommonDirectory")))
  {
    try{
      $azureCommon = ('{0}\{1}' -f  $psCommonDirectory, 'azure-common.psm1')
      Import-Module -Name $azureCommon -Force 

      #Set Config Values
      $configurationFile = ('{0}\{1}' -f  $psConfigDirectory, 'adap-configuration.psm1')
      Import-Module -Name $configurationFile -Force 
      $config = Get-Configuration
      
      # Set variabls from config file
      $adOUPath = $config.adOUPath
      $orgTagDefault = $config.orgTag
      $suffixDefault = $config.suffix
      $locationDefault = $config.location
      $locationDescriptionDefault = $config.locationDescription
      $subscriptionIdZero = '00000000-0000-0000-0000-000000000000'
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
    Write-Information  -MessageData 'No file specified or file {0}\{1} does not exist.' -MessageData -f -Tags $psConfigDirectory, $adapCMDBfile
    Exit
  }

    $testRG = "rg-$orgTag-test-$suffix"
    $smokeRG = "rg-$orgTag-smoke-$suffix"
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
  if ($force) {
    # load PS modules
    Import-Module -Name 'Az'
    Load-Module 'Az.Blueprint'
    Load-Module 'AzureAD'
    Load-Module 'Azure.Storage'
    Load-Module 'Pester'
    Load-Module 'PSDocs'
    Load-Module 'PsISEProjectExplorer'
    Load-Module 'ImportExcel'
    
    Get-ChildItem -Path $rootAzuredeploy -Recurse | Unblock-File 
    try{
      Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Confirm:0 -Force -ErrorAction SilentlyContinue
    }
    Catch
    {
      Write-Host 'Set-ExecutionPolicy Failed'
      Write-Host -Message 'Press any key to exit...'
      Exit
    }
    
    # Logon to Azure
    Write-Information -MessageData 'Logon to Azure (MFA)...'
    Initialize-Subscription -Force -azureEnvironment $azureEnvironment
    
    # Logon to Azure AD
    try{
        Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
        # Logon to Azure AD 
        Write-Information -MessageData 'Logon to Azure Active Directory...'
        $currentAzureContext = Get-AzContext
        Write-Information -MessageData 'Logon to Azure AD'
        $tenantId = $currentAzureContext.Tenant.Id
        $accountId = $currentAzureContext.Account.Id
        Connect-AzureAD -TenantId $tenantId -AccountId $accountId -AzureEnvironmentName $azureEnvironment
    }
    catch{
      Write-Host 'Logon to Azure Active Directory Failed'
      Write-Host -Message 'Press any key to exit...'
      Exit
    }
  }
  $subscriptionId = Get-SubscriptionId
  $currentAzSubscription = Get-AzSubscription -SubscriptionId $subscriptionId -TenantId $tenantId
  # Verifies that the location is valid based on the azureEnvironment parameter. AzureUSGovernment will validate against Gov Regions.
  $locationName = Get-AzSubLocationDisplayName  -Subscription $currentAzSubscription -location $location 
  
  Set-Location -Path "$rootAzuredeploy" 
  
  #update production and development variables for Location
  Write-Information -MessageData "Pre-Deployment - Updating $locationDefault to $location."
  If ($locationDefault -ne $location){
    Update-StringInFile -searchStr $locationDefault -replaceStr $location -rootDirectory $variablesDirectory -fileExtension 'yml' -CaseSensitive
    Update-StringInFile -searchStr $locationDefault -replaceStr $location -rootDirectory $psConfigDirectory -fileExtension 'psm1' -CaseSensitive
  }
  else {
    Write-Information -MessageData "Location are the same $locationDefault to $location - no changes needed."
  }

  Write-Information -MessageData "Pre-Deployment - Updating $locationDescriptionDefault to $locationName."
  If ($locationDescriptionDefault -ne $locationName){
    Update-StringInFile -searchStr $locationDescriptionDefault -replaceStr $locationName -rootDirectory $variablesDirectory -fileExtension 'yml' -CaseSensitive
    Update-StringInFile -searchStr $locationDescriptionDefault -replaceStr $locationName -rootDirectory $psConfigDirectory -fileExtension 'psm1' -CaseSensitive
  }
  else {
    Write-Information -MessageData "Location are the same $locationDescriptionDefault to $locationName - no changes needed."
  }

  Write-Information -MessageData "Pre-Deployment - Updating rg-smoke to $smokeRG."
  If ($locationDescriptionDefault -ne $locationName){
    Update-StringInFile -searchStr 'rg-smoke' -replaceStr $smokeRG -rootDirectory $variablesDirectory -fileExtension 'yml' -CaseSensitive
  }
  else {
    Write-Information -MessageData "Location are the same rg-smoke to $smokeRG - no changes needed."
  }

  
  # update suffix in yml and json files.
  Write-Information -MessageData "Pre-Deployment - Updating $suffixDefault to $suffix."
  If ($suffixDefault -ne $suffix){
    Update-StringInFile -searchStr $suffixDefault -replaceStr $suffix -rootDirectory $rootAzuredeploy -fileExtension 'json'
    Update-StringInFile -searchStr $suffixDefault -replaceStr $suffix -rootDirectory $rootAzuredeploy -fileExtension 'yml'
    Update-StringInFile -searchStr $suffixDefault -replaceStr $suffix -rootDirectory $rootAzuredeploy -fileExtension 'psm1'
  }
  else {
    Write-Information -MessageData "Suffix are the same $suffixDefault to $suffix - no changes needed."
  }


  # update orgTags in yml and json files.
  Write-Information -MessageData "Pre-Deployment - Updating $orgTagDefault to $orgTag."
  If ($orgTagDefault -ne $orgTag){
    Update-StringInFile -searchStr $orgTagDefault -replaceStr $orgTag -rootDirectory $rootAzuredeploy -fileExtension 'json' -CaseSensitive
    Update-StringInFile -searchStr $orgTagDefault -replaceStr $orgTag -rootDirectory $rootAzuredeploy -fileExtension 'yml' -CaseSensitive
    Update-StringInFile -searchStr $orgTagDefault -replaceStr $orgTag -rootDirectory $rootAzuredeploy -fileExtension 'psm1' -CaseSensitive
  }
  else {
    Write-Information -MessageData "OrgTag are the same $orgTagDefault to $orgTag - no changes needed."
  }

  Set-Location -Path "$psscriptsRoot"  

       
  # Start Deployment of Azure Assets
  Write-Information -MessageData 'Starting deployment of Azure Assets'
  
    # Deploy Azure ARM Parameter Files
  if($azParameterFiles -or $azAll){
    Write-Information -MessageData '  Starting deployment of Azure ARM Parameter Files...'
    Set-Location -Path "$psAzureDirectory"
    .\arm\create-arm-template-parameter-files.ps1 -adapCMDB "$adapCMDB" -paramDirectory "$armTemplatesDirectory\parameters" -env $envTag
  }
  else
  {
    Write-Information -MessageData '  Creation of Azure ARM Template Files is disabled.'
  }
  
      # Create Markdown Files
  if($azMdFiles -or $azAll){
    Set-Location -Path "$psAzureDirectory"
    Write-Information -MessageData '  updating arm markdown docs...'
    # .\arm\create-adap-platform-docs.ps1 
  }
  else
  {
    Write-Information -MessageData '  Creation of Azure Markdown Files is disabled.'
  }
  
  # Deploy Azure Active Directory Users
  if($adUsers -or $azAll){
    Write-Information -MessageData '  Starting deployment of Azure Active Directory Users'
    Set-Location -Path "$psAzureDirectory"
    .\ad\deploy-azure-ad-users.ps1 -adapCMDB "$adapCMDB" -action $deployAction
  }
  else
  {
    Write-Information -MessageData '  Deployment of Azure Active Directory Users is disabled.'
  }

  # Deploy Azure Active Directory Groups
  if($adGroups -or $azAll){
    Write-Information -MessageData '  Starting deployment of Azure Active Directory Groups'
    Set-Location -Path "$psAzureDirectory"
    .\ad\deploy-azure-ad-groups.ps1 -adapCMDB "$adapCMDB" -action $deployAction
  }
  else
  {
    Write-Information -MessageData '  Deployment of Azure Active Directory Groups is disabled.'
  }

  # Deploy Azure Roles
  if($azRoles -or $azAll){
    Write-Information -MessageData '  Starting deployment of Azure Roles'
    Set-Location -Path "$psAzureDirectory"
    .\role\deploy-azure-role-definitions.ps1 -adapCMDB "$adapCMDB" -rootDirectory $armRBACDirectory -subscriptionId $subscriptionId -action $deployAction # purge or create
  }
  else
  {
    Write-Information -MessageData '  Deployment of Azure Active Roles is disabled.'
  }

  # Deploy Azure Policies
  if($azPolicies -or $azAll){
    Write-Information -MessageData '  Starting deployment of Azure Policies'
    Set-Location -Path "$psAzureDirectory"
    .\policy\deploy-azure-policy-definitions.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armPolicyDirectory\policies\" -subscriptionId $subscriptionId -action $deployAction
  }
  else
  {
    Write-Information -MessageData '  Deployment of Azure Policies is disabled.'
  }

  # Deploy Azure Initiatives
  if($azInitiatives -or $azAll){
    Write-Information -MessageData '  Starting deployment of Azure Initiatives'
    Set-Location -Path "$psAzureDirectory"
    .\policy\deploy-azure-policy-initiatives.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armPolicyDirectory\initiatives\" -subscriptionId $subscriptionId -action $deployAction -location $location
  }
  else
  {
    Write-Information -MessageData '  Deployment of Azure Policy Initiatives is disabled.'
  }

  if (($azAll -or $azInitiatives) -and $azBlueprints -or $azAll){
    # need to sleep for 5 minutes to allow inititives to flush cache
    Write-Information -MessageData '  Need to sleep for 5 minutes to allow Policy Initiatives to flush cache'
    Start-Countdown -Seconds 300 -Message '    Need to sleep for 5 minutes to allow Policy Initiatives to flush cache'
  }

  if($azBlueprints -or $azAll){
    Write-Host $locationName
    Write-Information -MessageData '  Starting deployment of Azure Blueprints...'
    Update-StringInFile -searchStr $subscriptionIdZero -replaceStr $subscriptionId -rootDirectory $armBluePrintDirectory -fileExtension 'json'
    Set-Location -Path "$psAzureDirectory"
    .\blueprint\deploy-azure-blueprint-definitions.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armBluePrintDirectory" -action $deployAction -subscriptionId $subscriptionId -location "$location" -logAnalytics $logAnalytics -env $envTag -orgTag $orgTag -suffix $suffix -removeRG:$removeRG -testRG $testRG -smokeRG $smokeRG -mgmtRG $mgmtRG -networkRG $networkRG -sharedRG $sharedRG -adapRG $adapRG -onpremRG $onpremRG
  }
  else
  {
    Write-Information -MessageData '  Deployment of Azure Blueprints is disabled.'
  }
  
  if ($azBlueprints -or $azAll){
    # need to sleep for 10 minutes to allow blueprint deployment  to complete
    Write-Information -MessageData '  Need to sleep for 10 minutes to allow blueprint deployment to complete.'
    Start-Countdown -Seconds 600 -Message 'Waiting 10 minutes to allow blueprint deployment to complete.'
    Update-StringInFile -searchStr $subscriptionId -replaceStr $subscriptionIdZero -rootDirectory $armBluePrintDirectory -fileExtension 'json'
  }

  # Deploy Azure Role Assignments
  if($azRoleAssignments -or $azAll){
    Write-Information -MessageData '  Starting deployment of Azure Role Assignments'
    Set-Location -Path "$psAzureDirectory"
    .\role\assign-azure-roles.ps1 -adapCMDB "$adapCMDB" -env $envTag -action $deployAction -subscriptionId $subscriptionId
  }
  else
  {
    Write-Information -MessageData '  Deployment of Azure Active Role Assignments is disabled.'
  }

  # Deploy Azure Action Groups
  if($azActionGroups -or $azAll){
    Write-Information -MessageData '  Starting deployment of Azure Action Groups...'
    Set-Location -Path "$psAzureDirectory"
    .\alert\deploy-azure-action-group-defs.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armAlertDirectory\actiongroup\" -action $deployAction -resourceGroupName $alertResourceGroup
  }
  else
  {
    Write-Information -MessageData '  Deployment of Azure Action Groups is disabled.'
  }

  # Deploy Azure Alerts
  if($azAlerts -or $azAll){
    Write-Information -MessageData '  Starting deployment of Azure Alerts...'
    Set-Location -Path "$psAzureDirectory"
    .\alert\deploy-azure-alert-defs.ps1 -adapCMDB "$adapCMDB" -rootDirectory "$armAlertDirectory\alerts\" -action $deployAction -resourceGroupName $alertResourceGroup
  }
  else
  {
    Write-Information -MessageData '  Deployment of Azure Alerts is disabled.'
  }

   
  Set-Location -Path $psscriptsRoot
  # Completing Deployment of Azure Assets
  Write-Information -MessageData 'Completing deployment of Azure Assets'

  # Remove variable
  #((Compare-Object -ReferenceObject (Get-Variable).Name -DifferenceObject $DefaultVariables).InputObject).foreach{Remove-Variable -Name $_}
