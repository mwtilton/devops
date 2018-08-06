Function Get-UserVHDFile {
    $users = get-aduser -filter *
    $vhds = gci \\fileserver01\users | ? {$_.name -match '\d{10}'}

    $UPDList = Foreach ($VHD in $VHDs)
    {
        New-Object -Typename PSObject | Add-Member -MemberType NoteProperty -Name Username -Value (($Users | ? {$_.SID -eq ($VHD.name -replace "uvhd-","" -replace ".vhdx","")}).UserPrincipalName) -Passthru | Add-Member -Membertype NoteProperty -Name "VHD File" -Value $VHD.Name -PassThru
    }

    $UPDList | ? {$_.Username} | Sort Username | FT
}
