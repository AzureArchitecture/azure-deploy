<#
    .SYNOPSIS
        Create Service Principals in Azure Active Directory

    .DESCRIPTION
        This script will create Service Principals from an Excel file into Azure Active Directory

    .PARAM
        $adapCMDB - Excel Spreadsheet CMDB

    .EXAMPLE
        .\create-azure-service-principal.ps1 -$adapCMDB adap-cmdb.xlsx

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
# Initialization
$start = Get-Date
Exit

# Set Preference Variables
$ErrorActionPreference = $actionErrorActionPreference
$VerbosePreference = $actionVerbosePreference
$DebugPreference = $actionDebugPreference

# Initialize Subscription and get Subscription Variables
Initialize-Subscription
$subscriptionId = Get-SubscriptionId
$subscriptionName = Get-SubscriptionName
$tenantId = Get-TenantId

# Print the values
Write-Output "Current Azure Subscription Context" -Verbose
Write-Output "***************************************************************************"
Write-Output "Subscription Id: $subscriptionId"
Write-Output "Subscription Name: $subscriptionName"
Write-Output "Tenant Id: $tenantId"

# ====================
# Begin Script
# ====================
$SepChar = '|'

[string] $guid = (New-Guid).Guid
$certPath = "$PSScriptRoot\..\..\config\"

## Process Worksheet
# Load list of Users from Worksheet
$cmdbExcel = Open-Excel
$wb = Get-Workbook -ObjExcel $cmdbExcel -Path "$PSScriptRoot\..\..\config\$adapCMDB"
$ws = Get-Worksheet -Workbook $wb -SheetName "A-ADServicePrincipals"
$ListofSPs = Get-WorksheetData -Worksheet $ws

foreach ($U in $ListofSPs)
{
        if ($U.UserPrincipalName)
        {
      $applicationName = $U.ApplicationName.Split($SepChar)
      $userPrincipalName = $U.UserPrincipalName.Split($SepChar)
      $displayName  = $U.DisplayName.Split($SepChar)
      $location  = $U.Location.Split($SepChar)
      $certPlainPassword  = $U.CertPlainPassword.Split($SepChar)
      #$secPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($certPlainPassword))
      $spnRole  = $U.SpnRole.Split($SepChar)
      $grantRoleOnSubscriptionLevel  = $true

            for ($i=0;$i -lt $userPrincipalName.Length; $i++)
            {
                $ThisUser = Get-AzADServicePrincipal -ServicePrincipalName $userPrincipalName[$i]
                if (-not $ThisUser)
                {
                  if ($action -eq 'create')
                  {
                    new-SPNApp -spnName $applicationName -SubscriptionName $subscriptionName -applicationName $applicationName -certPath $certPath -certPlainPassword $certPlainPassword -location $location
                  }
                }
                else
                {
                  if ($action -eq 'purge')
                  {
                    Write-Information  "Deleting Service Principal $($UserPrincipalName[$i]) $($DisplayName[$i]) "
                    write-host $userPrincipalName[$i] :  $displayName[$i]
                  }
                }
            }
        }
    }
 Close-Excel -ObjExcel $cmdbExcel
