Connect-AzureRmAccount

# Prod
& "$PSScriptRoot\clean-subscription.ps1" -subscription '45f9252d-e27e-4ed8-ab4e-dc5054de13fa'
# Pre-Prod
& "$PSScriptRoot\clean-subscription.ps1" -subscription '210b13f9-e96d-493c-919e-34e12038a338'
# DevTest
& "$PSScriptRoot\clean-subscription.ps1" -subscription '35ad74f4-0b37-44a7-ba94-91b6ec6026cd'