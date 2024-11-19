# Import the Group Policy module
Import-Module GroupPolicy

# Initialize an array to store GPOs with unresolved SIDs
$unresolvedSIDs = @()

# Retrieve all GPOs in the domain
$gpos = Get-GPO -All

foreach ($gpo in $gpos) {
    # Get the security descriptor for each GPO, which includes permissions
    $gpoPermissions = Get-GPPermission -Guid $gpo.Id -All

    # Check each permission entry for unresolved SIDs
    foreach ($permission in $gpoPermissions) {
        # Attempt to get the SID from the GPTrustee object
        $sid = $permission.Trustee.SID.Value

        # If the SID is not found in Active Directory, it will return $null
        if (-not (Get-ADObject -Filter { ObjectSID -eq $sid } -ErrorAction SilentlyContinue)) {
            # If the SID does not resolve to an AD object, add it to the unresolved SIDs array
            $unresolvedSIDs += [PSCustomObject]@{
                GPOName = $gpo.DisplayName
                GPOID = $gpo.Id
                TrusteeSID = $sid
                Permission = $permission.Permission
            }
        }
    }
}

# Output unresolved SIDs to the console
if ($unresolvedSIDs.Count -gt 0) {
    Write-Output "Unresolved SIDs found in the following GPOs:"
    $unresolvedSIDs | Format-Table -AutoSize
} else {
    Write-Output "No unresolved SIDs found in the GPOs."
}

# Optionally, export the results to a CSV file
$outputCsvPath = "C:\temp\UnresolvedSIDsInGPOs.csv"
$unresolvedSIDs | Export-Csv -Path $outputCsvPath -NoTypeInformation -Encoding UTF8

Write-Output "Results have been saved to $outputCsvPath"
