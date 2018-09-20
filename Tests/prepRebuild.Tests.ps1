Import-Module "$env:WORKINGFOLDER\DevOps\Build\prepRebuild.ps1" -Force -ErrorAction Stop
Describe "prepGit" -Tags "GIT" {
    Context "Folder Location Prep" {
        Mock New-Item {return "$env:USERPROFILE\Documents\Github"}
        Mock Set-Location {return "$env:USERPROFILE\Documents\Github"}
        Mock Read-Host {return $true}
        Mock Start-Process { return $true}
        Mock Get-Process {}

        Mock Invoke-Command { return "/fake-path" } -ParameterFilter { $Command -eq "git branch"}
        Mock Invoke-Command { return "/fake-path" } -ParameterFilter { $Command -eq "git branch build"}
        Mock Invoke-Command { return "/fake-path" } -ParameterFilter { $Command -eq "git branch -u origin/build"}
        Mock Invoke-Command { return "/fake-path" } -ParameterFilter { $Command -eq "git checkout build"}
        Mock Invoke-Command { return "/fake-path" } -ParameterFilter { $Command -eq "git pull"}

        Start-PrepRebuild

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
