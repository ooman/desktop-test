
Clear-Host
$currentDir = [System.IO.Directory]::GetCurrentDirectory()
. "$currentDir\Get-Login.ps1"

$IsDisabled = $null #$false
$LoginName =  $null 



<#
$sqlCred = Get-Credential  
$sqlCred = $psCred

$Login = $sqlCred.UserName
$SecuredPswd = $sqlCred.Password 
$Pswd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecuredPswd))            

$Login
$Pswd
#>

$tenantID = Get-AzureRmContext | ForEach-Object { $($_.Tenant).TenantId }

$gcnt = 0
$cnt = 0
Get-AzureRmSubscription -TenantId $tenantID |
    ForEach-Object {
        $a = ($_.SubscriptionName).Split('-') 
        $SubscriptionName = $a[0]
        Get-AzureRmResourceGroup |
            Get-AzureRmSqlServer| 
                ForEach-Object {
                    $ServerName =  $_.ServerName + '.database.windows.net'  
                    $cnt = 0
                    Get-Login $ServerName $IsDisabled $Login $Pswd | 
                        ForEach-Object {
                            $gcnt += 1
                            $cnt += 1
                            add-member -in $_ -membertype noteproperty  -Name  "Total" -Value $gcnt
                            add-member -in $_ -membertype noteproperty  -Name  "Item" -Value $cnt -PassThru

                        # | Where-Object { ($_.Login -eq $LoginName)  -or ($LoginName -eq $null) } 
                        }
                 } | 
                    Format-Table Total, InstanceName, Item, Login -AutoSize
    }



