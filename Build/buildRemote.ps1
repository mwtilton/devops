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


<#
<# Notes:
Goal - Configure minimal post-installation settings for a server.
This script must be run after prepServer.ps1
Disclaimer - This example code is provided without copyright and AS IS.  It is free for you to use and modify.

<#
Specify the configuration to be applied to the server.  This section
defines which configurations you're interested in managing.


configuration buildFileServer
{
    Import-DscResource -ModuleName xSmbShare -ModuleVersion 2.1.0.0

    Node $ConfigData.AllNodes.NodeName
    {

        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyOnly"
            DebugMode = "ForceModuleImport"
            RebootNodeIfNeeded = $true
        }

        ForEach ($config in $Node.configs) {
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
                Credential    = $credentials
                DependsOn = "[User]Administrator"
            }


        }


    }
}
<#
Specify values for the configurations you're interested in managing.
See in the configuration above how variables are used to reference values listed here.

$ConfigData = @{
    AllNodes = @(
        @{

            Nodename = "FileServer01"

            configs = @(

                @{
                    Path =   "E:\Testing"
                    Ensure = "Present"
                }


            )
        }
        @{
            NodeName = "APP01"
            configs = @(

                @{
                    Path =   "E:\Testing"
                    Ensure = "Present"
                }


            )
        }
    )
}
<#
Lastly, prompt for the necessary username and password combinations, then
compile the configuration, and then instruct the server to execute that
configuration against the settings on this local server.


#$outputPath = "\\$($ConfigData.AllNodes.Nodename)\c$\users\administrator\Desktop\buildFileServer\"
$outputPath = "$env:USERPROFILE\Desktop\buildFileServer"

buildFileServer -ConfigurationData $ConfigData -OutputPath $outputPath

$Domain = $(($env:USERDNSDOMAIN).Split(".")[0])

$Session = New-CimSession -ComputerName $ConfigData.AllNodes.Nodename -Credential "$Domain\$env:USERNAME"

Set-DSCLocalConfigurationManager -CimSession $Session -Path $outputPath -Verbose
Start-DscConfiguration -CimSession $Session -Path $outputPath -Wait -Verbose -Force

#>
