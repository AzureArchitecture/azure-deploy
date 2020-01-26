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
       .\deploy-devops-project

   #>
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
     [string]$informationPreferenceVariable = 'Continue',

     # deployAction
     [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
     [validateset('create','purge')]
     [string]$deployAction = 'create',

     # devopsCMDB
     [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
     [string]$devopsCMDBfile = 'devops-cmdb.xlsx'

   )
   Clear-Host
   $DefaultVariables = $(Get-Variable).Name
   import-module ImportExcel -verbose:0 -ErrorAction SilentlyContinue
  
   Set-Location -Path "$PSScriptRoot" 
   $psscriptsRoot = $PSScriptRoot

   #Folder Locations
   $projectScriptRoot = "$psscriptsRoot\..\..\..\"
   $psCommonDirectory = "$projectScriptRoot\ps\azure\common"
   $psConfigDirectory = "$projectScriptRoot\ps\azure\config"
   $psModuleDirectory = "$projectScriptRoot\ps\modules"

   $devopsCMDB = "$psConfigDirectory\$devopsCMDBfile"

  
   if ( -not (Test-path ('{0}\azure-common.psm1' -f "$psCommonDirectory")) -or -not (Test-path -Path $devopsCMDB))
   {
     Write-Information 'Shared PS modules can not be found, Check path {0}.' -f $psCommonDirectory
     exit
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
   $azdoTAP = $config.azdoTAP
   $azdoOrgName = $config.azdoOrgName
   
   # load Az.DevOps Module
   Set-Location -Path "$psModuleDirectory" 
   .\Az.DevOps\Import-Az.DevOpsModules.ps1
   
   #connect to AzDevOps Project
   Connect-AzDo -PersonalAccessTokens $azdoTAP -OrganizationName $azdoOrgName
   exit

   $cmdbExcel = Open-Excel
   $wb = Get-Workbook -ObjExcel $cmdbExcel -Path $devopsCMDB
   $worksheets = Get-WorksheetNames -Workbook $wb
   Close-Excel -ObjExcel $cmdbExcel
   for ($w=0; $w -lt $worksheets.length; $w++) {
     Write-Verbose -Message ($worksheets.length)
     [string]$worksheetName = $worksheets[$w]
     Write-Verbose -Message ($w)
     Write-Verbose -Message ($worksheetName)
     if ($worksheetName.StartsWith("variable-group-")) {
       #$e = Open-ExcelPackage $adapCMDB
       $paramFiles = ConvertFrom-ExcelToJson -WorkSheetname $worksheetName -Path $adapCMDB
       Write-Verbose -Message ("Creating $worksheetName parameter files.")
       $p=0
       $f=0
       foreach($file in $paramFiles){
         #if ($p%2 -eq 0) {
          $jsonFile = $worksheetName.Remove(0,3)
          $TemplateParametersFilePath = "$paramDirectory\$jsonFile.$f.parameter.json"
          Write-Information "    Creating $jsonFile.$f.parameter.json parameter files."
          Write-Verbose -Message ($file)
          Set-Content -Path $TemplateParametersFilePath -Value ([Regex]::Unescape(($file | ConvertTo-Json -Depth 10))) -Force
          $f++
         #}
          $p++
        }
       $paramFiles = $null
       $p = $null
       $f = $null
     }
   }
  



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