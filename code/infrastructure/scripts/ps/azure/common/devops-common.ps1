[CmdletBinding()]
    param
    (
        # Common Parameters
        [PoshAzDo.AzDoConnectObject][parameter(ValueFromPipeline=$true, ValueFromPipelinebyPropertyName=$true)]$AzDoConnection,
        #[parameter(Mandatory=$false, ValueFromPipelinebyPropertyName=$true)][string]$ProjectUrl,
        #[parameter(Mandatory=$false, ValueFromPipelinebyPropertyName=$true)][string]$PAT,
        [string]$ApiVersion = $global:AzDoApiVersion,
                
        # Script Parameters
        [string]$RepoName = $global:AzDoTestRepoName,

        [string]$ReleaseDefinitionName = $global:AzDoTestReleaseDefinitionName,
        [string]$ReleaseVariableName = $global:AzDoTestReleaseVariableName,
        [string]$ReleaseVariableValue = $global:AzDoTestReleaseVariableValue,

        [string]$LibraryVariableGroupName = $global:AzDoTestLibraryVariableGroupName,
        [string]$LibraryVariableName = $global:AzDoTestLibraryVariableName,
        [string]$LibraryVariableValue = $global:AzDoTestLibraryVariableValue
)
BEGIN
{
    Write-Verbose "Entering script $($MyInvocation.MyCommand.Name)"
    Write-Verbose "Parameter Values"
    $PSBoundParameters.Keys | ForEach-Object { Write-Verbose "$_ = '$($PSBoundParameters[$_])'" }
}
PROCESS
{
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


  

}

END 
{ 
    Write-Verbose "Leaving script $($MyInvocation.MyCommand.Name)"
}

<#

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
