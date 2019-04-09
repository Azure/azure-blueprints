param(
    [Parameter(Mandatory=$true)]$mgId, 
    [Parameter(Mandatory=$true)]$BlueprintFolder,
    [Parameter(Mandatory=$true)]$blueprintName,
    [Parameter(Mandatory=$true)]$spnId,
    [Parameter(Mandatory=$true)]$spnPass,
    [Parameter(Mandatory=$true)]$tenantId
)

# Output powershell version for debugging purposes and is probably generally good to know
$PSVersionTable.PSVersion # PowerShell 5

# Same with the .NET version
Write-Host ".NET 4.5 Installed: "
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' | Get-ItemPropertyValue -Name Release | Foreach-Object { $_ -ge 461808 }

# Uninstall AzureRM so we can replace with Az
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Install-Module -Name Az -Repository PSGallery -AllowClobber -Force
Uninstall-AzureRM
Write-Host "Successfully installed Az module"

# Get-Module -ListAvailable
Install-Module -Name Az.Blueprint -AllowClobber
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

Write-Host "Starting install of modules"
Install-Script -Name Manage-AzureRMBlueprint -Force
Write-Host "Finished installing modules"

Write-Host "Start Blueprint import"
Manage-AzureRMBlueprint.ps1 -Mode Import -ImportDir $BlueprintFolder -ManagementGroupID $mgId -ModuleMode Az -Force

$date = Get-Date -UFormat %Y%m%d.%H%M%S
$genVersion = "$date.TEST" # todo - use the version from DevOps

# success

if ($?) {
    Write-Host "Imported successfully"

    # Publish the blueprint with a -test version
    $url = "https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Blueprint/blueprints/{1}/versions/{2}?api-version=2018-11-01-preview" -f $mgId, $blueprintName, $genVersion

    # Invoke the REST API
    $response = Invoke-RestMethod -Uri $url -Method Put -Headers $authHeader
    Write-Host $response

    # TODO - Clean up old test version(s)
    # need cmdlets for definition management
} else {
    throw "Failed to import successfully"
    exit 1
}
