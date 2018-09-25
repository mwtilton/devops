Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-WMIFilter.ps1" -Force -ErrorAction Stop
Describe "Export-WMIFilter" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
