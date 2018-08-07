Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-Ous.ps1" -Force -ErrorAction Stop

Describe "Export-Ous" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
