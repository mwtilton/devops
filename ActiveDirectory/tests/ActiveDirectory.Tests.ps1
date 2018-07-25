Import-Module $env:WORKINGFOLDER\Devops\ActiveDirectory\ActiveDirectory -Force -ErrorAction Stop

Describe "Start-DCImport" -Tags "UNIT" {
    InModuleScope "ActiveDirectory" {

        Context "Test-Path" {
            It "should find the folder" {
                $path = $env:WORKINGFOLDER
                Test-Path -Path $path | Should Be $true
            }
            It "should return an error" {
                {Start-DCImport -ErrorAction Stop } | Should throw
            }
            It "should return false" {
                $falsepath = "d:\"
                Start-DCImport -Path $falsepath | Should Be $false
            }

        }
        Context "Open the file" {
            Mock -MockWith Start-DCImport {"hello"}
            It "not able to open the file" {
                $result = Start-DCImport -Path "c:\"
                $result | Should Be $false
            }
        }


    }

}
