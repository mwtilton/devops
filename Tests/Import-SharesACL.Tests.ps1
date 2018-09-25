Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Import-SharesACL.ps1" -Force -ErrorAction Stop
Describe "Import-SharesACL" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
