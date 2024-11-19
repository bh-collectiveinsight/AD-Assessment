# Import the Group Policy module
Import-Module GroupPolicy

# Define the path to SYSVOL's Policies directory
$sysvolPath = "\\$((Get-ADDomainController -Discover -Service PrimaryDC).Hostname)\SYSVOL\$((Get-ADDomain).DNSRoot)\Policies"

# Initialize an array to store results
$unresolvedSIDs = @()

# Loop through each GPO folder in SYSVOL
foreach ($gpoFolder in Get-ChildItem -Path $sysvolPath -Directory) {
    # Check for the presence of a gpt.ini file to confirm it's a valid GPO folder
    if (Test-Path -Path (Join-Path -Path $gpoFolder.FullName -ChildPath "gpt.ini")) {
        # Extract the GPO GUID from the folder name and retrieve the friendly name
        $gpoGuid = $gpoFolder.Name
        $gpo = Get-GPO -Guid $gpoGuid -ErrorAction SilentlyContinue

        # Skip if the GPO doesn't exist in Active Directory
        if (!$gpo) { continue }

        $gpoName = $gpo.DisplayName

        # Check for Registry.pol files or other configuration files within the GPO folder
        $polFiles = Get-ChildItem -Path $gpoFolder.FullName -Recurse -Include "*.pol", "*.inf", "*.xml" -ErrorAction SilentlyContinue

        # Parse each file for potential SIDs and capture specific settings
        foreach ($file in $polFiles) {
            $fileContent = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
+
            # Use regex to identify SIDs in the file content
            $sids = Select-String -InputObject $fileContent -Pattern "S-\d-\d{1,2}-\d{1,10}(-\d{1,10}){1,}"

            foreach ($sidMatch in $sids) {
                $sid = $sidMatch.Matches.Value

                # Attempt to resolve each SID
                try {
                    $resolvedAccount = (New-Object System.Security.Principal.SecurityIdentifier($sid)).Translate([System.Security.Principal.NTAccount]).Value
                } catch {
                    # If SID cannot be resolved, capture each instance of the setting context
                    $settingContexts = @()  # Initialize an array to store multiple contexts for the same SID

                    # For .pol files, attempt to parse registry-based settings
                    if ($file.Extension -eq ".pol") {
                        $settingContexts += "Registry-based Policy"
                    }
                    # For .xml files, attempt to retrieve the Policy name or attribute associated with the SID
                    elseif ($file.Extension -eq ".xml") {
                        try {
                            $xml = [xml]$fileContent
                            foreach ($settingNode in $xml.SelectNodes("//Policy[@name]")) {
                                $settingContexts += $settingNode.name
                            }
                        } catch {
                            $settingContexts += "Unknown XML Setting"
                        }
                    }
                    # For .inf files, locate specific sections or policies associated with SIDs
                    elseif ($file.Extension -eq ".inf") {
                        $lines = $fileContent -split "`r`n"
                        $currentSection = ""
                        foreach ($line in $lines) {
                            # Identify sections such as [Privilege Rights], [Group Membership], etc.
                            if ($line -match "\[(Privilege Rights|Group Membership|Policy)\]") {
                                $currentSection = $matches[1].Trim()
                            }
                            # Capture each instance where the SID appears within a relevant section
                            if ($currentSection -and $line -match "$sid") {
                                $settingContexts += "${currentSection}: $line"
                            }
                        }
                    }

                    # Add each setting context found to the results array
                    foreach ($context in $settingContexts) {
                        $unresolvedSIDs += [PSCustomObject]@{
                            GPOFriendlyName = $gpoName
                            GPOGuid         = $gpoGuid
                            Setting         = $context
                            FilePath        = $file.FullName
                            UnresolvedSID   = $sid
                        }
                    }
                }
            }
        }
    }
}

# Display results in table format
$unresolvedSIDs | Format-Table -AutoSize

# Optional: Export to CSV
$unresolvedSIDs | Export-Csv -Path "C:\temp\UnresolvedSIDs_SYSVOL_GPO_Report.csv" -NoTypeInformation -Encoding UTF8
