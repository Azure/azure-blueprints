# SUBSCRIPTIONS
# Contoso IT - Retail - Prod: 45f9252d-e27e-4ed8-ab4e-dc5054de13fa
# Contoso IT - Retail - Pre-Prod: 210b13f9-e96d-493c-919e-34e12038a338 
# Contoso IT - Retail - DevTest: 35ad74f4-0b37-44a7-ba94-91b6ec6026cd

# Contoso IT - SH360 - Prod: e93d3ee6-fac1-412f-92d6-bfb379e81af2
# Contoso IT - SH360 - Pre-Prod: 71578c6b-75ba-4865-8f52-3e66d70389fd
# Contoso IT - SH360 - Dev: 0745e7d2-1e06-4d9e-9b9b-f42442b8b92f

$subscription = "e93d3ee6-fac1-412f-92d6-bfb379e81af2"

# set context to Contoso Infra1
Set-AzureRmContext -SubscriptionId $subscription

# delete all four resource groups
Remove-AzureRmResourceGroup -Name "Networking-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Security-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Management-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Application-resource-group" -Verbose -Force


# DELETE ROLE ASSIGNMENTS
# remove Contoso IT
Remove-AzureRmRoleAssignment -ObjectId "0605ea6f-1fc7-4067-bdc9-a0694a6c17b5" -RoleDefinitionName "Owner" -Scope "/subscriptions/$subscription" -Verbose

# REMOVE POLICY ASSIGNMENTS AT SUB
# get all policies assigned at this sub
$policies = Get-AzureRmPolicyAssignment

# loop through returned policies and remove them
$policies | foreach {if($_.ResourceType -eq 'Microsoft.Authorization/policyAssignments') {
        Write-Host 'Removing' $_.ResourceName
        Remove-AzureRmPolicyAssignment -Name $_.ResourceName -Scope "/subscriptions/$subscription"
    }
}


###################### SECOND SUBSCRIPTION ############################

$subscription = "71578c6b-75ba-4865-8f52-3e66d70389fd"

# set context to Contoso Infra1
Set-AzureRmContext -SubscriptionId $subscription

# delete all four resource groups
Remove-AzureRmResourceGroup -Name "Networking-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Security-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Management-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Application-resource-group" -Verbose -Force


# DELETE ROLE ASSIGNMENTS
# remove Contoso IT
Remove-AzureRmRoleAssignment -ObjectId "0605ea6f-1fc7-4067-bdc9-a0694a6c17b5" -RoleDefinitionName "Owner" -Scope "/subscriptions/$subscription" -Verbose

# REMOVE POLICY ASSIGNMENTS AT SUB
# get all policies assigned at this sub
$policies = Get-AzureRmPolicyAssignment

# loop through returned policies and remove them
$policies | foreach {if($_.ResourceType -eq 'Microsoft.Authorization/policyAssignments') {
        Write-Host 'Removing' $_.ResourceName
        Remove-AzureRmPolicyAssignment -Name $_.ResourceName -Scope "/subscriptions/$subscription"
    }
}

####################### THIRD SUBSCRIPTION #################################

$subscription = "0745e7d2-1e06-4d9e-9b9b-f42442b8b92f"

# set context to Contoso Infra1
Set-AzureRmContext -SubscriptionId $subscription

# delete all four resource groups
Remove-AzureRmResourceGroup -Name "Networking-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Security-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Management-resource-group" -Verbose -Force
Remove-AzureRmResourceGroup -Name "Application-resource-group" -Verbose -Force


# DELETE ROLE ASSIGNMENTS
# remove Contoso IT
Remove-AzureRmRoleAssignment -ObjectId "0605ea6f-1fc7-4067-bdc9-a0694a6c17b5" -RoleDefinitionName "Owner" -Scope "/subscriptions/$subscription" -Verbose

# REMOVE POLICY ASSIGNMENTS AT SUB
# get all policies assigned at this sub
$policies = Get-AzureRmPolicyAssignment

# loop through returned policies and remove them
$policies | foreach {if($_.ResourceType -eq 'Microsoft.Authorization/policyAssignments') {
        Write-Host 'Removing' $_.ResourceName
        Remove-AzureRmPolicyAssignment -Name $_.ResourceName -Scope "/subscriptions/$subscription"
    }
}