param(
    [Parameter(Mandatory = $True)]
    [Int]$MaxPwdAge,

    [Parameter(Mandatory = $True)]
    [Int]$MinPwdAge,

    [Parameter(Mandatory = $True)]
    [Int]$MinPwdLength,

    [Parameter(Mandatory = $True)]
    [Int]$PwdHistoryCount,

    [Parameter(Mandatory = $True)]
    [String]$Identity
) 

$maximumPwdAge = New-TimeSpan -Days $MaxPwdAge
$minimumPwdAge = New-TimeSpan -Days $MinPwdAge


Set-ADDefaultDomainPasswordPolicy -ComplexityEnabled $true -MaxPasswordAge $maximumPwdAge -MinPasswordAge $minimumPwdAge -MinPasswordLength $MinPwdLength -PasswordHistoryCount $PwdHistoryCount -Identity $Identity