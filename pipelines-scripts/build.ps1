param(
    [Parameter(Mandatory=$true)]$mgId, 
    [Parameter(Mandatory=$true)]$BlueprintFolder,
    [Parameter(Mandatory=$true)]$blueprintName,
    [Parameter(Mandatory=$true)]$spnId,
    [Parameter(Mandatory=$true)]$spnPass,
    [Parameter(Mandatory=$true)]$tenantId
)

# Output powershell version for debugging purposes and is probably generally good to know
$PSVersionTable.PSVersion # Assuming powershell core (6)

if (!(Get-Module -ListAvailable -Name Az.Blueprint)) {
    Write-Host "Installing Az module"
    Install-Module -Name Az.Blueprint -AllowClobber
}else
{
    Write-Host "Az.Blueprint module already exists"
}

Write-Host "Start login with SPN"
$pass = ConvertTo-SecureString $spnPass -AsPlainText -Force
$cred = New-Object -TypeName pscredential -ArgumentList $spnId, $pass
Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId
Write-Host "Successfully logged in with SPN"

Write-Host "Azure context:"
Get-AzContext

Write-Host "Start Blueprint import"
Import-AzBlueprintWithArtifact -Name $blueprintName -ManagementGroupId $mgId -InputPath $BlueprintFolder -Force

# success
if ($?) {
    Write-Host "Imported successfully"

    $date = Get-Date -UFormat %Y%m%d.%H%M%S
    $genVersion = "$date.TEST" # todo - use the version from DevOps
    
    $importedBp = Get-AzBlueprint -ManagementGroupId $mgId -Name $blueprintName 
    Publish-AzBlueprint -Blueprint $importedBp -Version $genVersion

    # TODO - Clean up old test version(s)
} else {
    throw "Failed to import successfully"
    exit 1
}
