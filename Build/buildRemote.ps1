#Discover & Download resources
<#
Find-Module -Name *computer*
Install-Module -Name ComputerManagementDsc -RequiredVersion 5.2.0.0
Get-DscResource -Module ComputerManagementDsc
Get-DscResource -Name Computer -Syntax
#>

#Simple DSC Configuration

Configuration buildAPPServer {

    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 5.2.0.0
    Import-DscResource -ModuleName NetworkingDSC -ModuleVersion 6.1.0.0
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0
    Import-DSCResource -ModuleName StorageDsc -ModuleVersion 4.1.0.0
    Import-DscResource -ModuleName xSmbShare -ModuleVersion 2.1.0.0
    Import-DscResource -ModuleName cNtfsAccessControl -ModuleVersion 1.3.1

    Node $ConfigData.AllNodes.Nodename {
        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyOnly"
            DebugMode = "ForceModuleImport"
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

    Node $ConfigData.AllNodes.Nodename.IndexOf(0) {
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
             Size = 22GB
        }

        Disk EVolume
        {
             DiskId = 0
             DriveLetter = 'E'
             FSLabel = 'Data'
             DependsOn = '[Disk]CVolume'
        }
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
                DependsOn = @("[File]" + $($Folder.Path.Replace(':','__')))
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

} #end configuration

$ConfigData = @{
    AllNodes = @(

        @{
            NodeName = "WIN-IJEVNIGDBQ4"

            ThisComputerName = "FileServer01"
            InterfaceAlias = "Ethernet0"
            IPAddressCIDR = "192.168.1.4/24"
            GatewayAddress = "192.168.1.1"
            DNSAddress = "192.168.1.2"
            DomainName = "democloud.local"

            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true

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
        }
        @{
            NodeName = "WIN-F59K035SMS1"

            ThisComputerName = "APP01"
            InterfaceAlias = "Ethernet0"
            IPAddressCIDR = "192.168.1.3/24"
            GatewayAddress = "192.168.1.1"
            DNSAddress = "192.168.1.2"
            DomainName = "democloud.local"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        }
    )
}

#RenameComputer -NodeName $ConfigData.AllNodes.NodeName -NewName 'APP03' -OutputPath c:\dsc\push

$outputPath = "$env:USERPROFILE\Desktop\buildAPPServer"
buildAPPServer -ConfigurationData $ConfigData -OutputPath $outputPath

Import-Module $env:USERPROFILE\Desktop\devops\DevOps -Force

Get-Item WSMan:\localhost\Client\TrustedHosts | Clear-Item -Force
Get-Item WSMan:\localhost\Client\TrustedHosts | Set-Item -Value "$($($ConfigData.AllNodes.Nodename) -join ",")" -Force -Confirm:$false

Get-HostsFile -Computer $env:COMPUTERNAME -Verbose | select * |ft
Get-Item WSMan:\localhost\Client\TrustedHosts

#$credentials = Get-Credential -UserName administrator -Message "Local Admin"

Get-Service -Name *winrm* | Restart-Service
Get-CimSession | Remove-CimSession

$($ConfigData.AllNodes) | ForEach-Object {
    Write-Host "$(($_.IPAddressCIDR).Split('/')[0])      $($_.Nodename)"

    Add-Content -Value "`n$(($_.IPAddressCIDR).Split("/")[0])      $($_.Nodename)" -Path "C:\Windows\System32\drivers\etc\hosts"

    #New-Variable -Name $_.NodeName -Value $($_.Nodename)

    #$Domain = $(($env:USERDNSDOMAIN).Split(".")[0])

    $credentials = Get-Credential -UserName "$env:USERNAME" -Message "Please enter your $($_.Nodename) credentials"
    $cim = New-CimSession -ComputerName $_.Nodename -Credential $credentials
    <#
    Set-DSCLocalConfigurationManager -Path $outputPath -Verbose
    Start-DscConfiguration -cimsession $cim -Path $outputPath -Wait -Verbose -Force

    #Copying DSC resource module to remote node

    $Session = New-PSSession -ComputerName $_.Nodename -Credential $credentials


    Try{
        $Params =@{
            Path = 'C:\Program Files\WindowsPowerShell\Modules\*'
            Destination = 'C:\Program Files\WindowsPowerShell'
            ToSession = $Session
            ErrorAction = "stop"
            Recurse = $true
        }

        Copy-Item @Params

    }
    Catch{
        If($_.Exception.ToString().Contains("An item with the specified name  already exists.")){
            Write-Host "Files for $($_.Nodename) already exists. Skipping!" -ForegroundColor DarkGreen
        }
        Else{
            $_ | fl * -force
            $_.InvocationInfo.BoundParameters | fl * -force
            $_.Exception
        }

    }

    Invoke-Command -Session $Session -ScriptBlock {Get-Module ComputerManagementDsc -ListAvailable}
    #>

}


#$cim = New-CimSession -ComputerName { foreach-object {$($ConfigData.AllNodes.Nodename)}} -Credential $credentials

<#
Set-DSCLocalConfigurationManager -Path $outputPath -Verbose
Start-DscConfiguration -cimsession $cim -Path $outputPath -Wait -Verbose -Force

#Copying DSC resource module to remote node
$Session = New-PSSession -ComputerName $ConfigData.AllNodes.Nodename -Credential $credentials


Try{
    $Params =@{
        Path = 'C:\Program Files\WindowsPowerShell\Modules'
        Destination = 'C:\Program Files\WindowsPowerShell'
        ToSession = $Session
        ErrorAction = "SilentlyContinue"
        Recurse = $true
    }

    Copy-Item @Params

}
Catch{
    If($_.Exception.ToString().Contains("An item with the specified name  already exists.")){
        Write-Host "Files for $($_.Nodename) already exists. Skipping!" -ForegroundColor DarkGreen
    }
    Else{
        $_ | fl * -force
        $_.InvocationInfo.BoundParameters | fl * -force
        $_.Exception
    }

}

Invoke-Command -Session $Session -ScriptBlock {Get-Module ComputerManagementDsc -ListAvailable}
#>
