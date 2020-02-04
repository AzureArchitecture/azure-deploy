<#

.SYNOPSIS
Deploys all the policies in the root folder and child folders.

.DESCRIPTION
Create an App Service Plan and App Service and set configuration properties. The script will also check the availability
of the chosen name for the App Service.

.PARAMETER rootDirectory
The location of the folder that is the root where the script will start from

.PARAMETER subscriptionId
The subscriptionid where the policies will be applied

.PARAMETER managementGroupName
The managementGroupName where the policies will be applied

.PARAMETER resourceGroupName
The resourceGroupName where the policies will be applied

.EXAMPLE
.\Deploy-Policies.ps1 -rootDirectory "\" -subscriptionId 323241e8-df5e-434e-b1d4-a45c3576bf80 -resourceGroupName rgtest
#>
param(
    [Parameter(Mandatory=$true,HelpMessage='Root Directory where Policy files are located')]
    [string] $rootDirectory,
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $subscriptionId,
    [Parameter(Mandatory = $false)]
    [string] $managementGroupName,
    [Parameter(Mandatory = $false)]
    [string] $resourceGroupName
)

# Set working directory to path specified by rootDirectory var
Set-Location -Path $rootDirectory -PassThru
Import-Module -Name $PSScriptRoot\config\submgmt -Force
Import-Module -Name $PSScriptRoot\config\config -Force

# Get Azure credentials if not already logged on,  Use -Force to select a different subscription
Initialize-Subscription
$config = Get-Configuration
$azurePolicies = $config.azurePolicies

if(!$subscriptionId -and !$managementGroupName)
{
    Throw 'Unable to create policy: Subscription Id or Management Group Name were not provided. Either may be provided, but not both.'
}

if ($subscriptionId -and $managementGroupName)
{
    Throw 'Unable to create policy: Subscription Id and Management Group Name were both provided. Either may be provided, but not both.'
}

if ($managementGroupName -and $resourceGroupName)
{
    Throw 'Unable to create policy: Management Group Name and Resource Group Name were both provided. Either may be provided, but not both.'
}

$Az.Module = (Get-Module -Name Az)
if ($managementGroupName -and (-not $Az.Module -or $Az.Module.version -lt 1.1))
{
    Throw 'For creating policy as management group, Azure PS installed version should be equal to or greater than 6.4'
}

foreach($parentDir in Get-ChildItem -Directory)
{
    foreach($childDir in Get-ChildItem -Path $parentDir -Directory)
    {
        $configFile = ('{0}\{1}\policy.config.json' -f $parentDir, $childDir)
        $rulesFile = ('{0}\{1}\policy.rules.json' -f $parentDir, $childDir)
        $paramFile = ('{0}\{1}\policy.parameters.json' -f $parentDir, $childDir)

        $policyName  = (Get-Content -Path $configFile | ConvertFrom-Json).config.policyName.value
        $policyDisplayName = (Get-Content -Path $configFile | ConvertFrom-Json).config.policyDisplayName.value
        $policyDescription = (Get-Content -Path $configFile | ConvertFrom-Json).config.policyDescription.value
        $assignmentName = (Get-Content -Path $configFile | ConvertFrom-Json).config.assignmentName.value
        $assignmentDisplayName = (Get-Content -Path $configFile | ConvertFrom-Json).config.assignmentDisplayName.value
        $assignmentDescription = (Get-Content -Path $configFile | ConvertFrom-Json).config.assignmentDescription.value
        $policySetName = (Get-Content -Path $configFile | ConvertFrom-Json).config.policySetName.value
        $policyCategory = (Get-Content -Path $configFile | ConvertFrom-Json).config.policyCategory.value

        $cmdletParameters = @{Name=$policyName; Policy=$rulesFile; Parameter=$paramFile; Mode='Indexed'}

		if ($policyCategory)
        {
            $cmdletParameters += @{Metadata=$policyCategory}
        }

        if ($policyDisplayName)
        {
            $cmdletParameters += @{DisplayName=$policyDisplayName}
        }

        if ($policyDescription)
        {
            $cmdletParameters += @{Description=$policyDescription}
        }

        if ($subscriptionId)
        {
            $cmdletParameters += @{SubscriptionId=$subscriptionId}
        }

        if ($managementGroupName)
        {
            $cmdletParameters += @{ManagementGroupName=$managementGroupName}
        }
        foreach ($policy in $azurePolicies)
        {
            $polName = $policy[0]
            $status = $policy[1]
            if(($polName -eq $childDir) -and ($status -eq 'enabled'))
            {
                Write-Host 'deplying policy: ' $polName
		        &New-AzPolicyDefinition @cmdletParameters

            if ($managementGroupName)
            {
                $scope = ('/providers/Microsoft.Management/managementGroups/{0}' -f $managementGroupName)
                $searchParameters = @{ManagementGroupName=$managementGroupName}
            }
            else
            {
                if (!$subscriptionId)
                {
                    $subscription = Get-AzContext | Select-Object -ExpandProperty Subscription
                    $subscriptionId = $subscription.Id
                }

                $scope = ('/subscriptions/{0}' -f $subscriptionId)
                $searchParameters = @{SubscriptionId=$subscriptionId}

                if ($resourceGroupName)
                {
                    $scope += ('/resourceGroups/{0}' -f $resourceGroupName)
                }
            }

            $cmdletParameters = @{Name=$assignmentName; Scope=$scope}
            if ($assignmentDisplayName)
            {
                $cmdletParameters += @{DisplayName=$assignmentDisplayName}
            }

            if ($assignmentDescription)
            {
                $cmdletParameters += @{Description=$assignmentDescription}
            }

            if ($policyName)
            {
                $policyDefinition = Get-AzPolicyDefinition @searchParameters | Where-Object { $_.Name -eq $policyName }
                if (!$policyDefinition)
                {
                    Write-Error -Message ('Unable to create policy assignment: policy definition {0} does not exist' -f $policyName)
                    exit 1
                }

                $cmdletParameters += @{PolicyDefinition=$policyDefinition}
            }

            if ($policySetName)
            {
                $policySetDefinition = Get-AzPolicySetDefinition @searchParameters | Where-Object { $_.Name -eq $policySetName }
                if (!$policySetDefinition)
                {
                    Write-Error -Message ('Unable to create policy assignment: policy set definition {0} does not exist' -f $policySetName)
                    exit 1
                }

                $cmdletParameters += @{PolicySetDefinition=$policySetDefinition}
            }

            &New-AzPolicyAssignment @cmdletParameters
        }
    }
    }
}
