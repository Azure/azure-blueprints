$subcriptionId = ""

# switch to selected subscription
Set-AzContext -SubscriptionId $subcriptionId

# get all rgs
$rgs = Get-AzResourceGroup

# loop through each rg in a sub
foreach ($rg in $rgs) {
    Remove-AzResourceGroup -Name $rg.name # delete the current rg
}