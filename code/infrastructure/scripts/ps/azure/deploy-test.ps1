  <#
      .SYNOPSIS
      This script deploys the scaffolding in Azure based on the values in the CMDB spreadsheet.

      .PARAMETER orgTag 
      Organization string for deployment. This is used to create resources in Azure that are globally unique. Example: -orgTag ''adw''"

      .PARAMETER envTag 
      Environment string for deployment. This is used to create resources in Azure that are globally unique. Example: -envTag "dev"

      .PARAMETER suffix
      Token for deployment. This is used to create resources in Azure that are globally unique. Example: -suffix "eus2"

      .PARAMETER deployAction
      This parameter is used to either create or remove the Azure Resources. Example: -deployAction "create"

      .PARAMETER removeRG
      This switch is used to indicate that you want to remove the Azure Resource Groups. It is only valid if deployAction -eq remove. Example: -removeRG

      .PARAMETER adapCMDBfile
       This is the file that contains the values that will create the parameter files for deployment. Example: -adapCMDB "dev-adap-cmdb.xlsm"

      .PARAMETER azParameterFiles
      This switch is used to indicate that you want to create the parameter files from the excel spreadsheet. Example: -azParameterFiles

      .PARAMETER azMdFiles
      This switch is used to indicate that you want to create the documentation markdown files. Example: -azMdFiles
      
      .PARAMETER azAll
      This switch is used to indicate that you want to execute all sections of this PowerShell Script. Example: -azAll

      .PARAMETER adUsers
      This switch is used to indicate that you want to create test users that are found in the Excel Spreadsheet. Example: -adUsers

      .PARAMETER adGroups
      This switch is used to indicate that you want to create Azure Active Directory Security Groups that are found in the Excel Spreadsheet. Example: -adGroups

      .PARAMETER azPolicies
      This switch is used to indicate that you want to create Azure Policies that are found in the Excel Spreadsheet. Example: -azPolicies

      .PARAMETER azInitiatives
      This switch is used to indicate that you want to create Azure Initiatives that are found in the Excel Spreadsheet. Example: -azInitiatives
   
      .PARAMETER azRoles
      This switch is used to indicate that you want to create Azure Roles that are found in the Excel Spreadsheet. Example: -azRoles

      .PARAMETER azBlueprints
      This switch is used to indicate that you want to create Azure Blueprints that are found in the Excel Spreadsheet. Example: -azBlueprints

      .PARAMETER azRoleAssignments
      This switch is used to indicate that you want to create Azure Role Assignments that are found in the Excel Spreadsheet. Example: -azRoleAssignments

      .PARAMETER azActionGroups
      This switch is used to indicate that you want to create Azure Action Groups that are found in the Excel Spreadsheet. Example: -azActionGroups

      .PARAMETER azAlerts
      This switch is used to indicate that you want to create Azure Alerts that are found in the Excel Spreadsheet. Example: -azAlerts

      .PARAMETER location (default centralus)
      location for Azure Blueprint deployment

      .PARAMETER alertResourceGroup (default rg-yazy-shared-dev-cus)
      Resource group to deploy Azure Alerts to



      .PARAMETER removeRG (default $false)
      Switch to remove resource groups during blueprint purge

      Stop: Displays the error message and stops executing.
      Inquire: Displays the error message and asks you whether you want to continue.
      Continue: (Default) Displays the error message and continues executing.
      Suspend: Automatically suspends a work-flow job to allow for further investigation. After investigation, the work-flow can be resumed.
      SilentlyContinue: No effect. The error message isn't displayed and execution continues without interruption.

      .EXAMPLE
      .\deploy-tests.ps1 -orgTag "yazy" -location "eastus" -envTag "dev" -suffix "eus" -adapCMDBfile "dev-adap-cmdb.xlsm" -deployAction "create" -azAll
      .\deploy-tests.ps1 -orgTag "yazy" -location "eastus" -envTag "dev" -suffix "eus" -adapCMDBfile "dev-adap-cmdb.xlsm" -deployAction "remove" -removeRG -azAll
      .\deploy-tests.ps1 -orgTag "yazy" -location "eastus" -envTag "dev" -suffix "eus" -adapCMDBfile "dev-adap-cmdb.xlsm" -deployAction "create" -adUsers

  #>
  param(
    # orgTag
    [Parameter(Mandatory=$True,HelpMessage='Enter organization string between 1 and 4 characters. This is used to create resources in Azure that are globally unique. Example: -orgTag adw')]
    [ValidateLength(1,4)]
    [string]$orgTag,

    # location
    [Parameter(Mandatory=$True,HelpMessage='Enter the Azure Location for the deployment. All resources and resource groups will be created in this Azure Region. Example: -location eastus')]
    [validateset('canadacentral','canadaeast','centralus','eastus','eastus2','northcentralus','southcentralus','westcentralus','westus','westus2')]
    [string]$location,

    # envTag
    [Parameter(Mandatory=$True,HelpMessage='Enter 3 character environment string. This is used to create resources in Azure that are globally unique. Example: -envTag dev')]
    [ValidateLength(3,3)]
    [string]$envTag,

    # suffix
    [Parameter(Mandatory=$True,HelpMessage="Enter resource suffix string between 1 and 4 characters. This is used to create resources in Azure that are globally unique. Example: -suffix ''eus2''")]
    [ValidateLength(1,4)]
    [string]$suffix,

    # deployAction
    [Parameter(Mandatory=$True,HelpMessage="Enter deployment action: create or purge. This switch is used to either create or remove the Azure Resources. Example: -deployAction ''create''")]
    [validateset('create','remove')]
    [string]$deployAction,

    # removeRG
    [Parameter(HelpMessage='This switch is used to indicate that you want to remove the Azure Resource Groups. It is only valid if deployAction -eq remove. Example: -removeRG')]
    [switch]$removeRG,

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
  #Clear-Host
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

   # Set Excel Spreadsheet
  $adapCMDB = "$psConfigDirectory\$adapCMDBfile"

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
      $azureEnvironment = $config.azureEnvironment
      $orgTagDefault = $config.orgTag
      $location = $config.primaryLocation
      $locationName = $config.primaryLocationName
      $adOUPath = $config.adOUPath
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
    Write-Information  'No file specified or file {0}\{1} does not exist.' -f $psConfigDirectory, $adapCMDBfile
    Exit
  }
  
     
    $testRG = 'rg-test'
    $smokeRG = 'rg-smoke'
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
    Import-Module 'Az'
    Load-Module 'Az.Blueprint'
    Load-Module 'AzureAD'
    Load-Module 'Azure.Storage'
    Load-Module 'Pester'
    Load-Module 'PSDocs'
    Load-Module 'PsISEProjectExplorer'
    Load-Module 'ImportExcel'
    
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
        Write-Information 'Logon to Azure AD'
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
    Update-StringInFile -searchStr $orgTagDefault -replaceStr $orgTag -rootDirectory $rootAzuredeploy -fileExtension 'json'
    Update-StringInFile -searchStr $orgTagDefault -replaceStr $orgTag -rootDirectory $rootAzuredeploy -fileExtension 'yml'
    Update-StringInFile -searchStr $orgTagDefault -replaceStr $orgTag -rootDirectory $rootAzuredeploy -fileExtension 'psm1'
  }
  else {
    Write-Information "OrgTag are the same $orgTagDefault to $orgTag - no changes needed."
  }

 
  Set-Location -Path "$psscriptsRoot"  
  $subscriptionId = Get-SubscriptionId
       
  
  
    
  Set-Location -Path $psscriptsRoot
  # Completing Deployment of Azure Assets
  Write-Information 'Completing deployment of Azure Assets'

  # Remove variable
  #((Compare-Object -ReferenceObject (Get-Variable).Name -DifferenceObject $DefaultVariables).InputObject).foreach{Remove-Variable -Name $_}
