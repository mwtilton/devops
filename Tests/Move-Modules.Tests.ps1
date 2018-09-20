Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Move-Modules.ps1" -Force -ErrorAction Stop
Describe "Move-Modules" {
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
