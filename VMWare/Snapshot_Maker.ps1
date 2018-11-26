function CutString {

$string = $args[0]
if ($string.length -gt 40){$string.substring(0,$((($string).length) - 39))}

}

Add-PSSnapin VMware.VimAutomation.Core
Add-PSSnapin Vmware.VimAutomation.Cloud
Connect-VIServer -Server 10.20.0.4

$VM = $args[0]
$Resource = $args[1]
$date = get-date
Get-VM -Id $VM | ? {$_.resourcepool -match $resource} | New-Snapshot -Memory -Name $("$(CutString [string]$($_.name)) $($date.month)_$($date.day)_$($date.year) $($date.hour)h_$($date.minute)m_$($date.second)s")
Get-VM -Id $VM | ? {$_.resourcepool -match $resource} | Get-Snapshot | % {
	if ((($(($date) - $(($_).created))).days) -gt "7"){remove-snapshot -Snapshot $_ -Confirm:$false}
}