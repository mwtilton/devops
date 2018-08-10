Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\New-Partition.ps1" -Force -ErrorAction Stop
Describe "New-Partition" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
