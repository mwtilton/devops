Connect-VIServer -Server 10.21.1.4 -User vcloud\jessewaddell -Password F1xMyCl0ud!

$oneMonthAgo = (Get-Date).AddDays(-30) 

Get-VM BeneMedical-* | Foreach-Object {Get-Snapshot -VM $_ | Foreach-Object {if($_.Created -lt $oneMonthAgo) {Remove-Snapshot $_ -Confirm:$false}}}