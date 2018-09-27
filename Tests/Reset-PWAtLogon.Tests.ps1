Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Reset-PWAtLogon.ps1" -Force -ErrorAction Stop
Describe "Reset-PWAtLogon" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
