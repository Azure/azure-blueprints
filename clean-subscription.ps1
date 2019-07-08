# should get context so it can be reset at the end of exectuion

$subcriptionId = "e93d3ee6-fac1-412f-92d6-bfb379e81af2" # should make this a param

# switch to selected subscription
Set-AzContext -SubscriptionId $subcriptionId

# get all rgs
$rgs = Get-AzResourceGroup

# loop through each rg in a sub
foreach ($rg in $rgs) {
    Write-Host "Deleting {0}..." -f $rg.ResourceGroupName
    Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force # delete the current rg
}

$policies = Get-AzPolicyAssignment

foreach ($policy in $policies) {
    Write-Host "Removing policy assignment: {0}" -f $policy.Name
    Remove-AzPolicyAssignment -Name $policy.Name
}

# get-azroleassignment returns assignments at current OR parent scope
# will need to do a check on the scope property

$rbacs = Get-AzRoleAssignment 

foreach ($rbac in $rbacs) {
    if ($rbac.Scope -eq "/subscriptions/$subscriptionId") { # extra logic to make sure we are only removing role assignments at the target sub
        Remove-AzRoleAssignment -InputObject $rbac
    }
}

