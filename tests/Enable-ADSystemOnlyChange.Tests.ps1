Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Enable-ADSystemOnlyChange.ps1" -Force -ErrorAction Stop

Describe "Unit Testing for Enable-ADSystemOnlyChange" -tags "0" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
