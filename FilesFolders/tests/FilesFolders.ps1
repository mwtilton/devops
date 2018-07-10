function Start-FilesFolders {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_ -like "*.*"})]
        [String]
        $path
    )
    


    Begin{
        $getFilesFolders = Get-ChildItem $path -Recurse 
        $getFilesFolders | ForEach-Object {
            $_

        }
    }

}
