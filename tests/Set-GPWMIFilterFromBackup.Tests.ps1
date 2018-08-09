Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Set-GPWMIFilterFromBackup.ps1" -Force -ErrorAction Stop
Describe "Set-GPWMIFilterFromBackup" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
