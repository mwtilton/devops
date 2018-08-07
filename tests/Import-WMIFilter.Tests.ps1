Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Import-WMIFilter.ps1" -Force -ErrorAction Stop
Describe "Import-WMIFilter" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
