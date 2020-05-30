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
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0

    Import-DscResource -ModuleName xSmbShare -ModuleVersion 2.1.0.0
    Import-DSCResource -ModuleName StorageDsc -ModuleVersion 4.1.0.0
    Import-DscResource -ModuleName cNtfsAccessControl -ModuleVersion 1.3.1
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0

    Node $ConfigData.AllNodes.NodeName {
        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyOnly"
            DebugMode = "ForceModuleImport"
            RebootNodeIfNeeded = $true
        }
        ForEach ($config in $Node.configs) {
            xIPAddress NewIPAddress {
                IPAddress = $config.IPAddressCIDR
                InterfaceAlias = $config.InterfaceAlias
                AddressFamily = "IPV4"
            }

            xDefaultGatewayAddress NewIPGateway {
                Address = $config.GatewayAddress
                InterfaceAlias = $config.InterfaceAlias
                AddressFamily = "IPV4"
                DependsOn = "[xIPAddress]NewIPAddress"
            }

            xDnsServerAddress PrimaryDNSClient {
                Address        = $config.DNSAddress
                InterfaceAlias = $config.InterfaceAlias
                AddressFamily = "IPV4"
                DependsOn = "[xDefaultGatewayAddress]NewIPGateway"
            }

            User Administrator {
                Ensure = "Present"
                UserName = "Administrator"
                Password = $domaincredentials
                DependsOn = "[xDnsServerAddress]PrimaryDNSClient"
            }

            xComputer ChangeNameAndJoinDomain {
                Name = $config.ThisComputerName
                DomainName    = $config.DomainName
                Credential    = $domaincredentials
                DependsOn = "[User]Administrator"
            }


        }
    }

    Node $ConfigData.AllNodes.NodeName.IndexOf(0)
    {


        ForEach ($Folder in $Node.FolderStructure) {

            # Each of our 'file' resources will be named after the path, but...
            #   we have to replace : with __ as colons aren't allowed in resource names
            File $Folder.Path.Replace(':','__') {
              DestinationPath = $Folder.Path
              Ensure = $Folder.Ensure
              Type = $folder.Type

            }
            cNtfsPermissionEntry $Folder.Path.Replace(':','__') {
                Ensure = $Folder.Ensure
                Path = $Folder.Path
                Principal = $Folder.Principal
                AccessControlInformation = @(
                    cNtfsAccessControlInformation
                    {
                        AccessControlType = $AccessControlInformation.AccessControlType
                        FileSystemRights = $AccessControlInformation.FileSystemRights
                        Inheritance = $AccessControlInformation.Inheritance
                        NoPropagateInherit = $AccessControlInformation.NoPropagateInherit
                    }
                )
                DependsOn = @("[File]" + "$($Folder.Path.Replace(':','__'))")
            }


            xSmbShare $(($Folder.path).Split("\")[-1])
            {
                Ensure = $Folder.Ensure
                Name   = ($Folder.path).Split("\")[-1] + "$"
                Path = $Folder.path
                FullAccess = "$Domain\Domain Admins"
                Description = "This is the $Domain main $(($Folder.path).Split("\")[-1]) Share"
            }

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

            Nodename = "FileServer01"

            FolderStructure = @(

                @{
                    Path =   "E:\Testing"
                    Ensure = "Present"
                    Type = "Directory"
                    Principal = "$Domain\Domain Admins"

                }
                @{
                    Path =   "E:\CompanyData"
                    Ensure = "Present"
                    Type = "Directory"
                    Principal = "$Domain\Domain Admins"
                    AccessControlInformation = @(

                        @{
                            AccessControlType = 'Allow'
                            FileSystemRights = 'FullControl'
                            Inheritance = 'ThisFolderSubfoldersAndFiles'
                            NoPropagateInherit = $true
                        }
                    )
                }


            )

            configs = @(

                @{
                    ThisComputerName = "FileServer01"
                    InterfaceAlias = "Ethernet0"
                    IPAddressCIDR = "192.168.1.7/24"
                    GatewayAddress = "192.168.1.1"
                    DNSAddress = "192.168.1.6"
                    DomainName = "democloud.local"
                    PSDscAllowPlainTextPassword = $true
                    PSDscAllowDomainUser = $true
                }


            )
        } #end node 0
        <#
        @{
            Nodename = ""

            configs = @(
                @{
                    ThisComputerName = "APP03"
                    InterfaceAlias = "Ethernet0"
                    IPAddressCIDR = "192.168.1.7/24"
                    GatewayAddress = "192.168.1.1"
                    DNSAddress = "192.168.1.6"
                    DomainName = "democloud.local"
                    PSDscAllowPlainTextPassword = $true
                    PSDscAllowDomainUser = $true
                }
            )
        }
        #>
    )
}
<#
Lastly, prompt for the necessary username and password combinations, then
compile the configuration, and then instruct the server to execute that
configuration against the settings on this local server.
#>

#$outputPath = "\\$($ConfigData.AllNodes.Nodename)\c$\users\administrator\Desktop\buildFileServer\"
$outputPath = "$env:USERPROFILE\Desktop\buildFileServer"

buildFileServer -ConfigurationData $ConfigData -OutputPath $outputPath

$Domain = $(($env:USERDNSDOMAIN).Split(".")[0])
$domaincredentials = Get-Credential -UserName "$Domain\$env:USERNAME" -Message "Please enter your Domain credentials"
$Session = New-CimSession -ComputerName $ConfigData.AllNodes.Nodename -Credential $domaincredentials

Set-DSCLocalConfigurationManager -CimSession $Session -Path $outputPath -Verbose
Start-DscConfiguration -CimSession $Session -Path $outputPath -Wait -Verbose -Force
