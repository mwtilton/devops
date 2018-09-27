function Get-ServerWinEvents {
    [CmdletBinding()]
    param (
        [string]$logname
    )

    begin {
        $filename = $($env:COMPUTERNAME + "-" + $((Get-Date).ToString("dd-MMM-yy:HHmm")))
    }

    process {
        Get-WinEvent -LogName *$logname* | ? {$_.leveldisplayname -notlike "*information*"} | Sort-Object -Property TimeCreated | fl | Out-File -FilePath "$env:USERPROFILE\Desktop\$filename.log" -Force
    }

    end {
    }


}
