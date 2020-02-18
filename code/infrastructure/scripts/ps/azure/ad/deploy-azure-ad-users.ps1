<#
    .SYNOPSIS
        Create users in Azure Active Directory

    .DESCRIPTION
        This script will create users from an Excel file into Azure Active Directory

    .PARAM
        $adapCMDB - Excel Spreadsheet CMDB

    .EXAMPLE
        .\create-azure-ad-users.ps1 -$adapCMDB adap-cmdb.xlsx

    .NOTES
        AUTHOR: [Author]
        LASTEDIT: August 18, 2017
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,HelpMessage='Excel Spreadsheet with Configuration Information.')]
    [string]$adapCMDB = $adapCMDB,
    [Parameter(Mandatory=$true,HelpMessage='Action to take.')]
    [ValidateSet("create","purge")]$action= "create"
)

# ====================
# Begin Script
# ====================

## Process Worksheet
# Load list of Users from Worksheet
$e = Open-ExcelPackage "$adapCMDB"
$ListofUsers = Import-Excel -ExcelPackage $e -WorksheetName "ADUsers"

foreach ($U in $ListofUsers)
{
  if ($U.UserPrincipalName)
  {
    $UserPrincipalName     = $U.UserPrincipalName.ToString()
    $DisplayName  = $U.DisplayName.ToString()
    $AccountEnabled = $true
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = "Z1!xcvbnmnbvcxz"
    $MailNickName = $U.DisplayName.Replace(" ","").ToString()

    $ThisUser = Get-AzureADUser -Filter "userPrincipalName eq '$UserPrincipalName'" -Verbose

    try
    {
      if ($action -eq 'create')
      {
        if (-not $ThisUser)
        {
          Write-Information  "    Creating Azure AD User $($UserPrincipalName)..." 
          $ThisUser = New-AzureADUser -UserPrincipalName $UserPrincipalName -AccountEnabled $AccountEnabled -PasswordProfile $PasswordProfile -DisplayName $DisplayName -MailNickName $MailNickName -Verbose
        }
        else
        {
          Write-Host -ForegroundColor RED    "    ERROR Azure AD User exists: $($UserPrincipalName)" 
        }
      }
      if ($action -eq 'purge')
      {
        if ($ThisUser)
        {
          Write-Information  "    Removing Azure AD User $($UserPrincipalName)" 
          Remove-AzureADUser -ObjectId  $UserPrincipalName
        }
        else
        {
          Write-Host -ForegroundColor RED    "    ERROR Azure AD User does not exist: $($UserPrincipalName)" 
        }
      }
    }
    catch
    {
      write-host -foreground RED  "    Error Azure AD User: $($UserPrincipalName)" 
      Close-ExcelPackage $e -NoSave
    }
  }
}

Close-ExcelPackage $e -NoSave
