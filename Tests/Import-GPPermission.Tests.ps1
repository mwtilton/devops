Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Import-GPPermission.ps1" -Force -ErrorAction Stop
Describe "Import-GPPermission" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
