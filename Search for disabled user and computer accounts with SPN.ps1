# Search for disabled user and computer accounts with SPNs
$disabledAccounts = Get-ADObject -Filter {
    (Enabled -eq $false) -and (ServicePrincipalName -like "*")
} -Properties ServicePrincipalName, Name, ObjectClass, SamAccountName

# Prepare data for export
$exportData = $disabledAccounts | ForEach-Object {
    if ($_.ServicePrincipalName) {
        [PSCustomObject]@{
            AccountName = $_.SamAccountName
            Name = $_.Name
            ObjectClass = $_.ObjectClass
            ServicePrincipalNames = ($_.ServicePrincipalName -join ", ")
        }
    }
}

# Export to CSV
$exportData | Export-Csv -Path "C:\temp\DisabledAccountsWithSPNs.csv" -NoTypeInformation -Encoding UTF8
