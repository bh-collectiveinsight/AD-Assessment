# Import Active Directory module if not already imported
Import-Module ActiveDirectory

# Get all PSOs (Password Settings Objects) to identify users they apply to
$allPSOs = Get-ADFineGrainedPasswordPolicy -Filter * -ErrorAction SilentlyContinue
$psoUsers = @()

# Collect all users associated with each PSO
foreach ($pso in $allPSOs) {
    $users = Get-ADFineGrainedPasswordPolicySubject -Identity $pso.Name -ErrorAction SilentlyContinue
    foreach ($user in $users) {
        # Add each user to the result with their associated PSO
        $psoUsers += [PSCustomObject]@{
            UserName          = $user.Name
            SamAccountName    = $user.SamAccountName
            DistinguishedName = $user.DistinguishedName
            PSOName           = $pso.Name
        }
    }
}

# Display the results
$psoUsers | Format-Table -AutoSize

# Optional: Export results to CSV
$psoUsers | Export-Csv -Path "C:\temp\UsersWithPSO.csv" -NoTypeInformation -Encoding UTF8
