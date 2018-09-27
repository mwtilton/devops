Configuration ConfigureRebootOnNode
{
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $NodeName
    )

    Node $NodeName
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }
    }
}

Write-Host "Creating mofs"
ConfigureRebootOnNode -NodeName fabfiberserver -OutputPath .\rebootMofs

Write-Host "Starting CimSession"
$pass = ConvertTo-SecureString "P2ssw0rd" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("administrator", $pass)
$cim = New-CimSession -ComputerName fabfiberserver -Credential $cred

Write-Host "Writing config"
Set-DscLocalConfigurationManager -CimSession $cim -Path .\rebootMofs -Verbose

# read the config settings back to confirm
Get-DscLocalConfigurationManager -CimSession $cim
