Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Start-OpenStack.ps1" -Force -ErrorAction Stop
Describe "Start-OpenStack" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
