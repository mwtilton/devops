Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-GPPermission.ps1" -Force -ErrorAction Stop

Describe "Export-GPPermission" -Tags "UNIT" {

    Setup -Dir "Desktop\WorkingFolder"

    $paramargs = @{
        DisplayName = "Accounting"
        SrceServer = "$env:COMPUTERNAME"
        SrceDomain = "$env:USERDNSDOMAIN"
        Path = "TestDrive:\Desktop\WorkingFolder"
    }

    Context "Mocking assertions for errors" {
        Mock Get-GPO {return "Accounting"}
        Mock Get-ADObject {return $true}

        It "should throw when $($paramargs.SrceServer)" {
            { Export-GPPermission @paramargs -ErrorAction Stop } | Should throw
        }
    }

}
