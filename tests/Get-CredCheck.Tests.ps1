Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-CredCheck.ps1" -Force -ErrorAction Stop

Describe "Get-CredCheck" -Tag "UNIT" {
    Context "Finds the Creds" {

        It "returns shares" {
            Should not be $null
        }
    }
}
