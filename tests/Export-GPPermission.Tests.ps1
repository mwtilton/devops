Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-GPPermission.ps1" -Force -ErrorAction Stop

Describe "Export-GPPermission" -Tags "UNIT" {

    Setup -Dir "Desktop\WorkingFolder"

    $paramargs = @{
        DisplayName = "Accounting"
        SrceServer = "$env:COMPUTERNAME"
        SrceDomain = "$env:USERDNSDOMAIN"
        Path = "TestDrive:\Desktop\WorkingFolder"
    }
    #-DisplayName "Accounting" -SrceServer "$env:COMPUTERNAME" -SrceDomain "$env:USERDNSDOMAIN" -Path "TestDrive:\Desktop\WorkingFolder"
    Context "Mocking assertions for errors" {
        $list = "Accounting","Admin"

        Mock Get-GPO {return $list}
        Mock Get-ADObject -MockWith {}

        It "should throw when no args are set" {
            { Export-GPPermission -ErrorAction Stop } | Should throw
        }
        It "throws specific exception for parameter binding exception" {
            { Export-GPPermission -ErrorAction Stop } | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException])
        }
        It "thows specific exception for identity issue" {
            { Export-GPPermission @paramargs -ErrorAction Stop } | Should -Not -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException])
        }
    }

}
