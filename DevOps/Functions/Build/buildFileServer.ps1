<# Notes:
Goal - Configure minimal post-installation settings for a server.
This script must be run after prepServer.ps1
Disclaimer - This example code is provided without copyright and AS IS.  It is free for you to use and modify.
#>

<#
Specify the configuration to be applied to the server.  This section
defines which configurations you're interested in managing.
#>

configuration buildFileServer
{
    Import-DscResource -ModuleName xComputerManagement -ModuleVersion 3.2.0.0
    Import-DscResource -ModuleName xNetworking -ModuleVersion 5.4.0.0
    Import-DscResource -Name MSFT_xSmbShare -ModuleVersion 2.1.0.0
    Import-DSCResource -ModuleName StorageDsc -ModuleVersion 1.7.0.0

    Node localhost
    {

        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyOnly"
            RebootNodeIfNeeded = $true
        }

        xIPAddress NewIPAddress {
            IPAddress = $node.IPAddressCIDR
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
        }

        xDefaultGatewayAddress NewIPGateway {
            Address = $node.GatewayAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
            DependsOn = "[xIPAddress]NewIPAddress"
        }

        xDnsServerAddress PrimaryDNSClient {
            Address        = $node.DNSAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
            DependsOn = "[xDefaultGatewayAddress]NewIPGateway"
        }

        User Administrator {
            Ensure = "Present"
            UserName = "Administrator"
            Password = $Cred
            DependsOn = "[xDnsServerAddress]PrimaryDNSClient"
        }

        xComputer ChangeNameAndJoinDomain {
            Name = $node.ThisComputerName
            DomainName    = $node.DomainName
            Credential    = $domainCred
            DependsOn = "[User]Administrator"
        }
        xSmbShare MainDriveShare
        {
            Ensure = "Present"
            Name   = "E$"
            Path = "E:\"
            FullAccess = "Domain Admin"
            Description = "This is the main drive share"
        }
        xSmbShare DataShare
        {
            Ensure = "Present"
            Name   = "Data$"
            Path = "E:\CompanyData\Data"
            FullAccess = "Domain Admin"
            Description = "This is the main Data share"
        }
        xSmbShare ExecShare
        {
            Ensure = "Present"
            Name   = "Executive$"
            Path = "E:\Company Data\Executive"
            FullAccess = "Domain Admin"
            Description = "This is the main Executive Share"
        }
        xSmbShare HRShare
        {
            Ensure = "Present"
            Name   = "HR$"
            Path = "E:\Company Data\HR"
            FullAccess = "Domain Admin"
            Description = "This is the main HR Share"
        }
        xSmbShare MarketingShare
        {
            Ensure = "Present"
            Name   = "Marketing$"
            Path = "E:\Company Data\Marketing"
            FullAccess = "Domain Admin"
            Description = "This is the main Marketing Share"
        }
        xSmbShare OneDriveShare
        {
            Ensure = "Present"
            Name   = "OneDrive$"
            Path = "E:\Company Data\OneDrive"
            FullAccess = "Domain Admin"
            Description = "This is the main OneDrive Share"
        }
        xSmbShare PrivateShare
        {
            Ensure = "Present"
            Name   = "Private$"
            Path = "E:\Company Data\Private"
            FullAccess = "Domain Admin"
            Description = "This is the main Private Share"
        }
        xSmbShare QBTestShare
        {
            Ensure = "Present"
            Name   = "QBTest$"
            Path = "E:\QBTest"
            FullAccess = "Domain Admin"
            Description = "This is the main QBTest Share"
        }
        xSmbShare UserFilesShare
        {
            Ensure = "Present"
            Name   = "UserFiles$"
            Path = "E:\Company Data\UserFiles"
            FullAccess = "Domain Admin"
            Description = "This is the main UserFiles Share"
        }
        xSmbShare UsersShare
        {
            Ensure = "Present"
            Name   = "Users$"
            Path = "E:\Users"
            FullAccess = "Domain Admin"
            Description = "This is the main Users Share"
        }
        <#
        WaitForDisk Disk0
        {
             DiskId = 0
             RetryIntervalSec = 10
             RetryCount = 10
        }

        Disk CVolume
        {
             DiskId = 0
             DriveLetter = 'C'
             Size = 32GB
        }

        Disk EVolume
        {
             DiskId = 0
             DriveLetter = 'E'
             FSLabel = 'Data'
             #DependsOn = '[Disk]CVolume'
        }
        #>
    }
}

<#
Specify values for the configurations you're interested in managing.
See in the configuration above how variables are used to reference values listed here.
#>
$ConfigData = @{
    AllNodes = @(
        @{
            Nodename = "localhost"
            ThisComputerName = "servercore2"
            InterfaceAlias = "Ethernet0"
            IPAddressCIDR = "192.168.3.102/24"
            GatewayAddress = "192.168.3.2"
            DNSAddress = "192.168.3.10"
            DomainName = "company.pri"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        }
    )
}
<#
Lastly, prompt for the necessary username and password combinations, then
compile the configuration, and then instruct the server to execute that
configuration against the settings on this local server.
#>

$domainCred = Get-Credential -UserName company\Administrator -Message "Please enter a new password for Domain Administrator."
$Cred = Get-Credential -UserName Administrator -Message "Please enter a new password for Local Administrator and other accounts."

buildFileServer -ConfigurationData $ConfigData

Set-DSCLocalConfigurationManager -Path .\buildFileServer –Verbose
Start-DscConfiguration -Wait -Force -Path .\buildFileServer -Verbose
