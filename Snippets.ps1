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