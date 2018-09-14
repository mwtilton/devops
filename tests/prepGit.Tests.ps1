Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\build\prepGit.ps1" -Force -ErrorAction Stop
Describe "prepGit" -Tags "GIT" {
    Context "Folder Location Prep" {
        Mock New-Item {return "$env:USERPROFILE\Documents\Github"}

        Start-PrepGit

        It "has location is set to github location" {
            Get-Location | Should Be "$env:USERPROFILE\Documents\Github"
        }
        It "has the github folder" {
            "$env:USERPROFILE\Documents\Github" | Should Exist
        }

    }
    Context "Git" {
        It "can run git" {
            {git status} | Should Not throw
        }
        It "Clones the DevOps Repo" {
            "$env:USERPROFILE\Documents\Github\DevOps" | Should Exist
        }
    }
}

set-location $env:WORKINGFOLDER\devops
