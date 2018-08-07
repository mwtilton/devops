$moduleFolder = "$env:WORKINGFOLDER\DevOps\ADFill"
Invoke-Pester -tags UNIT $moduleFolder -CodeCoverage $moduleFolder\ADFill\ADFill.psm1
