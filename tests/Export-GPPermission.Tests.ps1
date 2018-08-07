Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-GPPermission.ps1" -Force -ErrorAction Stop

Describe "Export-GPPermission" -Tags "0" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
