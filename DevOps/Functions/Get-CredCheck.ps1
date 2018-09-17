Function Get-CredCheck {
    [CmdletBinding()]
    param (

    )


    #Prompt for Credentials and verify them using the DirectoryServices.AccountManagement assembly.
    Write-Host "Please provide your credentials so the script can continue."
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    # Extract the current user's domain and also pre-format the user name to be used in the credential prompt.
    $UserDomain = $env:USERDOMAIN
    $UserName = "$UserDomain\$env:USERNAME"


    # Define the starting number (always #1) and the desired maximum number of attempts, and the initial credential prompt message to use.
    $Attempt = 1
    $MaxAttempts = 1
    $CredentialPrompt = "Enter your Domain account password (attempt #$Attempt out of $MaxAttempts):"
    # Set ValidAccount to false so it can be used to exit the loop when a valid account is found (and the value is changed to $True).
    $ValidAccount = $False
    $cred = Get-Credential #Read credentials
    $username = $cred.username
    $password = $cred.GetNetworkCredential().password

    # Get current domain using logged-on user's credentials
    $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
    $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

    if ($domain.name -eq $null)
    {
        write-host "Authentication failed - please verify your username and password."
        Break #terminate the script.
    }
    else
    {
        write-host "Successfully authenticated with domain $domain.name"
    }
    <#
    $Credentials = Get-Credential -UserName $UserName -Message $CredentialPrompt
    $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
    $ValidAccount = $PrincipalContext.ValidateCredentials($UserName,$Credentials.GetNetworkCredential().Password)


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
            }
            Catch {
                If ($_.Exception.InnerException -like "*The server could not be contacted*") {
                    $FailureMessage = "Could not contact a server for the specified domain on attempt #$Attempt out of $MaxAttempts."
                }
                Else {
                    $FailureMessage = "Unpredicted failure: `"$($_.Exception.Message)`" on attempt #$Attempt out of $MaxAttempts."
                }
            }
            # If there wasn't a failure talking to the domain test the validation of the credentials, and if it fails record a failure message.
            If (-not($FailureMessage)) {
                $ValidAccount = $PrincipalContext.ValidateCredentials($UserName,$Credentials.GetNetworkCredential().Password)

                Write-Host $UserName $Credentials.GetNetworkCredential().Password "returns $ValidAccount"-ForegroundColor Red

                If (-not($ValidAccount)) {
                    $FailureMessage = "Bad user name or password used on credential prompt attempt #$Attempt out of $MaxAttempts."
                }
            }
        # Otherwise the credential prompt was (most likely accidentally) bypassed so record a failure message.
        }
        Else {
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
    #>
}
