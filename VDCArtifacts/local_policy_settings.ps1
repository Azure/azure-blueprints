param(
    [Parameter(Mandatory = $True)]
    [Int]$MaxPwdAge,

    [Parameter(Mandatory = $True)]
    [Int]$MinPwdAge,

    [Parameter(Mandatory = $True)]
    [Int]$MinPwdLength,

    [Parameter(Mandatory = $True)]
    [Int]$PwdHistoryCount
) 
net accounts /minpwlen:$MinPwdLength
net accounts /maxpwage:$MaxPwdAge
net accounts /minpwage:$MinPwdAge
net accounts /uniquepw:$PwdHistoryCount
