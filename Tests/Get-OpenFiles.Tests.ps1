Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-OpenFiles.ps1" -Force -ErrorAction Stop
Describe "Get-OpenFiles" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
