#Discover & Download resources
<#
Find-Module -Name *computer*
Install-Module -Name ComputerManagementDsc -RequiredVersion 5.2.0.0
Get-DscResource -Module ComputerManagementDsc
Get-DscResource -Name Computer -Syntax
#>
<#
Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

Install-PackageProvider -Name NuGet -Force

Install-Module ComputerManagementDSC -RequiredVersion 5.2.0.0 -Force
Install-Module NetworkingDSC -RequiredVersion 6.1.0.0 -Force
Install-Module xPSDesiredStateConfiguration -RequiredVersion 8.4.0.0 -Force
#>

#Simple DSC Configuration
Configuration buildAPPServer {

    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 5.2.0.0
    Import-DscResource -ModuleName NetworkingDSC -ModuleVersion 6.1.0.0
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0

    Node $ConfigData.AllNodes.Nodename {
        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyOnly"
            RebootNodeIfNeeded = $true
        }
        Computer $("Rename-" + $ConfigData.AllNodes.Nodename)
        {
            Name = $node.ThisComputerName
            DomainName    = $node.DomainName
            Credential    = $domaincredentials
            DependsOn = $("[User]Administrator-" + $ConfigData.AllNodes.Nodename)
        }
        IPAddress $("NewIPAddress-" + $ConfigData.AllNodes.Nodename) {
            IPAddress = $node.IPAddressCIDR
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
        }
        DefaultGatewayAddress $("NewIPGateway-" + $ConfigData.AllNodes.Nodename) {
            Address = $node.GatewayAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
            DependsOn = $("[IPAddress]NewIPAddress-" + $ConfigData.AllNodes.Nodename)
        }

        DnsServerAddress $("PrimaryDNSClient-" + $ConfigData.AllNodes.Nodename) {
            Address        = $node.DNSAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
            DependsOn = $("[DefaultGatewayAddress]NewIPGateway-" + $ConfigData.AllNodes.Nodename)
        }

        User $("Administrator-" + $ConfigData.AllNodes.Nodename) {
            Ensure = "Present"
            UserName = "Administrator"
            Password = $credentials
            DependsOn = $("[DnsServerAddress]PrimaryDNSClient-" + $ConfigData.AllNodes.Nodename)
        }
    } #end node block

} #end configuration

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "pc"
            ThisComputerName = "APP03"
            InterfaceAlias = "Ethernet0"
            IPAddressCIDR = "192.168.1.2/24"
            GatewayAddress = "192.168.1.1"
            DNSAddress = "192.168.1.6"
Â Â Â Â Â Â Â Â Â Â Â Â DomainName = "democloud.local"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        }
    )
}

#RenameComputer -NodeName $ConfigData.AllNodes.NodeName -NewName 'APP03' -OutputPath c:\dsc\push
$outputPath = "$env:USERPROFILE\Desktop\buildAPPServer"
buildAPPServer -ConfigurationData $ConfigData -OutputPath $outputPath

Add-Content -Value "`n$(($ConfigData.AllNodes.IPAddressCIDR).Split("/")[0])      $($ConfigData.AllNodes.Nodename)" -Path "C:\Windows\System32\drivers\etc\hosts"

Get-Item WSMan:\localhost\Client\TrustedHosts | Set-Item -Value $($ConfigData.AllNodes.Nodename) -Force -Confirm:$false

$Domain = $(($env:USERDNSDOMAIN).Split(".")[0])
$domaincredentials = Get-Credential -UserName "$Domain\$env:USERNAME" -Message "Please enter your $Domain credentials"
$credentials = Get-Credential -UserName administrator -Message "Local Admin for $($ConfigData.AllNodes.Nodename)"

$cim = New-CimSession -ComputerName $ConfigData.AllNodes.Nodename -Credential $credentials

Set-DSCLocalConfigurationManager -Path $outputPath â€“Verbose
Start-DscConfiguration -cimsession $cim -Path $outputPath -Wait -Verbose -Force

#Copying DSC resource module to remote node
$Session = New-PSSession -ComputerName $ConfigData.AllNodes.Nodename -Credential $credentials

$Params =@{
    Path = 'C:\Program Files\WindowsPowerShell\Modules\*'
    Destination = 'C:\Program Files\WindowsPowerShell\Modules'
    ToSession = $Session
}

Copy-Item @Params -Recurse

Invoke-Command -Session $Session -ScriptBlock {Get-Module ComputerManagementDsc -ListAvailable}
