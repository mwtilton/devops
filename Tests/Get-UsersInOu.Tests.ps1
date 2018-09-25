Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-UsersInOu.ps1" -Force -ErrorAction Stop
Describe "Get-UsersInOu" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
