Get-Module DevOps | Remove-Module -Force
Import-Module $env:WORKINGFOLDER\DevOps\DevOps -Force -ErrorAction Stop
Import-Module $env:WORKINGFOLDER\DevOps\Call-DevOps.ps1 -Force -ErrorAction Stop

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Describe "Unit testing for DevOps Module" -Tags 'UNIT'{

    InModuleScope DevOps {

        Context "finds the functions" {
            $functionsFolder = $env:WORKINGFOLDER + "\DevOps\DevOps\Functions"
            It "PS Script root exists" {
                $PSScriptRoot | Should Exist
            }
            It "can go to the functions folder" {
                $functionsFolder | Should Exist
            }
            It "should have the DevOps\Functions in the directory name" {
                $functionsFolder | Should BeLike "*\DevOps\Functions*"
            }
        }
        Context "finds the functions" {
            $functionsFolder = $env:WORKINGFOLDER + "\DevOps\DevOps\Functions"
            $functions = Get-ChildItem $functionsFolder -Filter "*.ps1"
            $functions | ForEach-Object {
                It "found $($_.name)" {
                    "$here\Functions\$($_.name)" | Should Be $true
                }

            }

        }
        Context "finds the functions" {
            $functionsFolder = $env:WORKINGFOLDER + "\DevOps\DevOps\Functions"
            $functions = Get-ChildItem $functionsFolder -Filter "*.ps1"
            $functions | ForEach-Object {
                Context "importing $($_.name)" {
                    It "found $($_.name)" {
                        "$here\Functions\$($_.name)" | Should Be $true
                    }
                    It "should exist" {
                        $_.FullName | Should Exist
                    }
                    It "should have a function in it" {
                        $_.FullName | Should -FileContentMatchMultiline "Function"
                    }
                    It "should have some params" {
                        $_.FullName | Should -FileContentMatchMultiline "Param"
                    }
                    It "should have cmdletbinding" {
                        $_.FullName | Should -FileContentMatchMultiline "cmdletbinding"
                    }
                    It "dot sourcing does not throw when importing it" {
                        {. $_.FullName} | Should Not throw
                    }
                }


            }

        }
    }
}


Describe "Unit Testing for Call file" -Tags 'CALL'{
    Context "testing framework files" {

        It "DevOps folder exists" {
            "$($here)\DevOps" | Should be $true
        }
        It "DevOps Machine file exists" {
            "$($here)\DevOps\DevOps.Machine.ps1" | Should be $true
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
            "$($here)\Functions" | Should be $true
        }
    }
    Context "Testing if call file exists" {
        It "does return true, whatever that means" {
            "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should be $true
        }
        It "does exist apparently" {
            "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should Exist
        }
        It "not going to work without the env: Working folder" {
            {. "$($here)\Call-DevOps.ps1" } | Should throw
        }
    }
    Context "Testing folder locations" {
        It "imports the DevOps module" {
            "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape("Import-Module `"`$env:USERPROFILE\Desktop\DevOps\DevOps`" -Force"))
        }
        It "has the working folder set to Desktop\Workingfolder" {
            "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape("`$env:USERPROFILE\Desktop\WorkingFolder"))
        }
        It "does not contain any special env:" {
            "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape("`$env:WORKINGFOLDER"))
        }
    }
    Context "Start Something" {
        $start = "Start-DCImport","Start-DCExport","Start-GPOExport","Start-DCImport","Start-OpenStack"
        $start | ForEach-Object {
            It "has the $_ wrapper" {
                "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape($($_)))
            }
        }

    }
    Context "Import Machine Files" {


        It "has values" {
            $DevOpsInfo.Values | Should not be $null
        }
        It "has keys" {
            $DevOpsInfo.Keys | Should not be $null
        }
        $DevOpsInfo | ForEach-Object {
            It "has some keys" {

                $_.Keys | Should not be $null
            }
            It "has some values" {

                $_.Values | Should not be $null
            }

        }
    }#End Machine File Context

}


        <#
        Describe "Unit testing for OpenStack" {




        } #End Describe
        Describe "Unit testing FilesFolders Module" {

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
        Describe "DCImport Unit Tests"{
            $testPath = "$testdrive\testfile.psm1","$testdrive\testfile.psm1"
            $testPath | ForEach-Object {
                Set-Content $testPath -value "my test text."
            }

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
    }# End Unit Testing InModule Scope

} # End Unit Testing Describe
#>
