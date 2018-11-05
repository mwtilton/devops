Import-Module "$env:git\DevOps\DevOps\Functions\New-PasswordNotification.ps1" -Force -ErrorAction Stop
Describe "New-PasswordNotification" -Tag "UNIT"{

    Context "Testing the AD" {
        Mock Import-Module {}
        Mock Get-ADuser {}

        New-PasswordNotification

        It "AD is imported" {
            Assert-MockCalled -CommandName Import-Module -Exactly 1
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
        Mock New-Object {}

        $user = Get-ADUser -Filter *
        It "return a count of 1 user" {
            $user.count | Should -Be 1
        }
        $user | ForEach-Object {
            It "should ahve the correct user information" {
                $_.Name | Should -Be "John Smith"
                $_.Emailaddress | Should -Be "jsmith@place.com"
                $_.PasswordLastSet | Should -Be "10/10/18 12:00 PM"
                $_.SamaccountName | Should -Be "jsmith"
            }

            It "creates a new-object" {
                Assert-MockCalled -CommandName New-Object -Exactly 1
            }
        }
    }

}
