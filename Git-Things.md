# Useful Git CLI commands  

### git mv tests Tests  
fatal: source directory is empty, source=tests, destination=tmp  
Checking rename of 'tests' to 'tmp'  
#### git ls-files  
Tests/DevOps.Tests.ps1  
#### tree . /a /f  
\---tests  
        DevOps.Tests.ps1  
### Solution is to just rename the folder as git is already tracking it as Tests  

## git mv
#### This moves things within git. Doesn't necessarily keep commits  
### git mv tests tmp  
### git mv tests Tests  

## git commit  
### git commit -a -m "the message"  

## git push  
### git push origin --tag  

## git log  
### git log â€” all â€” grep=â€™commit messageâ€™  

## git config  
### git config --get remote.origin.fetch  
### ``git config --global alias.prum "pull --rebase upstream master"``  
### ``git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"``  
## git status  
### git status --ignored  

## Forget PW  
#### git config --unset-all credential.helper  
#### git config --global --unset-all credential.helper  

## git fetch  
###git fetch origin <remote branch>  

## git branch  
### git branch -a  
#### shows all branches, local and remote  
