<#

.SYNOPSIS
Retrieves  page file location information from  local or remote computers.

.DESCRIPTION
The script uses .Net RegistryKey class and its OpenRemoteBaseKey method to retrieve the information.
Each computer is contacted sequentially, not in parallel.

.EXAMPLE
Run it from the location where the script is stored.
PS C:\Users\Administrator\Downloads> .\PageFileLocation.ps1

ServerName                                                  PageFileLocation
----------                                                  ----------------
Server1                                                     C:\pagefile.sys

.EXAMPLE
Read computer names from a file (one name per line) and retrieve their page file loction.
Get-PageFileLocation -serverlist (Get-Content C:\server.txt)

ServerName                              PageFileLocation
----------                              ----------------
PRASADMU23                              C:\pagefile.sys
NOTFOUND                                The network path was not found.

#>
function Get-PageFileLocation()
{
	[CmdLetBinding ()]
	param(
		[Parameter(Mandatory=$False)]
		[String[]]$serverlist
	)
	#Get the list of servers
#	$serverlist=get-content "C:\servers.txt" -ErrorAction SilentlyContinue
	if($serverlist -eq $null)
	{
		$serverlist=hostname
	}
	$a=@()
	#Regular Expression to extract the page file location from the registry key
	$Regex="^\\.{3}(.*)"
	$Object=New-Object PSObject
	$Object1=New-Object PSObject
	foreach ($server in $serverlist)
	{
		try
		{
			#Open the registry on multiple remote computers
			$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$server )
			$RegKeyPath= "SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
			$pageFileKey=$reg.OpenSubKey($RegKeyPath)
			$pageFileLocation=$pageFileKey.GetValue("ExistingPageFiles")
			if("$pageFileLocation" -match $Regex)
			{
				$pageFileLocation=$Matches[1]
				$Object | add-member Noteproperty ServerName $server -Force
				$Object | add-member Noteproperty PageFileLocation $pageFileLocation -Force
				$a+=$Object
			}
		}
		Catch [Exception] # To capture the non reachable servers
		{
			[string]$ExcepMsg=$_.Exception.Message
			$Object1 | add-member Noteproperty ServerName $server -Force
			$Object1 | add-member Noteproperty PageFileLocation $ExcepMsg -Force
			$a+=$Object1
		}
	}
	Write-Output $a
}
