Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Set-OpenRC.ps1" -Force -ErrorAction Stop
Describe "Set-OpenRC" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
