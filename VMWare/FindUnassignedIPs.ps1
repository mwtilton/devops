#Connect to VCD server
Connect-CIServer myvcloud.scalematrix.com

#Displays list of external networks for ease of use
Get-ExternalNetwork | Select Name
$ExtNetparam = Read-host "What is the external network? (paste from above)"
$ExternalNetwork = Get-ExternalNetwork $ExtNetparam

#Returns IPScope extension data. Takes a while, but subsequent variables return quickly.
$ExternalNetworkIPScope = $ExternalNetwork.ExtensionData.Configuration.ipscopes.IpScope

#Returns allocated IP addresses. This is a straight list, not a range, so it doesn't have to be manipulated
$AllocatedIPs = $ExternalNetworkIPScope.allocatedipaddresses.ipaddress

#Returns all of the subnets on the network and splits them at each octet.
$IPRangeStart = $ExternalNetworkIPScope.ipranges.iprange.startaddress.split(".")
$IPRangeEnd = $ExternalNetworkIPScope.ipranges.iprange.endaddress.split(".")

#Divides the total lines by 4, which is how many times the IPRangeOutput loop will need to run
$IPRangeCount = ($IPRangeStart.Count)/4

#Returns all of the suballocated IP addresses on the network and splits them at each octet.
$SubAllocatedStart = $ExternalNetworkIPScope.suballocations.suballocation.ipranges.iprange.startaddress.split(".")
$SubAllocatedEnd = $ExternalNetworkIPScope.suballocations.suballocation.ipranges.iprange.endaddress.split(".")

#Divides the total lines by 4, which is how many times the SubAllocatedIPOutput loop will need to run
$SubAllocatedCount = ($SubAllocatedStart.Count)/4

#Defines output variables as empty arrays
$IPRangeOutput = @()
$SubAllocatedIPOutput = @()

#Defines variables needed for loops
$Split3 = 3
$Split0 = 0
$Split1 = 1
$Split2 = 2
$SplitAdd = 0
$ticker = 0

#Takes every fourth line in the IP start address list and the IP end address list (the fourth octet) and builds a range between them
#This gives you every actual IP address, where before you only had a range. The split variables are necessary because there are multiple ranges,
#otherwise it would just run for the first one
While ($ticker -lt $IPRangeCount)
{
    $ticker = $ticker + 1
    $IPRangeOutput = $IPRangeOutput += Write-Output $($IPRangeStart[$Split3+$SplitAdd]..$IPRangeEnd[$Split3+$SplitAdd] | % {"$($IPRangeStart[$Split0+$SplitAdd]).$($IPRangeStart[$Split1+$SplitAdd]).$($IPRangeStart[$Split2+$SplitAdd]).$_"})
    $SplitAdd = $SplitAdd + 4
}

#Reset ticker and splitadd variables
$ticker = 0
$SplitAdd = 0

#Does same as above loop
While ($ticker -lt $SubAllocatedCount)
{
    $ticker = $ticker + 1
    $SubAllocatedIPOutput = $SubAllocatedIPOutput += Write-Output $($SubAllocatedStart[$Split3+$SplitAdd]..$SubAllocatedEnd[$Split3+$SplitAdd] | % {"$($SubAllocatedStart[$Split0+$SplitAdd]).$($SubAllocatedStart[$Split1+$SplitAdd]).$($SubAllocatedStart[$Split2+$SplitAdd]).$_"})
    $SplitAdd = $SplitAdd + 4
}

#Add suballocated IP list to allocated IP list, giving you the total allocated IPs
$TotalAllocatedIPs = ($SubAllocatedIPOutput += $AllocatedIPs) | sort -Unique

#Compares the total IP list with the allocated IP list and gives you the un-allocated IPs
$UniqueIPs = Compare-Object $IPRangeOutput $TotalAllocatedIPs | ? {$_.SideIndicator -match "<="}
($UniqueIPs | sort InputObject | select InputObject) | Out-File $env:TEMP\AvailableIPs.txt
# C:\temp\AvailableIPs.txt