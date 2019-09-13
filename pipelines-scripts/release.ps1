param(
    [Parameter(Mandatory=$true)]$mgId, 
    [Parameter(Mandatory=$true)]$BlueprintFolder,
    [Parameter(Mandatory=$true)]$blueprintName,
    [Parameter(Mandatory=$true)]$spnId,
    [Parameter(Mandatory=$true)]$spnPass,
    [Parameter(Mandatory=$true)]$tenantId,
    [Parameter(Mandatory=$true)]$parametersPath,
    [Parameter(Mandatory=$true)]$subscriptionId
)

# Output powershell version for debugging purposes and is probably generally good to know
$PSVersionTable.PSVersion # Assuming powershell core (6)

Write-Host "Installing Az module"
Install-Module -Name Az.Blueprint -AllowClobber
Write-Host "Successfully installed Az.Blueprint module"

Write-Host "Start login with SPN"
$pass = ConvertTo-SecureString $spnPass -AsPlainText -Force
$cred = New-Object -TypeName pscredential -ArgumentList $spnId, $pass
Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId

Write-Host "Azure context:"
Get-AzContext

$importedBp = Get-AzBlueprint -ManagementGroupId $mgId -Name $blueprintName -LatestPublished
# Urgent TODO - this should be idemopotent...
New-AzBlueprintAssignment -Name "pla-$blueprintName" -Blueprint $importedBp -AssignmentFile $parametersPath -SubscriptionId $subscriptionId 

# Wait for assignment to complete
$timeout = new-timespan -Seconds 5
$sw = [diagnostics.stopwatch]::StartNew()

while (($sw.elapsed -lt $timeout) -and ($AssignemntStatus.ProvisioningState -ne "Succeeded") -and ($AssignemntStatus.ProvisioningState -ne "Failed")) {
    $AssignemntStatus = Get-AzBlueprintAssignment -Name "pla-$blueprintName" -SubscriptionId $subscriptionId
    if ($AssignemntStatus.ProvisioningState -eq "failed") {
        Throw "Assignment Failed. See Azure Portal for datails."
        break
    }
}

if ($AssignemntStatus.ProvisioningState -ne "Succeeded") {
    Write-Warning "Assignment has timed out, activity is exiting."
}

# publish 'stable' version
$date = Get-Date -UFormat %Y%m%d.%H%M%S
$genVersion = "$date.STABLE" # todo - use the version from DevOps
Publish-AzBlueprint -Blueprint $importedBp -Version $genVersion


