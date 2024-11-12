# Import Active Directory module
Import-Module ActiveDirectory

# Define a function to check inheritance for AD objects
function Get-ADObjectsWithoutInheritance {
    param(
        [string]$ObjectClass
    )

    # Find all objects of the specified class where inheritance is disabled
    Get-ADObject -Filter { ObjectClass -eq $ObjectClass } -Properties ntSecurityDescriptor, Name, DistinguishedName | Where-Object {
        $_.ntSecurityDescriptor.AreAccessRulesProtected -eq $true
    } | ForEach-Object {
        # Output results as custom objects
        [PSCustomObject]@{
            Name              = $_.Name
            DistinguishedName = $_.DistinguishedName
            ObjectClass       = $ObjectClass
            InheritanceProtected = "Yes"
        }
    }
}

# Retrieve all users, groups, and computers with inheritance disabled
$usersWithoutInheritance = Get-ADObjectsWithoutInheritance -ObjectClass "user"
$groupsWithoutInheritance = Get-ADObjectsWithoutInheritance -ObjectClass "group"
$computersWithoutInheritance = Get-ADObjectsWithoutInheritance -ObjectClass "computer"

# Combine results
$allObjectsWithoutInheritance = $usersWithoutInheritance + $groupsWithoutInheritance + $computersWithoutInheritance

# Display results in the console
$allObjectsWithoutInheritance | Format-Table -AutoSize

# Optional: Export to CSV
$allObjectsWithoutInheritance | Export-Csv -Path "C:\temp\ObjectsWithoutInheritance.csv" -NoTypeInformation -Encoding UTF8
