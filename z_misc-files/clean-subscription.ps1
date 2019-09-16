# Replace with your relevant subscription ID
$subcriptionId = "e93d3ee6-fac1-412f-92d6-bfb379e81af2" # Contoso IT – SH360 – Prod

# switch to selected subscription
Set-AzContext -SubscriptionId $subcriptionId

# remove all blueprint assignments
$bps = Get-AzBlueprintAssignment -SubscriptionId $subcriptionId
foreach ($bp in $bps) {
    $temp = "Deleting blueprint assignment {0}" -f $bp.Name
    Write-Host $temp
    Remove-AzBlueprintAssignment -Name $bp.Name
}

# todo - bust cache if locks were used
# get a new auth token

# loop through each rg in a sub
$rgs = Get-AzResourceGroup
foreach ($rg in $rgs) {
    $temp = "Deleting {0}..." -f $rg.ResourceGroupName
    Write-Host $temp
    Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force # delete the current rg
    # some output on a good result
}

# loop through policies
$policies = Get-AzPolicyAssignment
foreach ($policy in $policies) {
    $temp = "Removing policy assignment: {0}" -f $policy.Name
    Write-Host $temp
    Remove-AzPolicyAssignment -ResourceId $policy.ResourceId # TODO - also print display name..
}

# get-azroleassignment returns assignments at current OR parent scope`
# will need to do a check on the scope property
# todo - not entirely sure how well this is working...
$rbacs = Get-AzRoleAssignment 
foreach ($rbac in $rbacs) {
    if ($rbac.Scope -eq "/subscriptions/$subscriptionId") { # extra logic to make sure we are only removing role assignments at the target sub
        Write-Output "Found a role assignment to delete"
        Remove-AzRoleAssignment -InputObject $rbac
    } else {
        $temp = "NOT deleting role with scope {0}" -f $rbac.Scope
    }
}

