Import-Module "$env:git\DevOps\DevOps\Functions\New-PasswordNotification.ps1" -Force -ErrorAction Stop
Describe "New-PasswordNotification" -Tag "UNIT"{

    Context "Testing the AD" {
        Mock Import-Module {}
        Mock Get-AduserResultantPasswordPolicy {}
        Mock Get-ADuser {}

        New-PasswordNotification

        It "AD is imported" {
            Assert-MockCalled -CommandName Import-Module -Exactly 1
        }
        It "mocks the pass policy" {
            Assert-MockCalled -CommandName Get-AduserResultantPasswordPolicy -Exactly 1
        }
        It "mocks the user" {
            Assert-MockCalled -CommandName Get-ADuser -Exactly 1
        }
    }
    Context "User Information" {
        $demouser = @{
            Name = "John Smith"
            Emailaddress = "jsmith@place.com"
            PasswordLastSet = "10/10/18 12:00 PM"
            SamaccountName = "jsmith"
            Count = 1
        }

        Mock Get-ADuser -MockWith {return $demouser}

        Mock Get-AduserResultantPasswordPolicy {}
        Mock New-Object {}

        New-PasswordNotification

        It "should have the correct user information" {
            $_.Name | Should -Be "John Smith"
            $_.Emailaddress | Should -Be "jsmith@place.com"
            $_.PasswordLastSet | Should -Be "10/10/18 12:00 PM"
            $_.SamaccountName | Should -Be "jsmith"
        }
        It "gets the policy" {
            Assert-MockCalled -CommandName Get-AduserResultantPasswordPolicy -Exactly 1
        }
        It "creates a new-object" {
            Assert-MockCalled -CommandName New-Object -Exactly 1
        }

    }

}
