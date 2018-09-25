Function New-GPOMigrationTable {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $DestDomain,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path = '.\',  # Working path to store migration tables and backups
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $BackupPath,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $MigTableCSVPath
    )
        # Instead of manually editing multiple migration tables,
        # use a CSV template of search/replace values to update the
        # migration table by code.
        $MigTableCSV = Import-CSV $MigTableCSVPath
        $MigDomains  = $MigTableCSV | Where-Object {$_.Type -eq "Domain"}
        $MigUNCs     = $MigTableCSV | Where-Object {$_.Type -eq "UNC"}

        # Code adapted from GPMC VBScripts
        # This version uses a GPO backup to get the migration table data.

        $gpm = New-Object -ComObject GPMgmt.GPM
        $mt = $gpm.CreateMigrationTable()
        $Constants = $gpm.getConstants()
        $GPMBackupDir = $gpm.GetBackupDir($BackupPath)
        $GPMSearchCriteria = $gpm.CreateSearchCriteria()
        $BackupList = $GPMBackupDir.SearchBackups($GPMSearchCriteria)

        ForEach ($GPMBackup in $BackupList) {
            $szBackupDomain = $GPMBackup.GPODomain
            $mt.Add(0,$GPMBackup)
            $mt.Add($constants.ProcessSecurity,$GPMBackup)
        }

        $szSourceDomain = $GPMBackup.GPODomain

        ForEach ($Entry in $mt.GetEntries()) {

            Switch ($Entry.EntryType) {

                # Search/replace UNC paths from CSV file
                $Constants.EntryTypeUNCPath {
                    ForEach ($MigUNC in $MigUNCs) {
                        Write-host $MigUNC -ForegroundColor Cyan
                        If ($Entry.Source -like "$($MigUNC.Source)*") {
                            $mt.UpdateDestination($Entry.Source, $Entry.Source.Replace("$($MigUNC.Source)","$($MigUNC.Destination)"))
                        }

                    }
                }

                # Search/replace domain names from CSV file
                # v3 {$_ -in $Constants.EntryTypeLocalGroup, $Constants.EntryTypeGlobalGroup, $Constants.EntryTypeUnknown} {
                {$Constants.EntryTypeUser, $Constants.EntryTypeGlobalGroup, $Constants.EntryTypeUnknown -contains $_} {
                    ForEach ($MigDomain in $MigDomains) {
                        If ($Entry.Source -like "*@$($MigDomain.Source)") {
                            $mt.UpdateDestination($Entry.Source, $Entry.Source.Replace("@$($MigDomain.Source)","@$($MigDomain.Destination)")) | Out-Null
                        } ElseIf ($Entry.Source -like "$($MigDomain.Source)\*") {
                            $mt.UpdateDestination($Entry.Source, $Entry.Source.Replace("$($MigDomain.Source)\","$($MigDomain.Destination)\")) | Out-Null
                        }
                    }
                }

                # In some scenarios like single-domain forest the Enterprise Admin universal group needs to be migrated.
                ### Need to add logic to ignore it in other cases, as it may not always need to be translated.
                # v3 {$_ -in $Constants.EntryTypeUniversalGroup} {
                {$Constants.EntryTypeUniversalGroup -contains $_} {
                    ForEach ($MigDomain in $MigDomains) {
                        If ($Entry.Source -like "*@$($MigDomain.Source)") {
                            $mt.UpdateDestination($Entry.Source, $Entry.Source.Replace("@$($MigDomain.Source)","@$($MigDomain.Destination)")) | Out-Null
                        } ElseIf ($Entry.Source -like "$($MigDomain.Source)\*") {
                            $mt.UpdateDestination($Entry.Source, $Entry.Source.Replace("$($MigDomain.Source)\","$($MigDomain.Destination)\")) | Out-Null
                        }
                    }
                }

            } # end switch
        } # end foreach

        $MigTablePath = Join-Path -Path $Path -ChildPath "$szSourceDomain-to-$DestDomain.migtable"
        $mt.Save($MigTablePath)

        return $MigTablePath
} # End Function
