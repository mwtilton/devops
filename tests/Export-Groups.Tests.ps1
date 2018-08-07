Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-Groups.ps1" -Force -ErrorAction Stop

Describe "Export-Groups" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
