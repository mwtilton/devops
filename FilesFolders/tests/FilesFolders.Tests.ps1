Get-Module FilesFolders | Remove-Module -Force
Import-Module $env:WORKINGFOLDER\Devops\FilesFolders\FilesFolders -Force -ErrorAction Stop

InModuleScope "FilesFolders" {
    Describe "Test-FileLock" {
        Context "Test-Path" {

            It "should find the folder" {
                $path = $env:WORKINGFOLDER
                Test-FileLock -Path $path | Should Be $true
            }
            It "should return an error" {
                {Test-FileLock -ErrorAction Stop } | Should throw
            }
            It "should return false" {
                $falsepath = "d:\"
                Test-FileLock -Path $falsepath | Should Be $false
            }

        }
        Context "Open the file" {
            Mock -MockWith Test-FileLock {return $false}
            It "not able to open the file" {
                $result = Test-FileLock -Path "c:\"
                $result | Should Be $false
            }
        }


    }

}
