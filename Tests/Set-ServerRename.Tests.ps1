Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Set-ServerRename.ps1" -Force -ErrorAction Stop
Describe "Set-ServerRename" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
