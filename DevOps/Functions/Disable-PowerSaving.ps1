#Requires -RunAsAdministrator
#Inform user
Write-Host -ForegroundColor White "Iterating through network adapters"
$intNICid=0; do
{
	#Read network adapter properties
	$objNICproperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Class\{0}\{1}" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", ( "{0:D4}" -f $intNICid)) -ErrorAction SilentlyContinue)

	#Determine if the Network adapter index exists
	If ($objNICproperties)
	{
		#Filter network adapters
		# * only Ethernet adapters (ifType = ieee80211(71) - http://www.iana.org/assignments/ianaiftype-mib/ianaiftype-mib)
		# * root devices are exclude (for instance "WAN Miniport*")
		# * software defined network adapters are excluded (for instance "RAS Async Adapter")
        If (($objNICproperties."*ifType" -eq 6 -or $objNICproperties."*ifType" -eq 71) -and
        #If (($objNICproperties."*ifType" -eq 71) -and
		    ($objNICproperties.DeviceInstanceID -notlike "ROOT\*") -and
			($objNICproperties.DeviceInstanceID -notlike "SW\*")
			)
		{

			#Read hardware properties
			$objHardwareProperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Enum\{0}" -f $objNICproperties.DeviceInstanceID) -ErrorAction SilentlyContinue)
			If ($objHardwareProperties.FriendlyName)
			{ $strNICDisplayName = $objHardwareProperties.FriendlyName }
			else
			{ $strNICDisplayName = $objNICproperties.DriverDesc }

			#Read Network properties
			$objNetworkProperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Network\{0}\{1}\Connection" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", $objNICproperties.NetCfgInstanceId) -ErrorAction SilentlyContinue)

            #Inform user
			Write-Host -NoNewline -ForegroundColor White "   ID     : "; Write-Host -ForegroundColor Yellow ( "{0:D4}" -f $intNICid)
			Write-Host -NoNewline -ForegroundColor White "   Network: "; Write-Host $objNetworkProperties.Name
            Write-Host -NoNewline -ForegroundColor White "   NIC    : "; Write-Host $strNICDisplayName
            Write-Host -ForegroundColor White "   Actions:"

            #Disable power saving
            Set-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Class\{0}\{1}" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", ( "{0:D4}" -f $intNICid)) -Name "PnPCapabilities" -Value "24" -Type DWord
            Write-Host -ForegroundColor Green ("   - Power saving disabled")
            Write-Host ""
		}
	}

	#Next NIC ID
	$intNICid+=1
} while ($intNICid -lt 255)


# Request the user to reboot the machine
Write-Host -NoNewLine -ForegroundColor White "Please "
Write-Host -NoNewLine -ForegroundColor Yellow "reboot"
Write-Host -ForegroundColor White " the machine for the changes to take effect."
