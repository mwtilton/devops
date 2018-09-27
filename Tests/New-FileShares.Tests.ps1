Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\New-FileShares.ps1" -Force -ErrorAction Stop
Describe "New-FileShares" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
