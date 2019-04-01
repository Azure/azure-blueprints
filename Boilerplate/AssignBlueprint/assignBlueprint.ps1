# .\Boilerplate\AssignBlueprint\assignBlueprint.ps1 -managementGroupId ContosoRoot -subscriptionId "e93d3ee6-fac1-412f-92d6-bfb379e81af2"

param(
    [Parameter(Mandatory=$true)]$managementGroupId,
    [Parameter(Mandatory=$true)]$subscriptionId
)

$blueprintName = "Boilerplate"
$contributors = "caeebed6-cfa8-45ff-9d8a-03dba4ef9a7d" # this is my princiapl ID in the microsoft tenant so you should change this :)

# Get the version of the blueprint you want to assign, which we will pas to New-AzBlueprintAssignment
$myBluerpint = Get-AzBlueprint -ManagementGroupId $managementGroupId -Name $blueprintName -LatestPublished

# Each resource group artifact in the blueprint will need a hashtable for the actual RG name and location
$rgHash = @{ name="MyBoilerplateRG"; location = "eastus" }

# all other (non-rg) parameters are listed in a single hashtable, with a key/value pair for each parameter
$parameters = @{ principalIds=$contributors }

# All of the resource group artifact hashtables are themselves grouped into a parent hashtable
# the 'key' for each item in the table should match the RG placeholder name in the blueprint
$rgArray = @{ SingleRG = $rgHash }

# Assign the new blueprint to the specified subscription (Assignment updates should use Set-AzBlueprintAssignment
New-AzBlueprintAssignment -Blueprint $myBluerpint -Location eastus -SubscriptionId $subscriptionId -ResourceGroupParameter $rgArray -Parameter $parameters