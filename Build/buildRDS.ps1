param (
    [string]$brokerFQDN,
    [string]$webFQDN,
    [string]$collectionName = "DemoCloud",
    [string]$collectionDescription
)

$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName

if (!$collectionName) {$collectionName = "DemoCloud"}
if (!$collectionDescription) {$collectionDescription = "Remote Desktop instance for $collectionName"}

Configuration RemoteDesktopSessionHost
{
    param
    (

        # Connection Broker Name
        [Parameter(Mandatory)]
        [String]$collectionName,

        # Connection Broker Description
        [Parameter(Mandatory)]
        [String]$collectionDescription,

        # Connection Broker Node Name
        [String]$connectionBroker,

        # Web Access Node Name
        [String]$webAccessServer
    )
    Import-DscResource -Module xRemoteDesktopSessionHost

    if (!$connectionBroker) {$connectionBroker = $localhost}
    if (!$connectionWebAccessServer) {$webAccessServer = $localhost}

    Node "localhost"
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature Remote-Desktop-Services
        {
            Ensure = "Present"
            Name = "Remote-Desktop-Services"
        }

        WindowsFeature RDS-RD-Server
        {
            Ensure = "Present"
            Name = "RDS-RD-Server"
        }

        WindowsFeature RSAT-RDS-Tools
        {
            Ensure = "Present"
            Name = "RSAT-RDS-Tools"
            IncludeAllSubFeature = $true
        }

        if ($localhost -eq $connectionBroker) {
            WindowsFeature RDS-Connection-Broker
            {
                Ensure = "Present"
                Name = "RDS-Connection-Broker"
            }
        }

        if ($localhost -eq $webAccessServer) {
            WindowsFeature RDS-Web-Access
            {
                Ensure = "Present"
                Name = "RDS-Web-Access"
            }
        }

        WindowsFeature RDS-Licensing
        {
            Ensure = "Present"
            Name = "RDS-Licensing"
        }

        xRDSessionDeployment Deployment
        {
            SessionHost = "APP01.democloud.local"
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
            WebAccessServer = if ($WebAccessServer) {$WebAccessServer} else {$localhost}
            DependsOn = "[WindowsFeature]Remote-Desktop-Services", "[WindowsFeature]RDS-RD-Server"
        }

        xRDSessionCollection Collection
        {
            CollectionName = $collectionName
            CollectionDescription = $collectionDescription
            SessionHost = "APP01.democloud.local"
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
            DependsOn = "[xRDSessionDeployment]Deployment"
        }
        xRDSessionCollectionConfiguration CollectionConfiguration
        {
            CollectionName = $collectionName
            CollectionDescription = $collectionDescription
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
            TemporaryFoldersDeletedOnExit = $false
            SecurityLayer = "SSL"
            <#
                IdleSessionLimitMin = "60"
                DisconnectedSessionLimitMin = "60"
                ActiveSessionLimitMin = "90"
                UserGroup = @("Domain Admins","RD Users")
                DiskPath = "\\fileserver\users$"
                ClientPrinterRedirected = $true
                AuthenticateUsingNLA = $true
                #UPD's
                EnableUserProfileDisk = $true
                MaxUserProfileDiskSizeGB = "20"
            #>

            DependsOn = "[xRDSessionCollection]Collection"
        }

        xRDLicenseConfiguration License
        {
            ConnectionBroker = $localhost
            LicenseMode = PerUser
        }
    }
}

write-verbose "Creating configuration with parameter values:"
write-verbose "Collection Name: $collectionName"
write-verbose "Collection Description: $collectionDescription"
write-verbose "Connection Broker: $brokerFQDN"
write-verbose "Web Access Server: $webFQDN"

RemoteDesktopSessionHost -collectionName $collectionName -collectionDescription $collectionDescription -connectionBroker $brokerFQDN -webAccessServer $webFQDN -OutputPath $env:USERPROFILE\Desktop\RDSDSC\
$outputPath = "$env:USERPROFILE\Desktop\RDSDSC\"
RemoteDesktopSessionHost -OutputPath $outputPath

Set-DscLocalConfigurationManager -verbose -path $outputPath
Start-DscConfiguration -wait -force -verbose -path $outputPath
