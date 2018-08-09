Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-FileShares.ps1" -Force -ErrorAction Stop

Describe "Get-FileShares" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
