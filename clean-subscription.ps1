# should get context so it can be reset at the end of exectuion

$subcriptionId = "e93d3ee6-fac1-412f-92d6-bfb379e81af2" # should make this a param

# switch to selected subscription
Set-AzContext -SubscriptionId $subcriptionId

# get all rgs
$rgs = Get-AzResourceGroup

# loop through each rg in a sub
foreach ($rg in $rgs) {
    Write-Host "Deleting $rg.ResourceGroupName..."
    Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force # delete the current rg
}