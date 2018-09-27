Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-UserVHDFile.ps1" -Force -ErrorAction Stop
Describe "Get-UserVHDFile" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
