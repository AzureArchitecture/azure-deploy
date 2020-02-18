<#
.SYNOPSIS
Set Azure Role Assignments

.DESCRIPTION
This script will Assign the Azure Active Directory Security Group to an Azure Role

.PARAM AADPassword
Administrator's password

.PARAM RoleAssignCSV
CSV file containing role/group definition

.EXAMPLE
.\Create-RoleAssignments.ps1 -RoleAssignCSV RoleAssign.csv

.NOTES
Depends on and submgmt.psm1, config.psm1
AUTHOR: [Author]
LASTEDIT: April 29, 2019
#>
param(
    [Parameter(Mandatory=$true,HelpMessage='Excel Spreadsheet with Configuration Information.')]
    [string]$adapCMDB = $adapCMDB,
    [Parameter(Mandatory=$true,HelpMessage='Action to take.')]
    [ValidateSet("create","purge")]$action= "create",
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$env = "dev",
    [Parameter(Mandatory=$true,HelpMessage='SubscriptionId for Scope.')]
    [string]$subscriptionId
)

# ====================
# Begin Script
# ====================

if ($action -eq "purge")
{
  try{
  $rbacs = Get-AzRoleAssignment
  foreach ($rbac in $rbacs) {
    if ($rbac.DisplayName.StartsWith("az."))
    {
    if ($rbac.Scope -eq "/subscriptions/$subscriptionId") { # extra logic to make sure we are only removing role assignments at the target sub
          Write-Information  "    Remove role assignment" -InformationAction Continue
          Remove-AzRoleAssignment -InputObject $rbac -InformationAction Continue
    } else {
        $temp = "    NOT Removing role assignment with scope {0}" -f $rbac.Scope
          Write-Information  $temp
    }
  }
    exit
    }
}
  catch {
            $temp = "    ERROR No role Assignments to remove."
          Write-Host -ForegroundColor RED  $temp
        exit
  }
  }

## Process Worksheet
# Load list of Groups from Worksheet
$e = Open-ExcelPackage "$adapCMDB"
$ListofRoleAssignments = Import-Excel -ExcelPackage $e -WorksheetName "RoleAssignments"

foreach ($U in $ListofRoleAssignments)
{
  if ($U.ADGroupName)
  {
    $ADGroupName     = $U.ADGroupName
    $AzureRole       = $U.AzureRole
    $ResourceGroup   = $U.ResourceGroup
    $Scope           = $U.Scope
  }

  $adGroup = Get-AzureADGroup -SearchString $ADGroupName
  $roles = Get-AzRoleDefinition -Name $AzureRole
  if ($adGroup -and $roles)
  {
    $ObjectId = $adGroup.ObjectId
    Write-Verbose -Message "New-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $AzureRole"
    Write-Information  "    Setting Azure Role Assignment (RBAC) - ADGroup: $($ADGroupName) Role: $($AzureRole) Scope: $($Scope) SubscriptionId: $($subscriptionId) Resource Group: $($ResourceGroup)"
    switch ($Scope) {
      'subscription' {
        $ScopePath = "/subscriptions/$subscriptionId"
        try{
          New-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $AzureRole -Scope $ScopePath -InformationAction Ignore
        break
          }
        catch
        {
          Write-Host -ForegroundColor RED  "    ERROR creating Azure Role Assignment $($roleFile.FullName) "
        }
      }
      'resourceGroups' {
        $ScopePath = $ResourceGroup
        try {
        New-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $AzureRole -ResourceGroupName $ScopePath -InformationAction Ignore
        break
          }
        catch
        {
          Write-Host -ForegroundColor RED  "    ERROR creating Azure Role Assignment $($roleFile.FullName) "
        }
      }
      default { throw New-Object -TypeName ArgumentException -ArgumentList ('data') }
    }
  }
  else
  {
    write-host -foreground RED  "    Error Setting Azure Role Assignment (RBAC) - ADGroup: $($ADGroupName) Role: $($AzureRole) Scope: $($Scope) SubscriptionId: $($subscriptionId) Resource Group: $($ResourceGroup)"
  }
}
Close-ExcelPackage $e -NoSave
