Import-Module $env:WORKINGFOLDER\Devops\FilesFolders\FilesFolders -Force -ErrorAction Stop

InModuleScope "FilesFolders" {
    Describe "Start-FilesFolders" {
        Context "Error Handling" {

            Mock IsAdmin -MockWith {$false}
            It "should throw an exception" {
                { New-Item -Path $env:WORKINGFOLDER\Devops\FilesFolders\FilesFolders -ItemType Directory -ErrorAction Stop} | Should Throw
            }
            It "should fail"{
                {Get-GPOreport -ErrorAction Stop} | Should Throw
            }
            
        }
               
        
    }
    
}
