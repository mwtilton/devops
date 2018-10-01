<# Notes: This script must be run after prepDomainController.ps1. #>

configuration buildDomainController
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0
    Import-DscResource -ModuleName ComputerManagementDSC -ModuleVersion 5.2.0.0
    Import-DscResource -ModuleName NetworkingDSC -ModuleVersion 6.1.0.0
    Import-DscResource -ModuleName xActiveDirectory -ModuleVersion 2.21.0.0
    Import-DscResource -ModuleName xDnsServer -ModuleVersion 1.11.0.0

    Node $ConfigData.Allnodes.Nodename
    {
        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyOnly"
            DebugMode = "ForceModuleImport"
            RebootNodeIfNeeded = $true
        }

        IPAddress NewIPAddress {
            IPAddress = $node.IPAddressCIDR
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
        }

        DefaultGatewayAddress NewIPGateway {
            Address = $node.GatewayAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
            DependsOn = "[IPAddress]NewIPAddress"
        }

        DnsServerAddress PrimaryDNSClient {
            Address        = $node.DNSAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
            DependsOn = "[DefaultGatewayAddress]NewIPGateway"
        }

        User Administrator {
            Ensure = "Present"
            UserName = "Administrator"
            Password = $credentials
            DependsOn = "[DnsServerAddress]PrimaryDNSClient"
        }

        Computer $($node.ThisComputerName) {
            Name = $node.ThisComputerName
            DependsOn = "[User]Administrator"
        }

        WindowsFeature DNSInstall {
            Ensure = "Present"
            Name = "DNS"
            DependsOn = $("[Computer]" + $($node.ThisComputerName))
        }
        xDnsServerPrimaryZone $("addForwardZone" + $($node.DomainName).split(".")[0]) {
            Ensure = "Present"
            Name = $($node.DomainName)
            DynamicUpdate = "NonsecureAndSecure"
            DependsOn = "[WindowsFeature]DNSInstall"
        }

        xDnsServerPrimaryZone $("addReverse" + $($node.DomainName).split(".")[0]) {
            Ensure = "Present"
            Name = "3.168.192.in-addr.arpa"
            DynamicUpdate = "NonsecureAndSecure"
            DependsOn = "[WindowsFeature]DNSInstall"
        }

        WindowsFeature ADDSInstall {
            Ensure = "Present"
            Name = "AD-Domain-Services"
            DependsOn = $("[xDnsServerPrimaryZone]" + $("addForwardZone" + $($node.DomainName).split(".")[0]))
        }

        WindowsFeature ADDSTools {
             Ensure = "Present"
             Name = "RSAT-ADDS"
        }

        xADDomain FirstDC {
            DomainName = $node.DomainName
            DomainAdministratorCredential = $credentials
            SafemodeAdministratorPassword = $credentials
            DatabasePath = $node.DCDatabasePath
            LogPath = $node.DCLogPath
            SysvolPath = $node.SysvolPath
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADUser myaccount {
            DomainName = $node.DomainName
            Path = "CN=Users,$($node.DomainDN)"
            UserName = "myaccount"
            GivenName = "My"
            Surname = "Account"
            DisplayName = "My Account"
            Enabled = $true
            Password = $credentials
            DomainAdministratorCredential = $credentials
            PasswordNeverExpires = $true
            DependsOn = "[xADDomain]FirstDC"
        }

        xADGroup DomainAdmins {
            GroupName = "Domain Admins"
            Path = "CN=Users,$($node.DomainDN)"
            Category = "Security"
            GroupScope = "Global"
            MembersToInclude = "myaccount"
            DependsOn = "[xADDomain]FirstDC"
        }

        xADGroup EnterpriseAdmins {
            GroupName = "Enterprise Admins"
            Path = "CN=Users,$($node.DomainDN)"
            Category = "Security"
            GroupScope = "Universal"
            MembersToInclude = "myaccount"
            DependsOn = "[xADDomain]FirstDC"
        }

        xADGroup SchemaAdmins {
            GroupName = "Schema Admins"
            Path = "CN=Users,$($node.DomainDN)"
            Category = "Security"
            GroupScope = "Universal"
            MembersToInclude = "myaccount"
            DependsOn = "[xADDomain]FirstDC"
        }
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
            ThisComputerName = "DC01"
            IPAddressCIDR = "192.168.1.2/24"
            GatewayAddress = "192.168.1.1"
            DNSAddress = "127.0.0.1"
            InterfaceAlias = "Ethernet0"
            DomainName = "democloud.local"
            DomainDN = "DC=democloud,DC=local"
            DCDatabasePath = "C:\NTDS"
            DCLogPath = "C:\NTDS"
            SysvolPath = "C:\Sysvol"
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

$credentials = Get-Credential -UserName Administrator -Message "Please enter a new password for Local Administrator and other accounts."

$outputPath = "$env:USERPROFILE\Desktop\buildDomainController"
BuildDomainController -ConfigurationData $ConfigData -OutPutPath $outputPath

Set-DSCLocalConfigurationManager -Path $outputPath –Verbose
Start-DscConfiguration -Wait -Force -Path $outputPath -Verbose
