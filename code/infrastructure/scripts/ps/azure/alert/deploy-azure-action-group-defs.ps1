<#

.SYNOPSIS
Deploys all the action group definitions in the root folder and child folders.

.PARAMETER rootDirectory
The location of the folder that is the root where the script will start from

.PARAMETER action
The action to take on the resource - create or purge

.PARAMETER resourceGroupName
The resourceGroupName where the action groups will be applied

.EXAMPLE
.\deploy-azure-action-group-defs.ps1 -rootDirectory '.\alert\actiongroup' -resourceGroupName "rg-adap" -action "create"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,HelpMessage='Excel Spreadsheet with Configuration Information.')]
    [string]$adapCMDB,
    [Parameter(Mandatory=$true,HelpMessage='Root Directory where Action Group files are located')]
    [string] $rootDirectory,
    [Parameter(Mandatory=$true,HelpMessage='Action to take.')]
    [ValidateSet("create","purge")] $action,
    [Parameter(Mandatory=$true,HelpMessage='Resource Group.')]
    [string] $resourceGroupName
)

# Set working directory to path specified by rootDirectory var
Set-Location -Path  $rootDirectory -PassThru
try{
$resourceGroupExist = Get-AzResourceGroup -Name $resourceGroupName
if(!$resourceGroupExist)
{
    Write-Host -ForegroundColor RED    "    ERROR creating Azure Action Group: $resourceGroupName does not exist."
    exit
}
  }
  catch
  {
        Write-Host -ForegroundColor RED    "    ERROR creating Azure Action Group: $resourceGroupName does not exist."
    exit
  }

if ($action -eq "purge")
{
  # loop through action groups and delete
  $actiongroups = Get-AzActionGroup
  foreach ($group in $actiongroups) {
    $temp = "    Removing Action Group: {0}" -f $group.Name
    Write-Information $temp
    Remove-AzActionGroup -Name $group.Name -ResourceGroupName $resourceGroupName
  }
  exit
}

foreach($parentDir in Get-ChildItem -Directory)
{
  foreach($childDir in Get-ChildItem -Path $parentDir -Directory)
  {
    $templateFile = ('{0}\{1}\azuredeploy.json' -f $parentDir, $childDir)
    $paramFile = ('{0}\{1}\azuredeploy.parameters.json' -f $parentDir, $childDir)
    Write-Information  "    Creating Azure Action Group:  $childDir"
    New-AzResourceGroupDeployment -Name $childDir  -ResourceGroupName $resourceGroupName -TemplateFile $templateFile -TemplateParameterFile $paramFile
  }
}
