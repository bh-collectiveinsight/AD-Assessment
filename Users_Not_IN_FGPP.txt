# Import Active Directory module if not already imported
Import-Module ActiveDirectory

# Get all PSOs (Password Settings Objects) to identify users they apply to
$allPSOs = Get-ADFineGrainedPasswordPolicy -Filter * -ErrorAction SilentlyContinue
$psoUsers = @()

# Collect all users with an applied PSO
foreach ($pso in $allPSOs) {
    $users = Get-ADFineGrainedPasswordPolicySubject -Identity $pso.Name -ErrorAction SilentlyContinue
    $psoUsers += $users
}

# Get unique list of users with a PSO applied
$psoUsers = $psoUsers | Select-Object -Unique

# Get all users in the domain
$allUsers = Get-ADUser -Filter * -Properties Name, SamAccountName, DistinguishedName

# Filter for users not in the list of PSO-applied users
$noPsoUsers = $allUsers | Where-Object { $_.DistinguishedName -notin $psoUsers.DistinguishedName }

# Display the results
$noPsoUsers | Select-Object Name, SamAccountName, DistinguishedName | Format-Table -AutoSize

# Optional: Export results to CSV
$noPsoUsers | Select-Object Name, SamAccountName, DistinguishedName | Export-Csv -Path "C:\temp\UsersWithoutPSO.csv" -NoTypeInformation -Encoding UTF8
