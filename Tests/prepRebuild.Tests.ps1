Import-Module "$env:WORKINGFOLDER\DevOps\Build\prepRebuild.ps1" -Force -ErrorAction Stop
Describe "prepGit" -Tags "GIT" {
    Context "Folder Location Prep" {
        Mock New-Item {return "$env:USERPROFILE\Documents\Github"}
        Mock Set-Location {return "$env:USERPROFILE\Documents\Github"}
        Mock Read-Host {return $true}
        Mock Start-Process { return $true}
        Mock Get-Process {}

        Mock Invoke-Command { return $true } -ParameterFilter { $Command -like "*git*"}

        Start-PrepRebuild

        It "has location is set to github location" {
            $pwd.Path | Should Be "$env:USERPROFILE\Documents\Github"
        }
        It "has the github folder" {
            "$env:USERPROFILE\Documents\Github" | Should Exist
        }

    }
    Context "Git" {
        Mock Invoke-Command { return "/fake-path" } -ParameterFilter { $Command -eq "git status"}
        It "can run git" {
            {git status} | Should Not throw
        }
        It "Clones the DevOps Repo" {
            "$env:USERPROFILE\Documents\Github\DevOps" | Should Exist
        }
    }
}

#set-location $env:WORKINGFOLDER\devops
