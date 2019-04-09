Connect-AzureRmAccount

# Prod
& "$PSScriptRoot\clean-subscription.ps1" -subscription 'e93d3ee6-fac1-412f-92d6-bfb379e81af2'
# Pre-Prod
& "$PSScriptRoot\clean-subscription.ps1" -subscription '71578c6b-75ba-4865-8f52-3e66d70389fd'
# DevTest
& "$PSScriptRoot\clean-subscription.ps1" -subscription '0745e7d2-1e06-4d9e-9b9b-f42442b8b92f'