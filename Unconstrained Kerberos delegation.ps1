# Import Active Directory module if not already imported
Import-Module ActiveDirectory

# Search for all users with Unconstrained Kerberos Delegation enabled
$unconstrainedDelegationUsers = Get-ADUser -Filter {TrustedForDelegation -eq $true} -Properties TrustedForDelegation

# Display the results
$unconstrainedDelegationUsers | Select-Object Name, SamAccountName, DistinguishedName | Format-Table -AutoSize

# Optional: Export results to CSV
$unconstrainedDelegationUsers | Select-Object Name, SamAccountName, DistinguishedName | Export-Csv -Path "C:\temp\UnconstrainedDelegationUsers.csv" -NoTypeInformation -Encoding UTF8
