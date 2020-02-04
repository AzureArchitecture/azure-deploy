<#
.SYNOPSIS
Deploys all the roles in the root folder and child folders.

.PARAMETER rootDirectory
The location of the folder that is the root where the script will start from

.PARAMETER action
The action to take on the resource - create or purge

.PARAMETER subscriptionId
The subscriptionId where the policies will be applied

.EXAMPLE
.\deploy-azure-role-definitions.ps1 -rootDirectory '.\policy\' -subscriptionId 323241e8-df5e-434e-b1d4-a45c3576bf80 -action "Create"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,HelpMessage='Excel Spreadsheet with Configuration Information.')]
    [string]$adapCMDB,
    [Parameter(Mandatory=$true,HelpMessage='Root Directory where Role files are located.')]
    [string] $rootDirectory,
    [Parameter(Mandatory=$true,HelpMessage='Action to take.')]
    [ValidateSet("create","purge")][string]$action,
    [Parameter(Mandatory=$true,HelpMessage='Subscription Id.')]
    [string] $subscriptionId
)

Set-Location -Path  $rootDirectory -PassThru

if ($action -eq "purge")
{
  try{
      $rbacs = Get-AzRoleAssignment
      foreach ($rbac in $rbacs) {
        if ($rbac.Scope -eq "/subscriptions/$subscriptionId") { # extra logic to make sure we are only removing role assignments at the target sub
              Write-Information  "    Remove role assignment" -InformationAction Continue
              Remove-AzRoleAssignment -InputObject $rbac -InformationAction Continue
        } else {
          $temp = "    NOT Removing role assignment with scope {0}" -f $rbac.Scope
          Write-Information  $temp
        }
      }
    }
  catch
  {
    $temp = "    No role Assignments to remove."
    Write-Information  $temp
    exit
  }
  # loop through policy assignments
  $roles = Get-AzRoleDefinition -Custom
  foreach ($role in $roles) {
    $temp = "    Removing Azure Role: {0}" -f $role.Name
    Write-Information $temp
    Remove-AzRoleDefinition -Id $role.Id -Force
  }
  exit
}

foreach($parentDir in Get-ChildItem -Directory)
{
  foreach($roleFile in Get-ChildItem -Path $parentDir\* -Include *.json -Recurse)
  {
    $role = $roleFile.FullName
    $roledefinition = Get-Content -Path $roleFile.FullName
    $roledefinitionNew = $roledefinition -Replace "_subscriptionId", "$subscriptionId"
    Set-Content -Path $role -Value $roledefinitionNew
    Write-Information  "    Creating Azure Role $($roleFile.FullName) "
    try{
      New-AzRoleDefinition -InputFile "$role"
      }
    catch
    {
       Write-Host -ForegroundColor RED  "    ERROR creating Azure Role $($roleFile.FullName) "
    }
    $roleOld = $roleFile.FullName
    $roledefinitionOld = $roledefinition -Replace "$subscriptionId", "_subscriptionId"
    Set-Content -Path $roleOld -Value $roledefinitionOld
  }
}
