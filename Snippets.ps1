#Fatal Error Handling
Try{
    If($_.Exception.ToString().Contains("something")){
        Write-Host " already exists. Skipping!" -ForegroundColor DarkGreen
    }
    Else{

        Write-host $_.Exception -ForegroundColor Yellow
    }
}
Catch{
    $_ | fl * -force
    $_.InvocationInfo.BoundParameters | fl * -force
    $_.Exception
}

#one line error thrower
if ($?) {throw}

#runAs Admin stuffs
#R equires -RunAsAdministrator

#DSC
Get-DscResource * | Select -ExpandProperty Properties | ft -AutoSize
Get-DscResource * -Syntax


#Igonore SSL
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy


<#

    https://techcommunity.microsoft.com/t5/ITOps-Talk-Blog/PowerShell-Basics-Finding-Your-Way-in-the-PowerShell-Console/ba-p/300935
    PowerShell Basics: Finding Your Way in the PowerShell Console

#>

#Get-Command
get-command -CommandType Function
get-command -CommandType Function -name Get-*

#Firewall
get-command -name *firewall*
get-command -name *netfirewallrule

#Get-Help
get-help set-netfirewallrule
get-help set-netfirewallrule -examples
help Set-NetFirewallRule -Full
Help set-netfirewallrule -Parameter RemoteAddress

#Get-Member
get-service | Get-Member
(Get-Service | Get-Member | Where-Object -Property Membertype -EQ Property).count
Get-Service | Get-Member | Where-Object -Property Membertype -EQ Property
get-service | format-table -Property Name,Status,ServicesDependedOn

Get-Variable

#Prompt Information
(Get-Command prompt).definition
(Get-Command Prompt).ScriptBlock

#RawUI settings
$(Get-Host).UI.RawUI

#Check if you are in a nested powershell session
$NestedPromptLevel

#get running history of commands used
Get-History

#Making a new profile
if (!(Test-Path -Path $profile)) {New-Item -ItemType File -Path $profile -Force}

#profile information
$PROFILE | select *

#Git
git checkout --track origin/<branch_name>

# Connection to mysql database from dataset
import dataset
from CreatePointsDatabase import create_points_database

db = dataset.connect('mssql+pymssql://mssql+pymssql://user:password@server:port/database')


# Sending Email
#Enter in Log ID information
$id = ''

#Enter in Log Name. You can use the Asterisk(*) symbol for wildcards
$Logname = "Application"
$event = Get-EventLog -LogName $Logname -InstanceId $id -Newest 1

#Check Event log for error
if ($event.EntryType -eq "Error")
{
    #region Variables and Arguments
    $date = Get-Date -Format MM/dd/yy
    $users = "Josh@Justic.net" # List of users to email your report to (separate by comma)
    $fromemail = "USERNAME@gmail.com"
    $SMTPServer = "smtp.gmail.com"
    $SMTPPort = "587"
    $SMTPUser = "USERNAME@gmail.com"
    $SMTPPassword = "PASSWORD"
    $ComputerName = gc env:computername
    $EmailSubject = "COMPUTERNAME - New Event Log [Application] $date"
    $MailSubject = $MailSubject -replace('COMPUTERNAME', $ComputerName)
    $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SMTPUser, $($SMTPPassword | ConvertTo-SecureString -AsPlainText -Force) 
    $EnableSSL = $true
    $ListOfAttachments = @()
    $Report = @()
    $CurrentTime = Get-Date
    $PCName = $env:COMPUTERNAME
    $EmailBody = $event | ConvertToHtml > elog.htm
    $getHTML = Get-Content "elog.htm"
    #sending email
    send-mailmessage -from $fromemail -to $users -subject $EmailSubject -BodyAsHTML -body $getHTML -priority Normal -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $Credentials
    Remove-Item elog.htm
}
else
{
    write-host "No error found"
    write-host "Here is the log entry that was inspected: $event"
}

# Moving from one repo to another
1. Check out the existing repository from Bitbucket:
$ git clone https://USER@bitbucket.org/USER/PROJECT.git

2. Add the new Github repository as upstream remote of the repository checked out from Bitbucket:

$ cd PROJECT
$ git remote add upstream https://github.com:USER/PROJECT.git

3. Checkout and track any extra branches you want to push to the new repo
$ git checkout --track origin/dev

4. Push all branches (below: just master) and tags to the Github repository:

$ git push upstream master
$ git push --tags upstream

# PS ModulePath
Import-Module '$($env:PSModulePath).Split(;)[1]\UCSD' -Force -ErrorAction Stop;

