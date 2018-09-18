
Function Test-Credential {
    [OutputType([Bool])]

    Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeLine = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias(
            'PSCredential'
        )]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [String]
        $Domain = $Credential.GetNetworkCredential().Domain
    )

    Begin {
        [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement") |
            Out-Null

        $principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
            [System.DirectoryServices.AccountManagement.ContextType]::Domain, $Domain
        )
    }

    Process {
        foreach ($item in $Credential) {
            $networkCredential = $Credential.GetNetworkCredential()

            Write-Output -InputObject $(
                $principalContext.ValidateCredentials(
                    $networkCredential.UserName, $networkCredential.Password
                )
            )
        }
    }

    End {
        $principalContext.Dispose()
    }
}

Function Get-CredCheck {
    [CmdletBinding()]
    Param (
        <#
        [Parameter(
            Mandatory = $true,
            ValueFromPipeLine = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias(
            'PSCredential'
        )]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credentials = [System.Management.Automation.PSCredential]::Empty,

        [Parameter()]
        [String]
        $Domain = $Credentials.GetNetworkCredential().Domain
        #>
    )
    Begin {
        # Prompt for Credentials and verify them using the DirectoryServices.AccountManagement assembly.
        Write-Host "Please provide your credentials so the script can continue."
        #Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        # Extract the current user's domain and also pre-format the user name to be used in the credential prompt.
        $UserDomain = $env:USERDOMAIN
        $UserName = "$UserDomain\$env:USERNAME"
        # Define the starting number (always #1) and the desired maximum number of attempts, and the initial credential prompt message to use.
        $Attempt = 1
        $MaxAttempts = 3
        $CredentialPrompt = "Enter your Domain account password (attempt #$Attempt out of $MaxAttempts):"
        # Set ValidAccount to false so it can be used to exit the loop when a valid account is found (and the value is changed to $True).
        $ValidAccount = $False

    }
    Process {
        Do {
            <#
            foreach ($item in $Credential) {
                $networkCredential = $Credential.GetNetworkCredential()

                Write-Output -InputObject $(
                    $principalContext.ValidateCredentials(
                        $networkCredential.UserName, $networkCredential.Password
                    )
                )
            }
                [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]
            $Credentials = [System.Management.Automation.PSCredential]::Empty,
            #>

            $Credentials = Get-Credential -UserName $UserName -Message $CredentialPrompt
            $FailureMessage = $Null
            $Domain = $Credentials.GetNetworkCredential().Domain

            [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement") |
                Out-Null

            $principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
                [System.DirectoryServices.AccountManagement.ContextType]::Domain, $Domain
            )

            # Verify the credentials prompt wasn't bypassed.
            If ($Credentials) {

                If ($Credentials.UserName -ne $UserName) {
                    $UserName = $Credentials.UserName
                }
                If (-not($FailureMessage)) {
                    $networkCredential = $Credentials.GetNetworkCredential()
                    $ValidAccount = $principalContext.ValidateCredentials($networkCredential.UserName, $networkCredential.Password)
                    If (-not($ValidAccount)) {
                        $FailureMessage = "Bad user name or password used on credential prompt attempt #$Attempt out of $MaxAttempts."
                    }
                    Else{
                        "it thinks its valid"
                    }
                }
            # Otherwise the credential prompt was (most likely accidentally) bypassed so record a failure message.
            }
            Else {
                $FailureMessage = "Credential prompt closed/skipped on attempt #$Attempt out of $MaxAttempts."
                Write-Warning "$FailureMessage"
                break
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

        }Until (($ValidAccount) -or ($Attempt -gt $MaxAttempts))
    }
    End {
        $principalContext.Dispose()
    }


}
$validcred = Get-CredCheck
#Test-Credential
#Enter-PSSession -Credential $validCred -ComputerName FileServer01
