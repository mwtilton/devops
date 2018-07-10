$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Start-FilesFolders" {
    
    
    It "finds files" {
        
        $true | Should Be $false
    }
}

