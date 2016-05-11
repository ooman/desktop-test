
Clear-Host
$currentDir = [System.IO.Directory]::GetCurrentDirectory()
. "$currentDir\Get-User.ps1"

$HasDBAccess = $null #$false
$AuthenticationType = $nulll # "Database"
$LoginName = $null # "APugliese"



<#
$sqlCred = Get-Credential  


$Login = $sqlCred.UserName
$SecuredPswd = $sqlCred.Password 
$Pswd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecuredPswd))            

$Login
$Pswd
#>


#$tenantID = Get-AzureAccount | Where-Object {$_.Id -eq 'tuntun@ooman7hotmail.onmicrosoft.com'} | Foreach-Object { $_.Tenants } 
$tenantID = Get-AzureRmContext | ForEach-Object { $($_.Tenant).TenantId }

$ServerName = ""

$gcnt = 0
$tcnt = 0
$cnt = 0
Get-AzureRmSubscription -TenantId $tenantID |
    ForEach-Object {
        $a = ($_.SubscriptionName).Split('-') 
        $SubscriptionName = $a[0]
        Get-AzureRmResourceGroup |
            Get-AzureRmSqlServer| 
                Get-AzureRmSqlDatabase | 
                    Sort-Object { $_.ServerName, $_.DatabaseName} |
                        ForEach-Object {
                            if ($_.ServerName + '.database.windows.net' -ne $ServerName )  {
                                $tcnt = 0
                            }                             
                            $tcnt += 1
                            $ServerName =  $_.ServerName + '.database.windows.net'                            
                            $DatabaseName = $_.DatabaseName
                            

                            $cnt = 0
                            Get-User $ServerName $DatabaseName $HasDBAccess $Login $Pswd |
                                ForEach-Object {
                                    $gcnt += 1
                                    $cnt += 1
                                    add-member -in $_ -membertype noteproperty  -Name  "GrandTotal" -Value $gcnt
                                    add-member -in $_ -membertype noteproperty  -Name  "DBItem" -Value $tcnt
                                    add-member -in $_ -membertype noteproperty  -Name  "Item" -Value $cnt -PassThru

                                }


                        } | 
                            Where-Object { ($_.Login -eq $LoginName -or $LoginName -eq $null) -and  ($_.AuthenticationType -eq $AuthenticationType -or $AuthenticationType -eq $null )} |
                                Format-Table GrandTotal, InstanceName, DBItem, DatabaseName, Item, User, Login, LoginType, AuthenticationType, DefaultSchema, HasDBAccess -AutoSize
    }


