Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\IsAdmin.ps1" -Force -ErrorAction Stop
Describe "IsAdmin" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
