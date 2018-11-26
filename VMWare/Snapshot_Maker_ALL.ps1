function CutString {

$string = $args[0]
if ($string.length -gt 40){$string.substring(0,$((($string).length) - 39))}

}

Add-PSSnapin VMware.VimAutomation.Core
Add-PSSnapin Vmware.VimAutomation.Cloud
Connect-VIServer -Server 10.21.1.4

$VMs = Get-VM * 
$date = get-date
$Resource = $args[0]

$VMs | ? {$_.resourcepool -match $resource -and $_.notes -notmatch "NoSnap"} | % {start-sleep 90 ; $_} | New-Snapshot -Memory -Name $("SM_AS_$(CutString [string]$($_.name)) $($(get-date).month)_$($(get-date).day)_$($(get-date).year) $($(get-date).hour)h_$($(get-date).minute)m_$($(get-date).second)s")
$VMs | ? {$_.resourcepool -match $resource} | Get-Snapshot | ? {$_.name -match "SM_AS_*"} | % {
	if ((($(($date) - $(($_).created))).days) -gt "7"){remove-snapshot -Snapshot $_ -Confirm:$false}
}