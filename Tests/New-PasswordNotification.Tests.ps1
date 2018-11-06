Import-Module "$env:git\DevOps\DevOps\Functions\New-PasswordNotification.ps1" -Force -ErrorAction Stop
Describe "New-PasswordNotification" -Tag "UNIT"{
    $demouser = @{
        Name = "John Smith"
        Emailaddress = "jsmith@place.com"
        PasswordLastSet = "10/10/18 12:00 PM"
        SamAccountName = "jsmith"
        Count = 1
    }

    Context "Testing the AD" {
        Mock Get-Date {}
        Mock Import-Module {}
        Mock Get-ADDefaultDomainPasswordPolicy {}
        Mock Get-ADuser {}

        New-PasswordNotification

        It "mocks the date" {
            Assert-MockCalled -CommandName Get-Date -Exactly 1
        }
        It "AD is imported" {
            Assert-MockCalled -CommandName Import-Module -Exactly 1
        }
        It "mocks the pass policy" {
            Assert-MockCalled -CommandName Get-ADDefaultDomainPasswordPolicy -Exactly 1
        }
        It "mocks the user" {
            Assert-MockCalled -CommandName Get-ADuser -Exactly 1
        }

    }
    Context "User Information" {

        Mock Get-ADuser -MockWith {return $demouser}
        Mock Get-Aduser {return $demouser} -ParameterFilter {
            $properties -eq "Name" -and $filter -like "{(Enabled -eq $true) -and (PasswordNeverExpires -eq $false)}"
        }
        New-PasswordNotification

        It "should have the correct user information" {
            $demouser.Name | Should -Be "John Smith"
            $demouser.Emailaddress | Should -Be "jsmith@place.com"
            $demouser.PasswordLastSet | Should -Be "10/10/18 12:00 PM"
            $demouser.SamAccountName | Should -Be "jsmith"
        }
        It "should have an accurate count of 0 users when mocked" {
            Mock Get-ADuser {}
            (Get-Aduser -Filter *).Count | Should Be 0
        }
        It "mock the parameter" {
            Mock Get-Aduser {return $demouser} -ParameterFilter {
                $properties -eq "Name" -and $filter -like "*"
            }
            $user = Get-Aduser -filter * -Properties Name, SamAccountName | where {$_.Name -eq "John Smith"}
            $user.SamAccountName | Should Be "jsmith"
        }
        It "mock the parameterfilter in the function" {
            Assert-MockCalled -CommandName Get-ADuser -Exactly 1
        }
    }
    Context "Creating the Hashtable" {

        Mock New-Object {
            return @{
                Name = $demouser.Name
                UserName = $demouser.SamAccountName
            }
        }

        $users = $demouser
        $users | ForEach-Object {
            $userObj = New-Object System.Object
            It "should add 1 username and name" {
                $userObj | Add-Member -Type NoteProperty -Name UserName -Value $demouser.SamAccountName
                $userObj | Add-Member -Type NoteProperty -Name Name -Value $demouser.Name

                $userObj.UserName | Should Be "jsmith"
                $userObj.Name | Should Be "John Smith"

            }
            It "should not be null or empty" {
                $userObj | Should -Not -BeNullOrEmpty
            }
        }

    }
    Context "Generating Email" {
        $messageDays = 1
        $subject = "Your password will expire in $messageDays days"

        $body = "
<font face=""verdana"">
Dear $($demouser.Name),
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
        It "should have a subject" {
            $subject | Should Be "Your password will expire in 1 days"
        }
        It "should have a body" {
            $body | Should Be "
<font face=""verdana"">
Dear John Smith,
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
        }

    }

}
