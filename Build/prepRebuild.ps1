Function Start-PrepRebuild {
    [CmdletBinding()]
    Param(
        #Branch Selection
        [Parameter(
            Mandatory=$true
        )]
        [string]
        $branch,
        #Path Selection
        [Parameter(
            Mandatory=$false
        )]
        [string]
        $path = "$env:USERPROFILE\Desktop\Github"
    )
    try{
        New-Item -ItemType Directory -Path $path -ErrorAction Stop
    }
    Catch{
        If($_.Exception.ToString().Contains("An item with the specified name")){
            Write-Host "Folder Exists. Skipping!" -ForegroundColor DarkGreen
        }
        Else{
            $_ | fl * -force
            $_.InvocationInfo.BoundParameters | fl * -force
            $_.Exception
            break
        }

    }
    Set-Location $path

    #Start-Process "https://github.com/git-for-windows/git/releases/download/v2.18.0.windows.1/Git-2.18.0-64-bit.exe"
    #Read-Host "Holding for installation of git"
    #Get-Process -Name git -ErrorAction stop

    Try{
        git --version
    }
    Catch{
        "Git broke for some reason"
        $_ | fl * -force
        $_.InvocationInfo.BoundParameters | fl * -force
        $_.Exception
        break
    }

    Read-host "We good fam???"

    Start-Process "https://www.mozilla.org/en-US/firefox/download/thanks/"
    Read-Host "Holding for installation of FireFox"

    Write-Host $pwd.Path
    Read-Host "Ready to clone DevOps Repo?"
    #git clone --single-branch -b branch host:/dir.git
    Try{
        git clone --single-branch -b $branch "https://mwtilton@bitbucket.org/mwtilton/devops.git"
        #if ($LASTEXITCODE) { Throw "git clone failure (exit code $LASTEXITCODE" }
    }
    Catch{
        throw "git clone failed"
        break
    }


    Set-Location $path\DevOps

    . $path\DevOps\SetupGit\SetupGit.ps1
    Invoke-SetupGit
    git fetch --all
    Read-Host "Ready to set the branch information?"
    Try {
        git branch
        #git branch $branch
        git branch -u origin/$branch
        #git checkout $branch
        git pull
    }
    Catch{
        "couldn't properly setup the branch information"
        break
    }

    Start-Process powershell_ise -ArgumentList "$path\Devops\Build\prepDomainController.ps1" -verb RunAs
    Start-Process powershell_ise -ArgumentList "$path\Devops\Build\buildDomainController.ps1" -verb RunAs
}
