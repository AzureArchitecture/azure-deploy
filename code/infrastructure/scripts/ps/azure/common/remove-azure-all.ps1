  # loop through policy assignments
  $policies = Get-AzPolicyAssignment -InformationAction Ignore
  foreach ($policy in $policies) {
    $temp = "    Removing policy assignment: {0}" -f $policy.Name
    Write-Host -foreground YELLOW $temp  -InformationAction $informationPreferenceVariable
    Remove-AzPolicyAssignment -ResourceId $policy.ResourceId -ErrorAction $actionErrorVariable -InformationAction Ignore
  }

  	# Get and delete all of the policy set definitions. Skip over the built in policy definitions.
    $policySetDefinitions = Get-AzPolicySetDefinition -Custom
    foreach ($policySetDefinition in $policySetDefinitions) {
      Write-Host "    Removing Policy Set Definition:" $policySetDefinition.Name
      Remove-AzPolicySetDefinition -Name $policySetDefinition.Name -Force -ErrorAction $actionErrorVariable  -InformationAction $informationPreferenceVariable
    }

# remove all blueprint assignments
$bps = Get-AzBlueprintAssignment -SubscriptionId $subcriptionId
foreach ($bp in $bps) {
    $temp = "Deleting blueprint assignment {0}" -f $bp.Name
    Write-Host $temp
    Remove-AzBlueprintAssignment -Name $bp.Name
}

# loop through each rg in a sub
$rgs = Get-AzResourceGroup
foreach ($rg in $rgs) {
    $temp = "Deleting {0}..." -f $rg.ResourceGroupName
    Write-Host $temp
    Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force # delete the current rg
    # some output on a good result
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

  $alerts = Get-AzAlert
  foreach ($def in $alerts) {
    $temp = "    Removing Action Group: {0}" -f $def.Name
    Write-Host -foreground YELLOW $temp  -InformationAction $informationPreferenceVariable
    Remove-Az -Name $def.Name -ResourceGroupName $resourceGroupName -ErrorAction $actionErrorVariable
  }
  
    # loop through action groups and delete
  $actiongroups = Get-AzActionGroup
  foreach ($group in $actiongroups) {
    $temp = "    Removing Action Group: {0}" -f $group.Name
    Write-Host -foreground YELLOW $temp  -InformationAction $informationPreferenceVariable
    Remove-AzActionGroup -Name $group.Name -ResourceGroupName $resourceGroupName -ErrorAction $actionErrorVariable
  }