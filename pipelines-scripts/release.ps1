# Sample usage
# .\pipelines-scripts\release.ps1 -mgId "2cc4a1e3-2d9e-4d60-9f42-43da6960ac91" -blueprintName 101-boilerplate -spnId "1476502b-28c9-4b48-badc-4f5c2b74f361" -spnPass "" -tenantId "72f988bf-86f1-41af-91ab-2d7cd011db47" -parametersPath .\samples\101-boilerplate\assign.json -subscriptionId "e93d3ee6-fac1-412f-92d6-bfb379e81af2"

param(
    [Parameter(Mandatory=$true)]$mgId, 
    [Parameter(Mandatory=$true)]$blueprintName,
    [Parameter(Mandatory=$true)]$spnId,
    [Parameter(Mandatory=$true)]$spnPass,
    [Parameter(Mandatory=$true)]$tenantId,
    [Parameter(Mandatory=$true)]$parametersPath,
    [Parameter(Mandatory=$true)]$subscriptionId
)

# Output powershell version for debugging purposes and is probably generally good to know
$PSVersionTable.PSVersion # Assuming powershell core (6)

if (!(Get-Module -ListAvailable -Name Az.Blueprint)) {
    Write-Host "Installing Az module"
    Install-Module -Name Az.Blueprint -AllowClobber
} else
{
    Write-Host "Az.Blueprint module already exists"
}

Write-Host "Start login with SPN"
$pass = ConvertTo-SecureString $spnPass -AsPlainText -Force
$cred = New-Object -TypeName pscredential -ArgumentList $spnId, $pass
Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId

Write-Host "Azure context:"
Get-AzContext

$latestPublishedBp = Get-AzBlueprint -ManagementGroupId $mgId -Name $blueprintName -LatestPublished

# Auto-inserts blueprintId into parameters file
$content = Get-Content $parametersPath -raw | ConvertFrom-Json
$content.properties | % {if($_.blueprintId -ne $latestPublishedBp.id){$_.blueprintId=$latestPublishedBp.id}}
$content | ConvertTo-Json -Depth 100| set-content $parametersPath

$existingBp = Get-AzBlueprintAssignment -Name "pla-$blueprintName" -subscriptionId $subscriptionId -ErrorAction SilentlyContinue

if ($existingBp) {
    Set-AzBlueprintAssignment -Name "pla-$blueprintName" -Blueprint $latestPublishedBp -AssignmentFile $parametersPath -SubscriptionId $subscriptionId 
} else {
    Write-Host "No existing blueprint assignment. Creating one..."
    New-AzBlueprintAssignment -Name "pla-$blueprintName" -Blueprint $latestPublishedBp -AssignmentFile $parametersPath -SubscriptionId $subscriptionId
} 

# Wait for assignment to complete
$timeout = new-timespan -Seconds 500
$sw = [diagnostics.stopwatch]::StartNew()

while (($sw.elapsed -lt $timeout) -and ($AssignemntStatus.ProvisioningState -ne "Succeeded") -and ($AssignemntStatus.ProvisioningState -ne "Failed")) {
    $AssignemntStatus = Get-AzBlueprintAssignment -Name "pla-$blueprintName" -SubscriptionId $subscriptionId
    if ($AssignemntStatus.ProvisioningState -eq "failed") {
        Throw "Assignment Failed. See Azure Portal for details."
        break
    }
}

if ($AssignemntStatus.ProvisioningState -ne "Succeeded") {
    Write-Warning "Assignment has timed out, activity is exiting."
}

# publish 'stable' version
$date = Get-Date -UFormat %Y%m%d.%H%M%S
$genVersion = "$date.STBL" # todo - use the version from DevOps
$blueprint = Get-AzBlueprint -ManagementGroupId $mgId -Name $blueprintName
Publish-AzBlueprint -Blueprint $blueprint -Version $genVersion


