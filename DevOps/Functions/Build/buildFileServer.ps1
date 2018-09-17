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
    Import-DscResource -ModuleName xSmbShare -ModuleVersion 2.1.0.0
    Import-DSCResource -ModuleName StorageDsc -ModuleVersion 4.1.0.0
    Import-DscResource -ModuleName cNtfsAccessControl -ModuleVersion 1.3.1
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0

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
        File DataDirectory
        {
            Ensure = 'Present'
            DestinationPath = "E:\CompanyData\Data"
            Type = 'Directory'
        }
        xSmbShare MainDriveShare
        {
            Ensure = "Present"
            Name   = "E$"
            Path = "E:\"
            FullAccess = "Domain Admins"
            Description = "This is the main drive share"
        }

        xSmbShare DataShare
        {
            Ensure = "Present"
            Name   = "Data$"
            Path = "E:\CompanyData\Data"
            FullAccess = "Domain Admins"
            Description = "This is the main Data share"
        }
        <#
        xSmbShare ExecShare
        {
            Ensure = "Present"
            Name   = "Executive$"
            Path = "E:\Company Data\Executive"
            FullAccess = "Domain Admins"
            Description = "This is the main Executive Share"
        }
        xSmbShare HRShare
        {
            Ensure = "Present"
            Name   = "HR$"
            Path = "E:\Company Data\HR"
            FullAccess = "Domain Admins"
            Description = "This is the main HR Share"
        }
        xSmbShare MarketingShare
        {
            Ensure = "Present"
            Name   = "Marketing$"
            Path = "E:\Company Data\Marketing"
            FullAccess = "Domain Admins"
            Description = "This is the main Marketing Share"
        }
        xSmbShare OneDriveShare
        {
            Ensure = "Present"
            Name   = "OneDrive$"
            Path = "E:\Company Data\OneDrive"
            FullAccess = "Domain Admins"
            Description = "This is the main OneDrive Share"
        }
        xSmbShare PrivateShare
        {
            Ensure = "Present"
            Name   = "Private$"
            Path = "E:\Company Data\Private"
            FullAccess = "Domain Admins"
            Description = "This is the main Private Share"
        }
        xSmbShare QBTestShare
        {
            Ensure = "Present"
            Name   = "QBTest$"
            Path = "E:\QBTest"
            FullAccess = "Domain Admins"
            Description = "This is the main QBTest Share"
        }
        xSmbShare UserFilesShare
        {
            Ensure = "Present"
            Name   = "UserFiles$"
            Path = "E:\Company Data\UserFiles"
            FullAccess = "Domain Admins"
            Description = "This is the main UserFiles Share"
        }
        xSmbShare UsersShare
        {
            Ensure = "Present"
            Name   = "Users$"
            Path = "E:\Users"
            FullAccess = "Domain Admins"
            Description = "This is the main Users Share"
        }
        #>
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
Configuration FileResourceDemo
{
    Node "localhost"
    {
        File DirectoryCopy
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Type = "Directory" # Default is "File".
            Recurse = $true # Ensure presence of subdirectories, too
            SourcePath = "C:\Users\Public\Documents\DSCDemo\DemoSource"
            DestinationPath = "C:\Users\Public\Documents\DSCDemo\DemoDestination"
        }

        Log AfterDirectoryCopy
        {
            # The message below gets written to the Microsoft-Windows-Desired State Configuration/Analytic log
            Message = "Finished running the file resource with ID DirectoryCopy"
            DependsOn = "[File]DirectoryCopy" # This means run "DirectoryCopy" first.
        }
    }
}

Configuration MyConfiguration {

  Node "Localhost" {

    ForEach ($Folder in $Node.FolderStructure) {

      # Each of our 'file' resources will be named after the path, but...
      #   we have to replace : with __ as colons aren't allowed in resource names
      File $Folder.Path.Replace(':','__') {
        DestinationPath = $Folder.Path
        Ensure = $Folder.Ensure
      }

    } # ForEach

  } # Node "Localhost"

} # configuration MyConfiguration



$ConfigurationData =
@{
    AllNodes = @(
        @{
            NodeName = "localhost"

            FolderStructure = @(

                @{
                    Path =   "D:\Management\Packages"
                    Ensure = "Present"
                }

                @{
                    Path =   "D:\Management\Wallpaper"
                    Ensure = "Present"
                }

            ) #FolderStruture = @(...

        } # localhost
    ) # AllNodes = @(...
}
#>
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

