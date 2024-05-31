function Get-CIPPAlertQuotaUsed {
    <#
    .FUNCTIONALITY
        Entrypoint
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [Alias('input')]
        $InputValue,
        $TenantFilter
    )


    try {
        $AlertData = New-GraphGetRequest -uri "https://graph.microsoft.com/beta/reports/getMailboxUsageDetail(period='D7')?`$format=application/json" -tenantid $TenantFilter | ForEach-Object {
            if ($_.StorageUsedInBytes -eq 0) { return }
            $PercentLeft = [math]::round(($_.storageUsedInBytes / $_.prohibitSendReceiveQuotaInBytes) * 100)
            if ($InputValue) { $Value = [int]$InputValue } else { $Value = 90 }
            if ($PercentLeft -gt $Value) {
                "$($_.userPrincipalName): Mailbox is more than $($value)% full. Mailbox is $PercentLeft% full"
            }

        }
        Write-AlertTrace -cmdletName $MyInvocation.MyCommand -tenantFilter $TenantFilter -data $AlertData
    } catch {
    }
}
