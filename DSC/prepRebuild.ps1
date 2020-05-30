Function Start-PrepRebuildInstallation {
    [CmdletBinding()]
    Param(
        #Path Selection
        [Parameter(
            Mandatory=$false
        )]
        [string]
        $path = "$env:USERPROFILE\Desktop"
    )

    Get-Service "Windows Search" | Set-service -StartupType Automatic | Start-Service

    Start-Process "https://nmap.org/download.html"
    Sleep 1
    Start-Process "https://git-scm.com/downloads"
    Sleep 1
    Start-Process "https://www.mozilla.org/en-US/firefox/download/thanks/"

    Read-Host "Holding for installation completion"
    #Get-Process -Name git -ErrorAction stop
    Restart-Computer -Force -Confirm
}
Function Start-PrepReBuild{
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
        $path = "$env:USERPROFILE\Desktop"
    )

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
    Write-Host $pwd.Path

    Read-Host "Ready to clone DevOps Repo?"
    #git clone --single-branch -b branch host:/dir.git
    Try{
        git clone --single-branch -b $branch $repo
        #if ($LASTEXITCODE) { Throw "git clone failure (exit code $LASTEXITCODE" }
    }
    Catch{
        throw "git clone failed"
        break
    }


    Set-Location $path\DevOps

    . $path\DevOps\SetupGit\SetupGit.ps1
    Invoke-SetupGit

    #git fetch --all
    <#
    Read-Host "Ready to set the branch information?"
    Try {
        git branch -a
        #git branch $branch
        git branch $branch
        git checkout $branch
        git branch -u origin/$branch
        Read-Host "Bout to pull is that right?"
        #git checkout $branch
        git pull --all
    }
    Catch{
        "couldn't properly setup the branch information"
        break
    }
    #>
    Start-Process powershell_ise -ArgumentList "$path\Devops\Build\prepDomainController.ps1" -verb RunAs
    Start-Process powershell_ise -ArgumentList "$path\Devops\Build\buildDomainController.ps1" -verb RunAs
}
