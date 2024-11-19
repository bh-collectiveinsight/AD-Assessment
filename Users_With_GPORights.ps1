# Import the Group Policy module
Import-Module GroupPolicy

# Initialize an array to store results
$unresolvedSIDs = @()

# Retrieve all GPOs in the domain
$gpos = Get-GPO -All

# Loop through each GPO to check for unresolved SIDs
foreach ($gpo in $gpos) {
    # Get the GPO's ACL (permissions)
    $acl = Get-GPOReport -Guid $gpo.Id -ReportType Xml | Select-String -Pattern "<Trustee SID=.*?\/>"
    
    # Parse the ACL to find unresolved SIDs
    foreach ($entry in $acl) {
        if ($entry.Line -match '<Trustee SID="(S-\d+-\d+-\d+(-\d+)+)"') {
            $sid = $matches[1]
            
            # Check if the SID can be resolved
            try {
                $resolvedAccount = (New-Object System.Security.Principal.SecurityIdentifier($sid)).Translate([System.Security.Principal.NTAccount]).Value
            } catch {
                # If SID cannot be resolved, add it to the unresolved list
                $unresolvedSIDs += [PSCustomObject]@{
                    GPOName         = $gpo.DisplayName
                    GPOGuid         = $gpo.Id
                    UnresolvedSID   = $sid
                }
            }
        }
    }
}

# Display results in table format
$unresolvedSIDs | Format-Table -AutoSize

# Optional: Export to CSV
$unresolvedSIDs | Export-Csv -Path "C:\path\to\UnresolvedSIDs_GPO_Report.csv" -NoTypeInformation -Encoding UTF8
