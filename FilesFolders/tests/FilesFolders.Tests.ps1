Import-Module $env:WORKINGFOLDER\Devops\FilesFolders\FilesFolders -Force -Verbose

InModuleScope "FilesFolders" {
    Describe "Start-FilesFolders" {
        Context "Test files" {
            It "finds test files in current directory" {
                $expected = dir *.\test
                Start-FilesFolders | Should Be $expected            
            }
            It "test files are in the working folder" {
                $furtherexpectations = gci $env:WORKINGFOLDER -Filter *.ps1
                Start-FilesFolders | Should Be $furtherexpectations
            }
            It "finds a powershell file" {
                Mock Start-FilesFolders -MockWith {'gfgfds'}
                (Get-ChildItem).Extension | Should Be '.ps1'
            }
        }
        Context "Parent Directory" {
            It "tells me the current parent directory" {
                $here = "$env:WORKINGFOLDER\FilesFolders\Root"
                $here | Should Be $true
            }
        }
        
        
    }
    

}
