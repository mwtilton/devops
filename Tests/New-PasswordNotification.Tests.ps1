Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\New-PasswordNotification.ps1" -Force -ErrorAction Stop
Describe "New-PasswordNotification" -Tag "UNIT"{
    It "does something useful" {
        $true | Should -Be $false
    }
}
