$subscriptionId = "323241e8-df5e-434e-b1d4-a45c3576bf80"
$resourceGroupName = "rg-ORG-TAG-shared-dev-pcus"

# Delete policy assignments
$policies = Get-AzPolicyAssignment -InformationAction Ignore
foreach ($policy in $policies) {
  $temp = "    Removing policy assignment: {0}" -f $policy.Name
  Write-Host -foreground YELLOW $temp  -InformationAction Continue
  Remove-AzPolicyAssignment -ResourceId $policy.ResourceId -ErrorAction Continue -InformationAction Ignore
}

# Delete all of the policy set definitions
$policySetDefinitions = Get-AzPolicySetDefinition -Custom
foreach ($policySetDefinition in $policySetDefinitions) {
  Write-Host "    Removing Policy Set Definition:" $policySetDefinition.Name
  Remove-AzPolicySetDefinition -Name $policySetDefinition.Name -Force -ErrorAction Continue  -InformationAction Continue
}

# Delete all of the policy definitions
$policyDefinitions = Get-AzPolicyDefinition -Custom
foreach ($policyDefinition in $policyDefinitions) {
  Write-Information "    Removing Policy Definition "
  Remove-AzPolicyDefinition -Name $policyDefinition.Name -Force -ErrorAction SilentlyContinue
  }

# Delete Blueprint assignments
$bps = Get-AzBlueprintAssignment -SubscriptionId $subscriptionId
foreach ($bp in $bps) {
    $temp = "Deleting blueprint assignment {0}" -f $bp.Name
    Write-Host $temp
    Remove-AzBlueprintAssignment -Name $bp.Name
}

# loop through each rg in a sub
$filter = 'ORG-TAG'
$rgs = Get-AzResourceGroup | Where ResourceGroupName -like *$filter* 
Get-AzResourceLock | Where Name -NE 'dnd' | Remove-AzResourceLock -Force -ErrorAction Continue
foreach ($rg in $rgs) {
  $temp = "    Deleting {0}..." -f $rg.ResourceGroupName
  Write-Information $temp  
  Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force   -ErrorAction Continue
}

# get-azroleassignment returns assignments at current OR parent scope`
# will need to do a check on the scope property
# todo - not entirely sure how well this is working...
$rbacs = Get-AzRoleAssignment 
foreach ($rbac in $rbacs) {
    if ($rbac.Scope -eq "/subscriptions/$subscriptionId") { # extra logic to make sure we are only removing role assignments at the target sub
        Write-Host "Found a role assignment to delete" -InformationAction Continue
        Remove-AzRoleAssignment -InputObject $rbac -InformationAction Continue
    } else {
        $temp = "NOT deleting role with scope {0}" -f $rbac.Scope
         Write-Host $temp
    }
}

