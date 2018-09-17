Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-CredCheck.ps1" -Force -ErrorAction Stop

Describe "Get-CredCheck" -Tag "UNIT" {
    Context "Finds the Creds" {
        $CurrentDomain = "Democloud"
        $user = "demouser"
        $pass = "Temp123!"
        $securepassword = $Pass | ConvertTo-SecureString -AsPlainText -Force

        Mock Get-Credential -MockWith {$_.username -eq "$currentdomain\$username"} {return $true}
        #Mock New-Object -mockwith {New-MockObject System.Management.Automation -ArgumentList $User, $SecurePassword} {return $true}
        Mock New-Object -mockwith {New-MockObject System.Management.Automation.PSCredential -ArgumentList $User, $SecurePassword} {return $true}
        Mock New-Object -MockWith {New-MockObject System.DirectoryServices.DirectoryEntry -ArgumentList $CurrentDomain,$User,$Password} {return $true}

        Get-CredCheck

        It "calls the credential 1 on time on failed attempts" {
            Assert-MockCalled -CommandName Get-Credential -Exactly 1
        }
    }

}
