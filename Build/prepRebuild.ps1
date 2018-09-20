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
        "Something happened with $_.exception"
        break
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
    }
    Catch{
        "Error cloning the repo from $branch"
        $_ | fl * -force
        $_.InvocationInfo.BoundParameters | fl * -force
        $_.Exception
        break
    }

    Set-Location $path\DevOps

    . $path\DevOps\SetupGit\SetupGit.ps1
    Invoke-SetupGit
    git fetch --all
    Read-Host "Ready to set the branch information?"
    Try {
        git branch
        git branch $branch
        git branch -u origin/$branch
        git checkout $branch
        git pull
    }
    Catch{
        "couldn't properly setup the branch information"
        break
    }

    Start-Process powershell_ise -ArgumentList "$path\Devops\Build\prepDomainController.ps1" -verb RunAs
}
