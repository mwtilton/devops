Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-RemotePCInformation.ps1" -Force -ErrorAction Stop

Describe "Get-RemotePCInformation" -Tags "UNIT" {

    Context "Mocking assertions for errors" {


        It "should throw when $($paramargs.SrceServer)" {

        }
    }

}
