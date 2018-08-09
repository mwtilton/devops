Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-FilesFolders.ps1" -Force -ErrorAction Stop

Describe "Get-FilesFolders" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
