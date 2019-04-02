<#

FWIW, this only cleans up one rg that the script assumes was the rg created during the last test

If the blueprint has more than 1 rg and/or subscription level artifacts, you will need to write some sort 
of cleanup logic, or make sure you are deploying an update that can be deployed cleanly through ARM 

#>

param(
    [Parameter(Mandatory=$true)]$subId, # 35ad74f4-0b37-44a7-ba94-91b6ec6026cd
    [Parameter(Mandatory=$true)]$blueprintName,
    [Parameter(Mandatory=$true)]$spnId,
    [Parameter(Mandatory=$true)]$spnPass,
    [Parameter(Mandatory=$true)]$tenantId,
    [Parameter(Mandatory=$true)]$mgId
)

# -------- Get the powershell environment set up properly ----------

# Uninstall AzureRM so we can replace with Az
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Install-Module -Name Az -Repository PSGallery -AllowClobber -Force
Uninstall-AzureRM
Write-Host "Successfully installed Az module"

Install-Module -Name Az.Blueprint -AllowClobber -Force
Write-Host "Successfully installed Az.Blueprint module"

Write-Host "Start login with SPN"
$pass = ConvertTo-SecureString $spnPass -AsPlainText -Force
$cred = New-Object -TypeName pscredential -ArgumentList $spnId, $pass
Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId

Write-Host "See which sub we've got with this SPN"
Get-azContext

# Get token for API requests
Write-Host "Getting Azure token"
$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.AccessToken
}
Write-Host "Got Token"

# ------- assign the blueprint to a test subscription ---------
$rgName = "TestRG" # rg that will be deleted for cleanup, then recreated

# Clean out the relevant sub/rgs

# todo - should check whether or not this RG exists
$rgExists = Get-AzResourceGroup -Name $rgName -ErrorAction silentlycontinue

if ($rgExists) {
    # For now, delete the SingleRG for Boilerplate
    Remove-AzResourceGroup -Name $rgName -Force
}

$userAssignedPrincipalId = "/subscriptions/d56e652e-758d-480a-8f0d-47f230264b4c/resourceGroups/managed-identities/providers/Microsoft.ManagedIdentity/userAssignedIdentities/service-admin"
$myBlueprint = Get-AzBlueprint -ManagementGroupId $mgId -Name $blueprintName -LatestPublished

# parameters for Boilerplate
<#

$rgHash = @{ name=$rgName; location = "eastus" } # single rg
$rgArray = @{ SingleRG = $rgHash } # array of all rgs

$principal = 'd3e063f7-09cb-4526-9021-4759a7ba179c' # specific to tenant
$params = @{ principalIds=$principal; genericBlueprintParameter="test"}
#>

# parameters for appnetwork
$rgHash = @{ name=$rgName; location = "eastus" } # single rg
$rgArray = @{ AppNetwork = $rgHash } # array of all rgs

$principal = 'd3e063f7-09cb-4526-9021-4759a7ba179c'
$params = @{ contributors=$principal; }

# $date = Get-Date -UFormat %Y%m%d%H%M%S # todo - use the version string from DevOps
$generatedAssignmentName = "A-$blueprintName" 

# check to see if there is an existing assignment
$oldAssignment = Get-AzBlueprintAssignment -SubscriptionId $subId -Name $generatedAssignmentName -ErrorAction silentlycontinue

if ($oldAssignment) {
    # if yes, *update* the assignment 
    Write-Host "Updating existing assignment..."
    Set-AzBlueprintAssignment -Blueprint $myBlueprint -Location eastus -SubscriptionId $subId -Parameter $params -ResourceGroupParameter $rgArray -Name $generatedAssignmentName -UserAssignedIdentity $userAssignedPrincipalId
} else {
    # if no assignment, create one
    # Assign the blueprint to a clean subscription (or matching the expected state of the sub/rg)
    # For now, assign to the sub, which creats a single RG
    Write-Host "Creating new assignment..."
    New-AzBlueprintAssignment -Blueprint $myBlueprint -Location eastus -SubscriptionId $subId -Parameter $params -ResourceGroupParameter $rgArray -Name $generatedAssignmentName -UserAssignedIdentity $userAssignedPrincipalId
}

# Check the status of the blueprint assignment

$assignment = Get-AzBlueprintAssignment -Subscription $subId -Name $generatedAssignmentName
$counter = 0 

while (($assignment.ProvisioningState -ne "Succeeded") -and ($assignment.ProvisioningState -ne "Failed")) {
    Write-Host $assignment.ProvisioningState
    Start-Sleep -Seconds 5
    $assignment = Get-AzBlueprintAssignment -Subscription $subId -Name $generatedAssignmentName
    $counter++
}

# Take action based on terminal assignment state
if ($assignment.ProvisioningState -eq "Succeeded") {
    Write-Host "Success"

    $date = Get-Date -UFormat %y%m%d.%H%M
    $genVersion = "$date.STABLE" # todo - use the version from DevOps

    # publish a new, .STABLE version
    $url = "https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Blueprint/blueprints/{1}/versions/{2}?api-version=2018-11-01-preview" -f $mgId, $blueprintName, $genVersion

    $response = Invoke-RestMethod -Uri $url -Method Put -Headers $authHeader
    Write-Host $response # need to check this and fail accordingly
} elseif ($assignment.provisioningState -eq "Failed") {
    Write-Host "Failure message" # todo - find out where the error message is in the assignment object and output it
    throw "Assignment failed to deploy"
    exit 1
} else {
    throw "Unhandled terminal state for assignment: {0}" -f $assignment.ProvisioningState 
    exit 1
}
