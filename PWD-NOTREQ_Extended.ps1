# Import the Active Directory module
Import-Module ActiveDirectory

# Specify the output file
$outputFile = "C:\temp\UsersWithPasswordNotRequired.csv"

# Initialize an array to store results
$results = @()

# Get all users in AD with "PasswordNotRequired" flag
$passwordNotRequiredUsers = Get-ADUser -Filter {PasswordNotRequired -eq $true} -Properties PasswordNotRequired, homeMDB, pwdLastSet, Enabled, adminCount

foreach ($user in $passwordNotRequiredUsers) {
    # Convert pwdLastSet to a readable date
    $pwdLastSetReadable = if ($user.pwdLastSet -ne 0) { [datetime]::FromFileTime($user.pwdLastSet) } else { "Never" }

    # Check if the user has a mailbox
    $hasMailbox = if ($user.homeMDB) { "Yes" } else { "No" }

    # Add user details to the results
    $results += [PSCustomObject]@{
        SamAccountName      = $user.SamAccountName
        DisplayName         = $user.Name
        HasMailbox          = $hasMailbox
        HomeMDB             = $user.homeMDB
        PasswordNotRequired = $user.PasswordNotRequired
        PwdLastSet          = $pwdLastSetReadable
        Enabled             = $user.Enabled
        AdminCount          = if ($user.adminCount -eq 1) { "Yes" } else { "No" }
    }
}

# Export results to CSV
if ($results.Count -gt 0) {
    $results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
    Write-Output "Users with 'PasswordNotRequired' have been exported to $outputFile"
} else {
    Write-Output "No users with 'PasswordNotRequired' found."
}
