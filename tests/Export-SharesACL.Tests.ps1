Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-SharesACL.ps1" -Force -ErrorAction Stop
Describe "Export-SharesACL" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
