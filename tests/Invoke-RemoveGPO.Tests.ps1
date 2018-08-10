Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Invoke-RemoveGPO.ps1" -Force -ErrorAction Stop
Describe "Invoke-RemoveGPO" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
