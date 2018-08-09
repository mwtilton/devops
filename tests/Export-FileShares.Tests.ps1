Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-FileShares.ps1" -Force -ErrorAction Stop
Describe "Export-FileShares" -Tags "0" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
