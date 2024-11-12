# Import the Active Directory module
Import-Module ActiveDirectory

# Get all Organizational Units (OUs) in the domain
$OUs = Get-ADOrganizationalUnit -Filter *

# Create an array to store the results
$aclResults = @()

foreach ($OU in $OUs) {
    # Get the ACL for each OU
    $acl = Get-Acl -Path ("AD:\" + $OU.DistinguishedName)

    # Process each ACL entry
    foreach ($ace in $acl.Access) {
        # Store the OU ACL information in a custom object
        $aclResults += [PSCustomObject]@{
            OUName         = $OU.Name
            DistinguishedName = $OU.DistinguishedName
            IdentityReference = $ace.IdentityReference
            ActiveDirectoryRights = $ace.ActiveDirectoryRights
            AccessControlType = $ace.AccessControlType
            InheritanceType = $ace.InheritanceType
            ObjectType = $ace.ObjectType
            InheritedObjectType = $ace.InheritedObjectType
        }
    }
}

# Display results in the console
$aclResults | Format-Table -AutoSize

# Optional: Export to CSV
$aclResults | Export-Csv -Path "C:\temp\OU_ACL_Settings.csv" -NoTypeInformation -Encoding UTF8
