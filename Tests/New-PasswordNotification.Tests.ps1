Import-Module "$env:git\DevOps\DevOps\Functions\New-PasswordNotification.ps1" -Force -ErrorAction Stop
Describe "New-PasswordNotification" -Tag "UNIT"{
    $demouser = @{
        Name = "John Smith"
        Emailaddress = "jsmith@place.com"
        PasswordLastSet = "10/10/18 12:00 PM"
        SamaccountName = "jsmith"
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

        New-PasswordNotification

        It "should have the correct user information" {
            $demouser.Name | Should -Be "John Smith"
            $demouser.Emailaddress | Should -Be "jsmith@place.com"
            $demouser.PasswordLastSet | Should -Be "10/10/18 12:00 PM"
            $demouser.SamaccountName | Should -Be "jsmith"
        }
        It "should have an accurate count of 0 users when mocked" {
            Mock Get-ADuser {}
            (Get-Aduser -Filter *).Count | Should Be 0
        }


    }
    Context "Creating the Hashtable" {

        Mock New-Object {
            return @{
                Name = $demouser.Name
                UserName = $demouser.SamaccountName
            }
        }
        $columns = @()
        $users = $demouser
        $users | ForEach-Object {
            $userObj = New-Object System.Object
            It "should add 1 username and name" {
                $userObj | Add-Member -Type NoteProperty -Name UserName -Value $demouser.SamaccountName
                $userObj | Add-Member -Type NoteProperty -Name Name -Value $demouser.Name

                $userObj.UserName | Should Be "jsmith"
                $userObj.Name | Should Be "John Smith"

            }
            It "should not be null or empty" {
                $userObj | Should -Not -BeNullOrEmpty
            }
            It "should have added it to the column array" {
                $columns += $userObj
                $columns | Should -Not -BeNullOrEmpty
            }

        }
        It "Columns array Should not be null or empty out of the loop" {
            $columns | Should -Not -BeNullOrEmpty
        }
        It "Should have added the UserObj to the array" -Skip {
            $columns.Name | Should Be $demouser.Name
            $columns.SamaccountName | Should Be $demouser.SamaccountName
        }

    }

}