$domainCred = Get-Credential -UserName company\Administrator -Message "Please enter a new password for Domain Adminsistrator."
$Cred = Get-Credential -UserName Administrator -Message "Please enter a new password for Local Administrator and other accounts."

buildFileServer -ConfigurationData $ConfigData

Set-DSCLocalConfigurationManager -Path $env:USERPROFILE\Desktop\buildFileServer –Verbose
Start-DscConfiguration -Wait -Force -Path $env:USERPROFILE\Desktop\buildFileServer -Verbose


<#
# Prompt for Credentials and verify them using the DirectoryServices.AccountManagement assembly.
Write-Host "Please provide your credentials so the script can continue."
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
# Extract the current user's domain and also pre-format the user name to be used in the credential prompt.
$UserDomain = $env:USERDOMAIN
$UserName = "$UserDomain\$env:USERNAME"
# Define the starting number (always #1) and the desired maximum number of attempts, and the initial credential prompt message to use.
$Attempt = 1
$MaxAttempts = 5
$CredentialPrompt = "Enter your Domain account password (attempt #$Attempt out of $MaxAttempts):"
# Set ValidAccount to false so it can be used to exit the loop when a valid account is found (and the value is changed to $True).
$ValidAccount = $False

# Loop through prompting for and validating credentials, until the credentials are confirmed, or the maximum number of attempts is reached.
Do {
    # Blank any previous failure messages and then prompt for credentials with the custom message and the pre-populated domain\user name.
    $FailureMessage = $Null
    $Credentials = Get-Credential -UserName $UserName -Message $CredentialPrompt
    # Verify the credentials prompt wasn't bypassed.
    If ($Credentials) {
        # If the user name was changed, then switch to using it for this and future credential prompt validations.
        If ($Credentials.UserName -ne $UserName) {
            $UserName = $Credentials.UserName
        }
        # Test the user name (even if it was changed in the credential prompt) and password.
        $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
        Try {
            $PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext $ContextType,$UserDomain
        } Catch {
            If ($_.Exception.InnerException -like "*The server could not be contacted*") {
                $FailureMessage = "Could not contact a server for the specified domain on attempt #$Attempt out of $MaxAttempts."
            } Else {
                $FailureMessage = "Unpredicted failure: `"$($_.Exception.Message)`" on attempt #$Attempt out of $MaxAttempts."
            }
        }
        # If there wasn't a failure talking to the domain test the validation of the credentials, and if it fails record a failure message.
        If (-not($FailureMessage)) {
            $ValidAccount = $PrincipalContext.ValidateCredentials($UserName,$Credentials.GetNetworkCredential().Password)
            If (-not($ValidAccount)) {
                $FailureMessage = "Bad user name or password used on credential prompt attempt #$Attempt out of $MaxAttempts."
            }
        }
    # Otherwise the credential prompt was (most likely accidentally) bypassed so record a failure message.
    } Else {
        $FailureMessage = "Credential prompt closed/skipped on attempt #$Attempt out of $MaxAttempts."
    }

    # If there was a failure message recorded above, display it, and update credential prompt message.
    If ($FailureMessage) {
        Write-Warning "$FailureMessage"
        $Attempt++
        If ($Attempt -lt $MaxAttempts) {
            $CredentialPrompt = "Authentication error. Please try again (attempt #$Attempt out of $MaxAttempts):"
        } ElseIf ($Attempt -eq $MaxAttempts) {
            $CredentialPrompt = "Authentication error. THIS IS YOUR LAST CHANCE (attempt #$Attempt out of $MaxAttempts):"
        }
    }
} Until (($ValidAccount) -or ($Attempt -gt $MaxAttempts))

$username = $cred.username
$password = $cred.GetNetworkCredential().password

 # Get current domain using logged-on user's credentials
$CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
$domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

if ($domain.name -eq $null)
{
    write-host "Authentication failed - please verify your username and password."
    exit #terminate the script.
}
else
{
    write-host "Successfully authenticated with domain $domain.name"
    buildFileServer -ConfigurationData $ConfigData

    Set-DSCLocalConfigurationManager -Path $env:USERPROFILE\Desktop\buildFileServer –Verbose
    Start-DscConfiguration -Wait -Force -Path $env:USERPROFILE\Desktop\buildFileServer -Verbose
}

#>
