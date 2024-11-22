# Import the Active Directory module
Import-Module ActiveDirectory

# Specify the output file path
$outputFile = "C:\temp\AllSPNs_WithEncryptionTypes.csv"

# Create an array to store results
$results = @()

# Retrieve all users with SPNs and msDS-SupportedEncryptionTypes
$usersWithSPNs = Get-ADUser -Filter * -Properties ServicePrincipalName, msDS-SupportedEncryptionTypes, Enabled
foreach ($user in $usersWithSPNs) {
    foreach ($spn in $user.ServicePrincipalName) {
        $results += [PSCustomObject]@{
            AccountName              = $user.SamAccountName
            AccountType              = "User"
            SPN                      = $spn
            Enabled                  = $user.Enabled
            msDS_SupportedEncryptionTypes = $user.'msDS-SupportedEncryptionTypes'
        }
    }
}

# Retrieve all computers with SPNs and msDS-SupportedEncryptionTypes
$computersWithSPNs = Get-ADComputer -Filter * -Properties ServicePrincipalName, msDS-SupportedEncryptionTypes, Enabled
foreach ($computer in $computersWithSPNs) {
    foreach ($spn in $computer.ServicePrincipalName) {
        $results += [PSCustomObject]@{
            AccountName              = $computer.SamAccountName
            AccountType              = "Computer"
            SPN                      = $spn
            Enabled                  = $computer.Enabled
            msDS_SupportedEncryptionTypes = $computer.'msDS-SupportedEncryptionTypes'
        }
    }
}

# Export the results to a CSV file
if ($results.Count -gt 0) {
    $results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
    Write-Output "All SPNs with encryption types have been exported to $outputFile"
} else {
    Write-Output "No SPNs found in the environment."
}
