Get-Module DevOps | Remove-Module -Force
Import-Module $env:WORKINGFOLDER\DevOps\DevOps -Force -ErrorAction Stop
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Describe "Unit testing for DevOps" -Tags 'U1'{

    InModuleScope DevOps {

        Context "testing framework files" {

            It "DevOps folder exists" {
                "$($here)\DevOps" | Should be $true
            }
            It "Tests folder exists" {
                "$($here)\Tests" | Should be $true
            }
            It "has a readme file" {
                "$($here)\readme.md" | Should be $true
            }
            It "has an .gitignore file" {
                "$($here)\.gitignore" | Should be $true
            }
            It "has a start-pester file" {
                "$($here)\start-pester.ps1" | Should be $true
            }
            It "has a call DevOps file" {
                "$($here)\Call-DevOps.ps1" | Should be $true
            }
            It "has function folder" {
                "$($here)\Functions" | Should Exist
            }
        }
        Context "finds the functions" {
            $functionsFolder = $env:WORKINGFOLDER + "\DevOps\Functions"
            It "PS Script root is in Devops\" {
                $PSScriptRoot | Should Exist
            }
            It "can go to the functions folder" {
                $functionsFolder | Should Exist
            }
            It "should have the DevOps\Functions in the directory name" {
                $functionsFolder | Should BeLike "*\vsCode\DevOps\Functions*"
            }
            $functions = Get-ChildItem $functionsFolder -Filter "*.ps1"
            $functions | ForEach-Object {
                It "found $($_.name)" {
                    "$here\Functions\$($_.name)" | Should Exist
                }

            }

        }

    }

}


Describe "Unit testing for OpenStack" -Tags 'Unit'{

    InModuleScope OpenStack {

        Context "testing framework files" {

            It "OpenStack folder exists" {
                "$($here)\OpenStack" | Should be $true
            }
            It "Tests folder exists" {
                "$($here)\Tests" | Should be $true
            }
            It "has a readme file" {
                "$($here)\readme.md" | Should be $true
            }
            It "has an .gitignore file" {
                "$($here)\.gitignore" | Should be $true
            }
            It "has a start-pester file" {
                "$($here)\start-pester.ps1" | Should be $true
            }
            It "has a call OpenStack file" {
                "$($here)\start-pester.ps1" | Should be $true
            }
        }


        $values = "500","200","404","403"

        $values | ForEach-Object{
            $myitem = $_
            Context "Foreach-Object Restmethod returns $myitem code" {
                Mock Invoke-RestMethod {
                    $myitem
                }

                $result = Start-OpenStack -DestServer $OpenStackInfo.Compute

                It "returns $myitem" {
                    $($result) | Should Be $($myitem)
                }
                It "should be a string" {
                    $result.gettype() | Should beoftype System.Object
                }
                It "Should not be empty" {
                    $result | Should not be ""
                }
                It "$myitem should be a valid entry" {
                    $myitem | Should BeExactly $myitem
                }
                it "should be mocked 1 times" {
                    $assMParams = @{
                        CommandName = 'Invoke-Restmethod'
                        Times = 1
                        Exactly = $true
                    }
                    Assert-MockCalled @assMParams
                }
                It "should not throw an exception" {
                    {$result }| Should not throw
                }
            } #End Context
        } # End Foreach
        Context "Machine File seccuessfully imported" {
            It "Contains a hashtable" {
                $OpenStackinfo | Should beoftype [Hashtable]

            }
            It "has values" {
                $OpenStackinfo.Values | Should not be $null
            }
            It "has keys" {
                $OpenStackinfo.Keys | Should not be $null
            }
            $OpenStackinfo | ForEach-Object {
                It "has some keys" {

                    $_.Keys | Should not be $null
                }
                It "has some values" {

                    $_.Values | Should not be $null
                }
                It "the values should have an HTTP address in it" {
                    $_.Values | Should BeLike "*http*://*"
                }

            }
        }#End Context
        Context "Hitting the API" {
            $OpenStackinfo | ForEach-Object {

            }



        }
    } #End Inmodule scope

} #End Describe

Describe "Unit testing FilesFolders Module" -Tags "UNIT" {

    InModuleScope FilesFolders {

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

}


Describe "DCImport Unit Tests" -Tags "UNIT" {
    $testPath = "$testdrive\testfile.psm1","$testdrive\testfile.psm1"
    $testPath | ForEach-Object {
        Set-Content $testPath -value "my test text."
    }
    InModuleScope ADFill {

        Context "Mocking getting the Organizational Units" {
            Mock Get-ADOrganizationalUnit {return $true} -ParameterFilter {$filter -eq "Name -like 'OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL'"}
            It "should not be null" {
                {Get-ADOrganizationalUnit -Filter }| Should not be $null
            }
            It "should not be empty" {
                {Get-ADOrganizationalUnit -Filter}| Should not be ""
            }
            It "should not throw with wildcard" {
                {Get-ADOrganizationalUnit -Filter *}| Should not throw
            }
            It "should not throw with OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL" {
                {Get-ADOrganizationalUnit -Filter "Name -like 'OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL'"} | Should not throw
            }
        }
        Context "Throwing unit tests" {
            Mock Mock Get-ADOrganizationalUnit {return $null} -ParameterFilter {$filter -eq "Name -like 'OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL'"}
            It "will throw" {
                $getOU = Get-ADOrganizationalUnit -Filter "Name -like 'OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL'"
                ($getOU -eq "OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL") | Should Be $true
            }
        }
        Context "Moving Modules Unit testing" {
            $testPath = "$testdrive\testfile.psm1","$testdrive\testfile.psm1"
            $testPath | ForEach-Object {
                Mock Get-ChildItem {return @{FullName = $_.FullName}}
                Mock ForEach-Object -MockWith {}
                Mock Get-Content {return "my test text."} -ParameterFilter {$path -eq $_.FullName}
                Mock Out-File {return $true} -ParameterFilter { $path -eq $_.FullName -and $destination -eq "$testdrive\Module\testfile.psm1"}
            }

            $result = Move-Modules -path $testdrive

            It "Calls the gci 1 time" {
                $Params = @{
                    CommandName = 'Get-ChildItem'
                    Times = 1
                    Exactly = $true
                }
                Assert-MockCalled @Params
            }
            It "Files should be psm or psd files" {
                $result | ForEach-Object{
                    $result.FullName | Should belike "*.ps*1"
                }
            }
            It "file should exist" {
                $result | ForEach-Object {
                    $_.Name | Should not be $null
                    $_.FullName | Should Exist
                }
            }
            It "has the program module folder" {
                ($env:PSModulePath).Split(";")[1] | Should belike "c:\Program*"
            }
            It "returns something" {
                $result | Should -not -BeNullOrEmpty
            }
            It "calls get-content" {
                $Params = @{
                    CommandName = 'Get-Content'
                    Times = 2
                    Exactly = $true
                }
                Assert-MockCalled @Params
            }
            It "calls out-file" {
                $Params = @{
                    CommandName = 'Out-File'
                    Times = 2
                    Exactly = $true
                }
                Assert-MockCalled @Params
            }

        }

    }

}
