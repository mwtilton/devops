Get-Module FilesFolders | Remove-Module -Force
Import-Module $env:WORKINGFOLDER\Devops\FilesFolders\FilesFolders -Force -ErrorAction Stop
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


    }

}
