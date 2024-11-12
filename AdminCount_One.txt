# Import the Active Directory module
Import-Module ActiveDirectory

# Find all users with AdminCount set to 1
$adminUsers = Get-ADUser -Filter { AdminCount -eq 1 } -Properties AdminCount, Name, SamAccountName, DistinguishedName

# Display results in the console
$adminUsers | Select-Object Name, SamAccountName, DistinguishedName, AdminCount | Format-Table -AutoSize

# Optional: Export to CSV
$adminUsers | Select-Object Name, SamAccountName, DistinguishedName, AdminCount | Export-Csv -Path "C:\temp\AdminCountUsers.csv" -NoTypeInformation -Encoding UTF8
