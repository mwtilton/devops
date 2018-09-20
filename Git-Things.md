#Useful Git CLI commands  

###git mv tests Tests  
fatal: source directory is empty, source=tests, destination=tmp  
Checking rename of 'tests' to 'tmp'  
####git ls-files  
Tests/DevOps.Tests.ps1  
####tree . /a /f  
\---tests  
        DevOps.Tests.ps1  
###Solution is to just rename the folder as git is already tracking it as Tests  

###git mv tests tmp  
###git mv tests Tests  
###git commit -a -m "the message"  
###git push  

###git push origin --tag  

####git log — all — grep=’commit message’
####git config --global alias.prum "pull --rebase upstream master"
####git status --ignored

##Forget PW
####git config --unset-all credential.helper
####git config --global --unset-all credential.helper
