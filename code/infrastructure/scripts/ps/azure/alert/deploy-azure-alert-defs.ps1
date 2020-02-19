<#

.SYNOPSIS
Deploys all the alert definitions in the root folder and child folders.

.PARAMETER rootDirectory
The location of the folder that is the root where the script will start from

.PARAMETER action
The action to take on the resource - create or purge

.PARAMETER resourceGroupName
The resourceGroupName where the action groups will be applied

.EXAMPLE
.\deploy-azure-alert-defs.ps1 -rootDirectory '.\alert\actiongroup' -resourceGroupName "rg-adap" -action "create"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,HelpMessage='Excel Spreadsheet with Configuration Information.')]
    [string]$adapCMDB,
    [Parameter(Mandatory=$true,HelpMessage='Root Directory where Action Group files are located')]
    [string] $rootDirectory,
    [Parameter(Mandatory=$true,HelpMessage='Action to take.')]
    [ValidateSet("create","purge")]$action= "create",
    [Parameter(Mandatory=$true,HelpMessage='Resource Group.')]
    [string] $resourceGroupName
)

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
      Write-Host -ForegroundColor RED  "    ERROR creating Azure Action Group: $resourceGroupName does not exist."
      exit
  }
  

if ($action -eq "purge")
{
  # loop through action groups and delete
  $alerts = get-AzScheduledQueryRule
  foreach ($def in $alerts) {
    $temp = "    Removing Alert: {0}" -f $def.Name
    Write-Information $temp
    Remove-AzScheduledQueryRule -Name $def.Name -ResourceGroupName $resourceGroupName
  }
  exit
}

foreach($parentDir in Get-ChildItem -Directory)
{
  foreach($childDir in Get-ChildItem -Path $parentDir -Directory)
  {
      try {
          $alertName = $childDir.Name + "-alert"
          $rule = get-AzScheduledQueryRule -ResourceGroupName $resourceGroupName -Name $alertName -ErrorAction SilentlyContinue
          if (!$rule){
            $templateFile = ('{0}\{1}\azuredeploy.json' -f $parentDir, $childDir)
            $paramFile = ('{0}\{1}\azuredeploy.parameters.json' -f $parentDir, $childDir)
            Write-Information  "    Creating Azure Alert:  $childDir"
            Write-Host New-AzResourceGroupDeployment -Name "$childDir" -ResourceGroupName "$resourceGroupName" -TemplateFile "$templateFile" -TemplateParameterFile "$paramFile"
            New-AzResourceGroupDeployment -Name "$childDir" -ResourceGroupName "$resourceGroupName" -TemplateFile "$templateFile" -TemplateParameterFile "$paramFile"
            }
          else
          {
            Write-Host -ForegroundColor RED  "    ERROR creating Alert: $alertName already exist."
          }
        }
      catch
      {
        Write-Host -ForegroundColor RED  "    ERROR creating Alert: $alertName"  
      }

  }
}

