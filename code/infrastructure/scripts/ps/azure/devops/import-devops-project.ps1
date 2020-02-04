   <#
      .SYNOPSIS
      This script deploys the Azure DevOps project based on the azdevop-cmdb.xlsx spreadsheet.

      .PARAMETER debugAction (default off)
      Switch to enable debugging output

      .PARAMETER actionVar (default SilentlyContinue)
      Switch to enable debugging output

      .PARAMETER action (default create)
      Create Azure Assets or Purge Azure Assets


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
  
  Set-Location -Path "$PSScriptRoot" 

  $psscriptsRoot = $PSScriptRoot

  #Folder Locations
  $projectScriptRoot = "$psscriptsRoot\..\..\..\"
  
   Set-Location -Path "$projectScriptRoot" 
   
  $psCommonDirectory = "$projectScriptRoot\ps\azure\common"
  $psConfigDirectory = "$projectScriptRoot\ps\azure\config"
  $psModuleDirectory = "$projectScriptRoot\ps\modules"
  
  if ( -not (Test-path ('{0}\azure-common.psm1' -f "$psCommonDirectory")))
  {
    Write-Information 'Shared PS modules can not be found'
    Exit
  }

  Set-Location -Path "$psModuleDirectory" 
  
  .\Az.DevOps\Import-Az.DevOpsModules.ps1


  



<#

  #Folder Locations
  $projectScriptRoot = "$psscriptsRoot\..\..\..\"
  $psCommonDirectory = "$projectScriptRoot\ps\azure\common"
  $psConfigDirectory = "$projectScriptRoot\ps\azure\config"
  $psModuleDirectory = "$projectScriptRoot\ps\modules"

  $adapCMDBfile = 'adap-cmdb.xlsm'
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

    #Install-Module -Name Posh-AzureDevOps -force -confirm:0 -AllowClobber
    #Import-module Posh-AzureDevOps -verbose:0 -ErrorAction SilentlyContinue

    $token = "mvvttbrowgdpxms2depmui5lfmksyqx4kx2fjg5es4p42qzyboza"
    $organizationName = "QDnA"


    Connect-AzDo -PersonalAccessTokens $token -OrganizationName $organizationName

    Write-Host "`tAdd Library Group: " -NoNewline
    $libraryVariableGroupRestResult = New-AzDoLibraryVariableGroup -AzDoConnection $AzDoConnection  -ApiVersion $ApiVersion -VariableGroupName $LibraryVariableGroupName 
    if ($libraryVariableGroupRestResult -ne $null) { Write-Host "`tSuccess" -ForegroundColor Green } else { Write-Host "`tFailed" -ForegroundColor Red }

    Write-Host "`tAdd Library Variable: " -NoNewline
    $libraryVariableGroupRestResult = Add-AzDoLibraryVariable -AzDoConnection $AzDoConnection  -ApiVersion $ApiVersion -VariableGroupName $LibraryVariableGroupName -VariableName $LibraryVariableName -VariableValue $LibraryVariableValue
    if ($libraryVariableGroupRestResult -ne $null) { Write-Host "`tSuccess" -ForegroundColor Green } else { Write-Host "`tFailed" -ForegroundColor Red }

    Write-Host "`tGet Library Variable Group: " -NoNewline
    $libraryVariableGroupRestResult = Get-AzDoVariableGroups -AzDoConnection $AzDoConnection  -ApiVersion $ApiVersion -VariableGroupName $LibraryVariableGroupName
    if ($libraryVariableGroupRestResult -ne $null) { Write-Host "`tSuccess" -ForegroundColor Green } else { Write-Host "`tFailed" -ForegroundColor Red }

    Write-Host "`tRemove Library Variable: " -NoNewline
    $libraryVariableGroupRestResult = Remove-AzDoLibraryVariable -AzDoConnection $AzDoConnection  -ApiVersion $ApiVersion -VariableGroupName $LibraryVariableGroupName -VariableName $LibraryVariableName
    if ($libraryVariableGroupRestResult -ne $null) { Write-Host "`tSuccess" -ForegroundColor Green } else { Write-Host "`tFailed" -ForegroundColor Red }

    #Write-Host "`tImport Library Variable: " -NoNewline
    #$libraryVariableGroupImportRestResult = Import-AzDoLibraryVariables -AzDoConnection $AzDoConnection  -ApiVersion $ApiVersion -VariableGroupName $LibraryVariableGroupName
    #if ($libraryVariableGroupImportRestResult -ne $null) { Write-Host "`tSuccess" -ForegroundColor Green } else { Write-Host "`tFailed" -ForegroundColor Red }

    Write-Host "`tRemove Library Group: " -NoNewline
    $libraryVariableGroupRestResult = Remove-AzDoLibraryVariableGroup -AzDoConnection $AzDoConnection  -ApiVersion $ApiVersion -VariableGroupName $LibraryVariableGroupName 
    if ($libraryVariableGroupRestResult -ne $null) { Write-Host "`tSuccess" -ForegroundColor Green } else { Write-Host "`tFailed" -ForegroundColor Red }
    #>
