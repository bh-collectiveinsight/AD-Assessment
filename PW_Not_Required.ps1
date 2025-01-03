# Import Active Directory module if not already imported
Import-Module ActiveDirectory

# Search for all users with the PasswordNotRequired flag set to True
$noPasswordRequiredUsers = Get-ADUser -Filter {PasswordNotRequired -eq $true} -Properties PasswordNotRequired

# Display the results
$noPasswordRequiredUsers | Select-Object Name, SamAccountName, DistinguishedName | Format-Table -AutoSize

# Optional: Export results to CSV
$noPasswordRequiredUsers | Select-Object Name, SamAccountName, DistinguishedName | Export-Csv -Path "C:\temp\NoPasswordRequiredUsers.csv" -NoTypeInformation -Encoding UTF8
