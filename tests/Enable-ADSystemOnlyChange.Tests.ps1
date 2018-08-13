Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Enable-ADSystemOnlyChange.ps1" -Force -ErrorAction Stop

Describe "Unit Testing for Enable-ADSystemOnlyChange" -tags "UNIT" {
    Context "Opening" {
        $regPath =  "HKLM:\System\CurrentControlSet\Services\NTDS\Parameters"

        Mock Write-Warning {}
        Mock Read-Host {}

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
}

<#

     Else {
        # Set the registry value
        $valueData = 1
        if ($Disable) {
            $valueData = 0
        }

        $key = Get-Item HKLM:\System\CurrentControlSet\Services\NTDS\Parameters -ErrorAction SilentlyContinue
        if (!$key) {
            New-Item HKLM:\System\CurrentControlSet\Services\NTDS\Parameters -ItemType RegistryKey | Out-Null
        }

        $kval = Get-ItemProperty HKLM:\System\CurrentControlSet\Services\NTDS\Parameters -Name "Allow System Only Change" -ErrorAction SilentlyContinue
        if (!$kval) {
            New-ItemProperty HKLM:\System\CurrentControlSet\Services\NTDS\Parameters -Name "Allow System Only Change" -Value $valueData -PropertyType DWORD | Out-Null
        } else {
            Set-ItemProperty HKLM:\System\CurrentControlSet\Services\NTDS\Parameters -Name "Allow System Only Change" -Value $valueData | Out-Null
        }

        # Restart the NTDS service. Use a reboot on older OS where the service does not exist.
        If (Get-Service NTDS -ErrorAction SilentlyContinue) {
            Write-Warning "You must restart the Directory Service to coninue..."
            Restart-Service NTDS -Confirm:$true
        } Else {
            Write-Warning "You must reboot the server to coninue..."
            Restart-Computer localhost -Confirm:$true
        }

#>
