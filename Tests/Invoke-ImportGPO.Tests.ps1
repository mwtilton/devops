Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Invoke-ImportGPO.ps1" -Force -ErrorAction Stop
Describe "Invoke-ImportGPO" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
