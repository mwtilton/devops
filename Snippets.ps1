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

Get-Command
Get-Help
Get-Member