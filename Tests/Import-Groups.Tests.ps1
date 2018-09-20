Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Import-Groups.ps1" -Force -ErrorAction Stop
Describe "Import-Groups" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
