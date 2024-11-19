# Specify the output file path
$outputFile = "C:\temp\NonReadAccessGPOs.csv"

# Initialize an array to store results
$results = @()

# Get the domain's Group Policy container
$gpoContainerPath = "CN=Policies,CN=System," + (Get-ADDomain).DistinguishedName

# Get all GPOs in the domain
$gpos = Get-ADObject -Filter {ObjectClass -eq "groupPolicyContainer"} -SearchBase $gpoContainerPath -Properties displayName, nTSecurityDescriptor

foreach ($gpo in $gpos) {
    # Get the ACL (Access Control List) for the GPO
    $acl = Get-Acl -Path "AD:$($gpo.DistinguishedName)"
    
    # Loop through each access rule in the ACL
    foreach ($ace in $acl.Access) {
        # Filter users with permissions other than "Read"
        if ($ace.AccessControlType -eq "Allow" -and $ace.ActiveDirectoryRights -ne "Read") {
            # Add to results
            $results += [PSCustomObject]@{
                GPOName         = $gpo.DisplayName
                UserOrGroup     = $ace.IdentityReference
                Permissions     = $ace.ActiveDirectoryRights
                AccessType      = $ace.AccessControlType
            }
        }
    }
}

# Export results to CSV
if ($results.Count -gt 0) {
    $results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
    Write-Output "Results exported to $outputFile"
} else {
    Write-Output "No users with non-'Read' access found on GPOs."
}
