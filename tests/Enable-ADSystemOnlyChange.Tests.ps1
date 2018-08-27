Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Enable-ADSystemOnlyChange.ps1" -Force -ErrorAction Stop

Describe "Unit Testing for Enable-ADSystemOnlyChange" -tags "UNIT" {
    $mocks = @(
        "Get-Item",`
        "New-Item",`
        "Get-ItemProperty",`
        "New-ItemProperty",`
        "Set-ItemProperty",`
        "Get-Service",`
        "Restart-Service",`
        "Restart-Computer"
    )
    $mocks | ForEach-Object {
        Mock $_ {}
    }

    Context "Asserting the Initial Read-host and write warnings are called" {
        $regPath =  "HKLM:\System\CurrentControlSet\Services\NTDS\Parameters"

        Mock Write-Warning {}
        Mock Read-Host {return "nope"}

        Enable-ADSystemOnlyChange

        It "writes a warning" {
            Assert-MockCalled -CommandName Write-Warning -Exactly 1 -Scope Context
        }
        It "asks for continue from read-host" {
            Assert-MockCalled -CommandName Read-Host -Exactly 1 -Scope Context
        }
        It "registry path is accessible"{
            $regPath | Should Exist
        }
    }
    Context "Mocking true assertions" {
        Mock Get-Item {return $true}
        Mock Get-ItemProperty {return $true}
        Mock Get-Service {return $true}

        Mock Read-Host {return "y"}

        Enable-ADSystemOnlyChange -disable

        It "sets the item property" {
            Assert-MockCalled -CommandName Set-ItemProperty -Exactly 1
        }
        It "shouldn't make a new-item reg edit" {
            Assert-MockCalled -CommandName New-Item -Exactly 0
        }
        It "shouldn't try and make a new-item property either" {
            Assert-MockCalled -CommandName New-ItemProperty -Exactly 0
        }
        It "get the service" {
            Assert-MockCalled -CommandName Get-Service -Exactly 1
        }
        It "restarts the service" {
            Assert-MockCalled -CommandName Restart-Service -Exactly 1
        }
        It "does not restart the computer" {
            Assert-MockCalled -CommandName Restart-Computer -Exactly 0
        }

    }
    Context "Mocking False assertions" {
        Mock Get-Item {return $false}
        Mock Get-ItemProperty {$false}
        Mock Get-Service {return $false}

        Mock Read-Host {return "y"}

        Enable-ADSystemOnlyChange
        It "creates the new-item" {
            Assert-MockCalled -CommandName New-Item -Exactly 1
        }
        It "should make a new-itemproperty reg edit" {
            Assert-MockCalled -CommandName New-ItemProperty -Exactly 1
        }
        It "get the service" {
            Assert-MockCalled -CommandName Get-Service -Exactly 1
        }
        It "does not restarts the service" {
            Assert-MockCalled -CommandName Restart-Service -Exactly 0
        }
        It "restart the computer" {
            Assert-MockCalled -CommandName Restart-Computer -Exactly 1
        }
    }
}
