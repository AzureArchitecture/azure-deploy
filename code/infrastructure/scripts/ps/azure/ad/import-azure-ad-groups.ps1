<#
    .SYNOPSIS
        Create groups in Azure Active Directory

    .DESCRIPTION
        This script will create users and groups from an Excel file into Azure Active Directory

    .PARAM
        $adapCMDB - Excel Spreadsheet CMDB

    .EXAMPLE
        Deploy-AzureADGroups -adapCMDB adap-cmdb.xlsx -action "create"

    .NOTES
        AUTHOR: [Author]
        LASTEDIT: August 18, 2019
#>
function Import-AzureADGroups
{
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,HelpMessage='Excel Spreadsheet with Configuration Information.')]
    [string]$adapCMDB,
    [Parameter(Mandatory=$true,HelpMessage='Action to take.')]
    [ValidateSet("create","purge")]$action
)

# ====================
# Begin Script
# ====================

## Process Worksheet
# Load list of Groups from Worksheet
$cmdbExcel = Open-Excel
$wb = Get-Workbook -ObjExcel $cmdbExcel -Path "$adapCMDB"
$ws = Get-Worksheet -Workbook $wb -SheetName "ADGroups"
$ListofGroups = Get-WorksheetData -Worksheet $ws

foreach ($U in $ListofGroups)
{
  if ($U.GroupName)
  {
    $GroupName     = $U.GroupName.ToString()
    $GDescription  = $U.GroupDescription.ToString()
    $GDisplayName  = $U.GroupDisplayName.ToString()
    $GMailEnabled  = $false
    $GSecEnabled   = $true
    $mailNickName  = "NotSet"

    $ThisGroup = Get-AzureADGroup -SearchString $GroupName 

   try
    {
      if ($action -eq 'create')
      {
        if (-not $ThisGroup)
        {
          Write-Information  "    Creating Azure AD Group $($Groupname)..."  
          $ThisGroup = New-AzureADGroup -displayname  $GroupName -description $Gdescription -MailEnabled $GMailEnabled  -SecurityEnabled $GSecEnabled -mailnickname $mailNickName
        }
        else
        {
          Write-Host -ForegroundColor RED    "    ERROR Azure AD Group exists: $($Groupname)" 
        }
      }
      if ($action -eq 'purge')
      {
        if ($ThisGroup)
        {
          Write-Information  "    Deleting Azure AD Group $($Groupname)" 
          Remove-AzureADGroup -ObjectId  $ThisGroup.ObjectId
        }
        else
        {
          Write-Host -ForegroundColor RED    "    ERROR Azure AD Group does not exist: $($Groupname) " 
        }
      }
    }
    catch
    {
      Write-Host -ForegroundColor RED    "    ERROR Azure AD Group: $($Groupname) " 
      Close-Excel -ObjExcel $cmdbExcel
    }
  }
}

Close-Excel -ObjExcel $cmdbExcel
}