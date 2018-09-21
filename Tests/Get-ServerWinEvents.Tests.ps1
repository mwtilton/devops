Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Get-ServerWinEvents.ps1" -Force -ErrorAction Stop

Describe "Unit Testing for Get-ServerWinEvents" -tags "UNIT" {
    $logname = "network"
    $filename = $($env:COMPUTERNAME + "-" + $((Get-Date).ToString("dd-MMM-yy:HHmm")))
    Context "filename string creation" {


        It "unique log filename" {

            $filename | Should beLike "*21-SEP-18*"
        }
        It "work with log name wildcards" {

            Mock Get-WinEvent { return $true }
            Get-WinEvent -LogName *$logname* | Should Be $true
        }
        It "Out-file should have the right filename" {
            Mock Out-File {}
            {Out-File -FilePath $filename -Force } | Should Not throw
            {"hello" | Out-File -FilePath $filename -Force}
        }
        It "Out-file should not throw with force param" {
            Mock Out-File {} -ParameterFilter {$filepath -eq $filename, $force -eq $true}
            {Out-File -FilePath $filename -Force } | Should Not throw
        }

    }
    Context "Integration" {
        Mock Get-WinEvent { return $true}
        Mock Out-File {} -ParameterFilter {$force -eq $true, $filepath -eq $filename}
        It "Should not throw" {
            { Get-ServerWinEvents -LogName $logname} | Should Not throw
        }
        It "pull in some information" {
            Get-WinEvent | Should Not be $null
        }
    }
    Context "Where object" {
        Mock Where-Object {} -ParameterFilter {$filterscript -eq {$_.leveldisplayname -notlike "*information*"}}

        It "should work with filtering the script" {
            {Where-Object -FilterScript {$_.leveldisplayname -notlike "*information*"}} | Should Not throw
        }
    }
    Context "Null handling" {
        Mock Get-WinEvent { return $null}
        Mock Out-File {} -ParameterFilter {$force -eq $true, $filepath -eq $filename}
        It "Should not throw" {
            { Get-ServerWinEvents -LogName $logname} | Should Not throw
        }
    }
}
