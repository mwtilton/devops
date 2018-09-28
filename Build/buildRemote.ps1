<#
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
#>

<#
<# Notes:
Goal - Configure minimal post-installation settings for a server.
This script must be run after prepServer.ps1
Disclaimer - This example code is provided without copyright and AS IS.  It is free for you to use and modify.

<#
Specify the configuration to be applied to the server.  This section
defines which configurations you're interested in managing.


configuration buildAPPServer
{
    Import-DscResource -ModuleName xComputerManagement -ModuleVersion 4.1.0.0
    Import-DscResource -ModuleName xNetworking -ModuleVersion 5.4.0.0
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0

    Node $ConfigData.AllNodes.NodeName
    {

        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyOnly"
            DebugMode = "ForceModuleImport"
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
            Password = $credentials
            DependsOn = "[xDnsServerAddress]PrimaryDNSClient"
        }

        xComputer ChangeNameAndJoinDomain {
            Name = $node.ThisComputerName
            DomainName    = $node.DomainName
            Credential    = $domaincredentials
            DependsOn = "[User]Administrator"
        }
    }
}
<#
Specify values for the configurations you're interested in managing.
See in the configuration above how variables are used to reference values listed here.

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = ""
            ThisComputerName = "APP03"
            InterfaceAlias = "Ethernet0"
            IPAddressCIDR = "192.168.1.7/24"
            GatewayAddress = "192.168.1.1"
            DNSAddress = "192.168.1.6"
Â Â Â Â Â Â Â Â Â Â Â Â DomainName = "democloud.local"
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
<#
#$outputPath = "\\$($ConfigData.AllNodes.Nodename)\c$\users\administrator\Desktop\buildFileServer\"
$outputPath = "$env:USERPROFILE\Desktop\buildAPPServer"

buildAPPServer -ConfigurationData $ConfigData -OutputPath $outputPath

$Domain = $(($env:USERDNSDOMAIN).Split(".")[0])
[PScredential]$domaincredentials = Get-Credential -UserName $Domain\$env:USERNAME -Message "Please enter your Domain credentials"
[PScredential]$credentials = Get-Credential -UserName $env:USERNAME -Message "Please enter your Local Admin credentials"

$Session = New-CimSession -ComputerName $ConfigData.AllNodes.Nodename -Credential $domaincredentials

Set-DSCLocalConfigurationManager -CimSession $Session -Path $outputPath -Verbose
Start-DscConfiguration -CimSession $Session -Path $outputPath -Wait -Verbose -Force
#>

#Simple DSC Configuration
Configuration RenameComputer {
    param(
        [string]$NodeName,
        [string]$NewName
    )

    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 5.2.0.0

    Node $NodeName {

        Computer RenameComputer
        {
            Name = $NewName
        }
    } #end node block

} #end configuration

RenameComputer -NodeName 'WIN-99CCLDAKOU2' -NewName 'APP03' -OutputPath c:\dsc\push

$credentials = Get-Credential -UserName administrator -Message "Local Admin"
$cim = New-CimSession -ComputerName 'WIN-99CCLDAKOU2' -Credential $credentials

Start-DscConfiguration -cimsession $cim -Path C:\dsc\push -Wait -Verbose -Force

#Copying DSC resource module to remote node
$Session = New-PSSession -ComputerName 'WIN-99CCLDAKOU2' -Credential $credentials

$Params =@{
    Path = 'C:\Program Files\WindowsPowerShell\Modules\ComputerManagementDsc'
    Destination = 'C:\Program Files\WindowsPowerShell\Modules'
    ToSession = $Session
}

Copy-Item @Params -Recurse

Invoke-Command -Session $Session -ScriptBlock {Get-Module ComputerManagementDsc -ListAvailable}
