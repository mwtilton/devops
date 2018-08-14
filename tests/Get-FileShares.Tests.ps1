Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-FileShares.ps1" -Force -ErrorAction Stop

Describe "Get-FileShares" {
    Context "Finds the fileshares" {
        Mock Get-FileShare -MockWith {}
        It "returns shares" {
            Should not be $null
        }
    }
}
