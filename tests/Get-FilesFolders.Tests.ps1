Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-FilesFolders.ps1" -Force -ErrorAction Stop

Describe "Get-FilesFolders" {
    Context "finds files" {
        $gff = Get-FilesFolders
        It "GCI on the c:\" {
            {gci "c:\"}| Should Not throw

        }
        It "GFF function should not throw" {
            {$gff} | Should Not throw
        }

    }
    Context "Finds the fileshares" {
        Mock Get-FileShare -MockWith {}
        It "returns shares" {
            Should not be $null
        }
    }
    Context "Get-Acl Unit Tests" {
        Mock Get-Acl -MockWith {"c:\"}
        $acl = Get-Acl
        It "gets the acl and does not throw" {
            {$acl} | Should Not throw
        }
        It "has a path" {
            $acl.path | Should BeLike "*c:\*"
        }
        It "should not return null or empty" {
            $acl | Should -not -BeNullOrEmpty
        }

    }
    Context "Creates New Shares" {
        It "New path exists" {

        }
    }
}
