$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Invoke-SetupGit" {
    Context "Sets the user information"{
        Mock Invoke-SetupGit {}
        Mock Read-Host {} -MockWith {"JohnDoe"}

        It "sets the user" {
            git config --get-regexp user.name | Should BeLike "*mwtilton*"
        }
        It "sets the email" {
            git config --get-regexp user.email | Should BeLike "*sandamomivo@gmail.com*"
        }
    }
    Context "Creates the aliases" {
        $gitAliases = "last","psu","NUKE","stashes","s"
        $gitAliases | ForEach-Object{
            It "$_ alias has been set" {
                git config --get-regexp alias.$_ | Should BeLike "*alias.$_*"
            }
        }
        
    }
    Context "Sets up the editor" {
        It "has vscode as the default editor" {

        }
    }
    Context "Displays the new setup" {
        It "shows end results" {

        }
    }
}
