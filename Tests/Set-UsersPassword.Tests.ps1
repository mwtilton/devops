Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Set-UsersPassword.ps1" -Force -ErrorAction Stop
Describe "Set-UsersPassword" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
