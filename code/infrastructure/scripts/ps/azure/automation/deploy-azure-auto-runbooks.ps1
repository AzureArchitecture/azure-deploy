<#
    .SYNOPSIS
    Deploys all the runbooks in the root folder and child folders.

    .PARAMETER rootDirectory
    The location of the folder that is the root where the script will start from

    .PARAMETER action
    The action to take on the resource - create or purge

    .PARAMETER $automationAccountName
    The automation account  where the runbooks will be deployed

    .PARAMETER subscriptionId
    The subscriptionid where the policies will be applied

    .EXAMPLE
    .\deploy-azure-policy-definitions.ps1 -rootDirectory '.\policy\' -subscriptionId 323241e8-df5e-434e-b1d4-a45c3576bf80 -action "Create"
#>
param(
    [string]$adapCMDB=$adapCMDB,
    [Parameter(Mandatory=$true,HelpMessage='Root Directory where Policy files are located')]
    [string] $rootDirectory,
    [Parameter(Mandatory = $true)]
    [string] $action,
    [Parameter(Mandatory = $false)]
    [string] $resourceGroupName,
    [Parameter(Mandatory = $false)]
    [string] $automationAccountName,
    [string] $subscriptionId
      )


#$tags = @{Environment = 'Production'; Description = 'Send invites to external users AAD and add to AAD group to allow access to application via MyApps'}
 exit 
if ($action -eq "purge")
{
  # loop through runbooks
  $rbs = Get-AzAutomationRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName
  foreach ($rb in $rbs) {
    $temp = "    Removing automation runbook: {0}" -f $rb.Name
    Write-Information $temp
    Remove-AzPolicyAssignment -ResourceId $rb.ResourceId -InformationAction Ignore
  
  }
  exit
}

Set-Location -Path  $rootDirectory -PassThru

foreach($runbookFile in Get-ChildItem -Include *.* -Recurse)
{
  $runbookName = $runbookFile.Name
  try{
      Import-AzAutomationRunbook -Path "$rootDirectory" -Name $runbookName -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName -Type PowerShell -Tags $tags -Force
        Write-Information  "    Creating runbook $($runbookFile.FullName) "
    }
  catch
  {
      Write-Host -ForegroundColor RED  "    ERROR creating Azure runbook $($runbookFile.FullName) "
  }
}


#Publish-AzAutomationRunbook -Name $runbookName -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName
