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
    Import-DscResource -ModuleName xSmbShare -ModuleVersion 2.1.0.0
    Import-DSCResource -ModuleName StorageDsc -ModuleVersion 4.1.0.0
    Import-DscResource -ModuleName cNtfsAccessControl -ModuleVersion 1.3.1
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0

    Node $ConfigData.AllNodes.NodeName
    {

        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyOnly"
            DebugMode = "ForceModuleImport"
            RebootNodeIfNeeded = $true
        }
        File Testing {
            DestinationPath = "E:\testing"
            Ensure = "Present"
            Type = "Directory"
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
            }

            <#
            cNtfsPermissionEntry $Folder.Path.Replace(':','__')
            {
                Ensure = 'Present'
                Path = $Folder.Path
                Principal = 'DEMOCLOUD\Domain Admins'
                AccessControlInformation = @(
                    cNtfsAccessControlInformation
                    {
                        AccessControlType = 'Allow'
                        FileSystemRights = 'FullControl'
                        Inheritance = 'ThisFolderSubfoldersAndFiles'
                        NoPropagateInherit = $true
                    }
                )
                DependsOn = @("[File]" + "$($Folder.Path.Replace(':','__'))")
            }

            xSmbShare $(($folders.path).Split("\")[-1])
            {
                Ensure = "Present"
                Name   = @(($folders.path).Split("\")[-1] + "$")
                Path = $Folder.Path
                FullAccess = "Domain Admins"
                Description = "This is the main $(($folders.path).Split("\")[-1]) Share"
            }
            #>

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
                    Path =   "E:\Management\Packages"
                    Ensure = "Present"
                    Type = "Directory"
                    Principal = "DemoCloud\Domain Admins"
                    AccessControlInformation = @(

                        @{
                            AccessControlType = 'Allow'
                            FileSystemRights = 'FullControl'
                            Inheritance = 'ThisFolderSubfoldersAndFiles'
                            NoPropagateInherit = $true
                        }
                    )
                }

                @{
                    Path =   "E:\Management\Wallpaper"
                    Ensure = "Present"
                    Type = "Directory"
                    Principal = "DemoCloud\Domain Admins"
                }

            )
        }
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

$Session = New-CimSession -ComputerName $ConfigData.AllNodes.Nodename -Credential DemoCloud\Administrator

Set-DSCLocalConfigurationManager -CimSession $Session -Path $outputPath -Verbose
Start-DscConfiguration -CimSession $Session -Path $outputPath -Wait -Verbose -Force
