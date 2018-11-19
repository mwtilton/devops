Function New-PasswordNotification {
    <#
    .Synopsis
    Script to Automated Email Reminders when Users Passwords due to Expire.
    .DESCRIPTION
    Script to Automated Email Reminders when Users Passwords due to Expire.
    Requires: Windows PowerShell Module for Active Directory

    .EXAMPLE
    PasswordChangeNotification.ps1 -smtpServer mail.domain.com -expireInDays 21 -from "IT Support <support@domain.com>" -Logging -LogPath "c:\logFiles" -testing -testRecipient support@domain.com

    This example will use mail.domain.com as an smtp server, notify users whose password expires in less than 21 days, send mail from support@domain.com
    Logging is enabled, log path is c:\logfiles
    Testing is enabled, and test recipient is support@domain.com

    .EXAMPLE
    PasswordChangeNotification.ps1 -smtpServer mail.domain.com -expireInDays 21 -from "IT Support <support@domain.com>" -reportTo myaddress@domain.com -interval 1,2,5,10,15

    This example will use mail.domain.com as an smtp server, notify users whose password expires in less than 21 days, send mail from support@domain.com
    Report is enabled, reports sent to myaddress@domain.com
    Interval is used, and emails will be sent to people whose password expires in less than 21 days if the script is run, with 15, 10, 5, 2 or 1 days remaining untill password expires.

    #>
    [CmdletBinding()]
    param(
        # $smtpServer Enter Your SMTP Server Hostname or IP Address
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNull()]
        [string]$smtpServer,
        [Parameter(Mandatory=$True,Position=1)]
        [ValidateNotNull()]
        [int]$expireInDays,
        [Parameter(Mandatory=$True,Position=2)]
        [ValidateNotNull()]
        [string]$from
    )
    $date = Get-Date
    $today = $date.ToString("MM-dd-yyyy")

    try{
        Import-Module ActiveDirectory -ErrorAction Stop
    }
    catch{
        break
    }
    $defaultMaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy -ErrorAction Stop).MaxPasswordAge.Days
    #{(Enabled -eq $true) -and (PasswordNeverExpires -eq $false)} #-properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress #| where { $_.passwordexpired -eq $false }
    $textEncoding = [System.Text.Encoding]::UTF8

    $MaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy -ErrorAction Stop).MaxPasswordAge.Days

    $users = get-aduser -filter {(Enabled -eq $true) -and (PasswordNeverExpires -eq $false)} -properties SamAccountName, Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress

    $colUsers = @()
    $users | ForEach-Object {
        $expireson = ($_.passwordLastSet).AddDays($MaxPasswordAge)
        $daysToExpire = New-TimeSpan -Start $Expireson -End $today
        $daysToExpireInDays = $([math]::Round($($daysToExpire.TotalDays)))

        $userObj = New-Object System.Object

        if($expireInDays -gt $daysToExpireInDays){
            $subject = "Your password will expire in $daysToExpireInDays days"
            $body = "<font face=""verdana"">
            Dear $($_.Name),
            <p>$subject<br>
            To change your password on a PC press CTRL ALT Delete and choose Change Password <br>
            <p> If you are using a MAC you can now change your password via Web Mail. <br>
            Login to <a href=""https://mail.domain.com/owa"">Web Mail</a> click on Options, then Change Password.
            <p> Don't forget to Update the password on your Mobile Devices as well!
            <p>Thanks, <br>
            </P>
            IT Support
            <a href=""mailto:support@domain.com""?Subject=Password Expiry Assistance"">support@domain.com</a> | 0123 456 78910
            </font>"

            $userObj | Add-Member -Type NoteProperty -Name UserName -Value $_.SamAccountName
            $userObj | Add-Member -Type NoteProperty -Name Name -Value $_.Name
            $userObj | Add-Member -Type NoteProperty -Name Email -Value $_.EmailAddress
            $userObj | Add-Member -Type NoteProperty -Name PasswordSet -Value $_.passwordLastSet
            $userObj | Add-Member -Type NoteProperty -Name DaysToExpire -Value $daysToExpireInDays
            $userObj | Add-Member -Type NoteProperty -Name ExpiresOn -Value $expiresOn
            $colUsers += $userObj

            Send-Mailmessage -smtpServer $smtpServer -from $from -to $from -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding -ErrorAction Stop
        }
        Else {
            $body = $null
        }


    }
    $colUsers | Export-Csv "$env:USERPROFILE\Desktop\$today-Log.csv" -Encoding "UTF8" -Force


}

New-PasswordNotification -smtpServer "smtp.office365.com" -expireInDays 7 -from "tilt1@scalematrix.com"