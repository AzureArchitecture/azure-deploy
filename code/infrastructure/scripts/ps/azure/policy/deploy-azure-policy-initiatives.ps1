<#

.SYNOPSIS
Deploys or deletes all the policy sets in the root folder and child folders.

.PARAMETER rootDirectory
The location of the folder that is the root where the script will start from

.PARAMETER action
The action to take on the resource - create or purge

.PARAMETER managementGroupName
The managementGroupName where the policies will be applied

.PARAMETER subscriptionId
The subscriptionid where the policies will be applied

.EXAMPLE
.\deploy-azure-policy-initiatives.ps1 -rootDirectory '.\policy\' -subscriptionId 323241e8-df5e-434e-b1d4-a45c3576bf80 -action "create"
#>
param(
	[string]$adapCMDB                     = $adapCMDB,
    [Parameter(Mandatory=$true,HelpMessage='Root Directory where Policy files are located')]
    [string] $rootDirectory,
    [Parameter(Mandatory = $true)]
    [string] $action,
    [Parameter(Mandatory = $false)]
    [string] $managementGroupName,
    [Parameter(Mandatory = $false)]
    [string] $subscriptionId,
    [Parameter(Mandatory = $true)]
    [string] $location
	)

if ($action -eq "purge")
{
  # loop through policy assignments
  $policies = Get-AzPolicyAssignment 
  foreach ($policy in $policies) {
    $temp = "    Removing policy assignment: {0}" -f $policy.Name
    Write-Information $temp  
    Remove-AzPolicyAssignment -ResourceId $policy.ResourceId  
  }

  	# Get and delete all of the policy set definitions. Skip over the built in policy definitions.
    $policySetDefinitions = Get-AzPolicySetDefinition -Custom
    foreach ($policySetDefinition in $policySetDefinitions) {
      Write-Host  "    Removing Policy Set Definition:" $policySetDefinition.Name
      Remove-AzPolicySetDefinition -Name $policySetDefinition.Name -Force   
    }
  exit
}

if(!$subscriptionId -and !$managementGroupName)
{
    Write-Information  "    Unable to create policy: Subscription Id or Management Group Name were not provided. Either may be provided, but not both." 
    exit
}

if ($subscriptionId -and $managementGroupName)
{
    Write-Host -ForegroundColor RED    "    ERROR Unable to create policy: Subscription Id and Management Group Name were both provided. Either may be provided, but not both." 
    exit
}

# Set working directory to path specified by rootDirectory var
Set-Location -Path  $rootDirectory -PassThru 

foreach($initFile in Get-ChildItem -Path $rootDirectory\* -Include *.json -Recurse)
{
    Write-Information  "    Creating Azure Policy Definition:  $initFile.Name" 
    try{
      New-Azdeployment -name $initFile.Name -templatefile $initFile.Fullname -Location "eastus2"
      }
    catch
    {
      Write-Host -ForegroundColor RED  "    ERROR creating policy initiative."
      throw
    }

}