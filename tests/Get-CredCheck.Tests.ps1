Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-CredCheck.ps1" -Force -ErrorAction Stop

Describe "Get-CredCheck" -Tag "UNIT" {
    Context "Finds the Creds" {
        Mock Get-Credential {$true}

        Get-CredCheck

        It "calls the credential once on success" {
            Assert-MockCalled -CommandName Get-Credential -Exactly 1
        }
    }
}
