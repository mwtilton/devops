#########################################################
#           Powershell PC Info Script V1.0b             #
#              Coded By:Trenton Ivey(kno)               #
#                     hackyeah.com                      #
#########################################################

function Pause ($Message="Press any key to continue..."){
    ""
    Write-Host $Message
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}


function GetCompName{
    $compname = Read-Host "Please enter a computer name or IP"
    CheckHost
}

function CheckHost{
    $ping = gwmi Win32_PingStatus -filter "Address='$compname'"
    if($ping.StatusCode -eq 0){$pcip=$ping.ProtocolAddress; GetMenu}
    else{Pause "Host $compname down...Press any key to continue"; GetCompName}
}



function GetMenu {
    Clear-Host
    "  /----------------------\"
    "  |     PC INFO TOOL     |"
    "  \----------------------/"
    "  $compname ($pcip)"
    ""
    ""
    "1) PC Serial Number"
    "2) PC Printer Info"
    "3) Current User"
    "4) OS Info"
    "5) System Info"
    "6) Add/Remove Program List"
    "7) Process List"
    "8) Service List"
    "9) USB Devices"
    "10) Uptime"
    "11) Disk Space"
    "12) Memory Info"
    "13) Processor Info"
    "14) Monitor Serial Numbers"
    ""
    "C) Change Computer Name"
    "X) Exit The program"
    ""
    $MenuSelection = Read-Host "Enter Selection"
    GetInfo
}


function GetInfo{
    Clear-Host
    switch ($MenuSelection){
        1 { #PC Serial Number
            gwmi -computer $compname Win32_BIOS | Select-Object SerialNumber | Format-List
            Pause
            CheckHost
          }

        2 { #PC Printer Information
            gwmi -computer $compname Win32_Printer | Select-Object DeviceID,DriverName, PortName | Format-List
            Pause
            CheckHost
          }

        3 { #Current User
            gwmi -computer $compname Win32_ComputerSystem | Format-Table @{Expression={$_.Username};Label="Current User"}
            ""
            #May take a very long time if on a domain with many users
            #"All Users"
            #"------------"
            #gwmi -computer $compname Win32_UserAccount | foreach{$_.Caption}
            Pause
            CheckHost
          }

        4 { #OS Info
            gwmi -computer $compname Win32_OperatingSystem | Format-List @{Expression={$_.Caption};Label="OS Name"},SerialNumber,OSArchitecture
            Pause
            CheckHost
          }

        5 { #System Info
            gwmi -computer $compname Win32_ComputerSystem | Format-List Name,Domain,Manufacturer,Model,SystemType
            Pause
            CheckHost
          }

        6 { #Add/Remove Program List
            gwmi -computer $compname Win32_Product | Sort-Object Name | Format-Table Name,Vendor,Version
            Pause
            CheckHost
          }

        7 { #Process Listx

            gwmi -computer $compname Win32_Process | Select-Object Caption,Handle | Sort-Object Caption | Format-Table
            Pause
            CheckHost
          }

        8 { #Service List
            gwmi -computer $compname Win32_Service | Select-Object Name,State,Status,StartMode,ProcessID, ExitCode | Sort-Object Name | Format-Table
            Pause
            CheckHost
          }

        9 { #USB Devices
            gwmi -computer $compname Win32_USBControllerDevice | %{[wmi]($_.Dependent)} | Select-Object Caption, Manufacturer, DeviceID | Format-List
            Pause
            CheckHost
          }

        10 { #Uptime
            $wmi = gwmi -computer $compname Win32_OperatingSystem
            $localdatetime = $wmi.ConvertToDateTime($wmi.LocalDateTime)
            $lastbootuptime = $wmi.ConvertToDateTime($wmi.LastBootUpTime)

            "Current Time:      $localdatetime"
            "Last Boot Up Time: $lastbootuptime"

            $uptime = $localdatetime - $lastbootuptime
            ""
            "Uptime: $uptime"
            Pause
            CheckHost
          }
        11 { #Disk Info
            $wmi = gwmi -computer $compname Win32_logicaldisk
            foreach($device in $wmi){
                    Write-Host "Drive: " $device.name
                    Write-Host -NoNewLine "Size: "; "{0:N2}" -f ($device.Size/1Gb) + " Gb"
                    Write-Host -NoNewLine "FreeSpace: "; "{0:N2}" -f ($device.FreeSpace/1Gb) + " Gb"
                    ""
             }
            Pause
            CheckHost
          }
        12 { #Memory Info
            $wmi = gwmi -computer $compname Win32_PhysicalMemory
            foreach($device in $wmi){
                Write-Host "Bank Label:     " $device.BankLabel
                Write-Host "Capacity:       " ($device.Capacity/1MB) "Mb"
                Write-Host "Data Width:     " $device.DataWidth
                Write-Host "Device Locator: " $device.DeviceLocator
                ""
            }
            Pause
            CheckHost
          }
        13 { #Processor Info
            gwmi -computer $compname Win32_Processor | Format-List Caption,Name,Manufacturer,ProcessorId,NumberOfCores,AddressWidth
            Pause
            CheckHost
          }
        14 { #Monitor Info

            #Turn off Error Messages
            $ErrorActionPreference_Backup = $ErrorActionPreference
            $ErrorActionPreference = "SilentlyContinue"


            $keytype=[Microsoft.Win32.RegistryHive]::LocalMachine
            if($reg=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($keytype,$compname)){
                #Create Table To Hold Info
                $montable = New-Object system.Data.DataTable "Monitor Info"
                #Create Columns for Table
                $moncol1 = New-Object system.Data.DataColumn Name,([string])
                $moncol2 = New-Object system.Data.DataColumn Serial,([string])
                $moncol3 = New-Object system.Data.DataColumn Ascii,([string])
                #Add Columns to Table
                $montable.columns.add($moncol1)
                $montable.columns.add($moncol2)
                $montable.columns.add($moncol3)



                $regKey= $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Enum\DISPLAY" )
                $HID = $regkey.GetSubKeyNames()
                foreach($HID_KEY_NAME in $HID){
                    $regKey= $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Enum\\DISPLAY\\$HID_KEY_NAME" )
                    $DID = $regkey.GetSubKeyNames()
                    foreach($DID_KEY_NAME in $DID){
                        $regKey= $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Enum\\DISPLAY\\$HID_KEY_NAME\\$DID_KEY_NAME\\Device Parameters" )
                        $EDID = $regKey.GetValue("EDID")
                        foreach($int in $EDID){
                            $EDID_String = $EDID_String+([char]$int)
                        }
                        #Create new row in table
                        $monrow=$montable.NewRow()

                        #MonitorName
                        $checkstring = [char]0x00 + [char]0x00 + [char]0x00 + [char]0xFC + [char]0x00
                        $matchfound = $EDID_String -match "$checkstring([\w ]+)"
                        if($matchfound){$monrow.Name = [string]$matches[1]} else {$monrow.Name = '-'}


                        #Serial Number
                        $checkstring = [char]0x00 + [char]0x00 + [char]0x00 + [char]0xFF + [char]0x00
                        $matchfound =  $EDID_String -match "$checkstring(\S+)"
                        if($matchfound){$monrow.Serial = [string]$matches[1]} else {$monrow.Serial = '-'}

                        #AsciiString
                        $checkstring = [char]0x00 + [char]0x00 + [char]0x00 + [char]0xFE + [char]0x00
                        $matchfound = $EDID_String -match "$checkstring([\w ]+)"
                        if($matchfound){$monrow.Ascii = [string]$matches[1]} else {$monrow.Ascii = '-'}


                        $EDID_String = ''

                        $montable.Rows.Add($monrow)
                    }
                }
                $montable | select-object  -unique Serial,Name,Ascii | Where-Object {$_.Serial -ne "-"} | Format-Table
            } else {
                Write-Host "Access Denied - Check Permissions"
            }
            $ErrorActionPreference = $ErrorActionPreference_Backup #Reset Error Messages
            Pause
            CheckHost
          }
        1337 { Write-Host "Program Made By Trenton Ivey (Trenton@hackyeah.com)";Pause; CheckHost}
        c {Clear-Host;$compname="";GetCompName}
        x {Clear-Host; exit}
        default{CheckHost}
      }
}

#---------Start Main--------------
$compname = $args[0]
if($compname){CheckHost}
else{GetCompName}


Function Get-ComputerInfo
{
<#
.SYNOPSIS
        This function will collect various data elements from a local or remote computer.
.DESCRIPTION
        This function was inspired by Get-ServerInfo a custom function written by Jason Walker
        and the PSInfo Sysinternals Tool written by Mark Russinovich.  It will collect a plethora
        of data elements that are important to a Microsoft Windows System Administrator.  The
        function will run locally, run without the -ComputerName Parameter, or connect remotely
        via the -ComputerName Parameter.  This function will return objects that you can interact
        with, however, due to the fact that multiple custom objects are returned, when piping the
        function to Get-Member, it will only display the first object, unless you run the following;
        "Get-ComputerInfo | Foreach-Object {$_ | Get-Member}".  This function is currently in beta.
        Also remember that you have to dot source the ".ps1" file in order to load it into your
        current PowerShell console: ". .\Get-ComputerInfo.ps1"  Then it can be run as a "cmdlet"
        aka "function".  Reminder: In it's current state, this function's output is intended for
        the console, in other words the data does not export very well, unless the Foreach-Object
        technique is used above.  This is something that may come in a future release or a simplied
        version.
.PARAMETER ComputerName
        A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME).
.EXAMPLE
        PS D:\> Get-ComputerInfo -ComputerName LAP01

        Computer            : LAP01
        Domain              : WILHITE.DS
        OperatingSystem     : Microsoft Windows 8 Enterprise
        OSArchitecture      : 64-bit
        BuildNumber         : 9200
        ServicePack         : 0
        Manufacturer        : Microsoft Corporation
        Model               : Virtual Machine
        SerialNumber        : 123456789
        Processor           : Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz
        LogicalProcessors   : 2
        PhysicalMemory      : 8192
        OSReportedMemory    : 8187
        PAEEnabled          : False
        InstallDate         : 8/16/2012 7:44:31 PM
        LastBootUpTime      : 3/6/2013 8:44:57 AM
        UpTime              : 04:32:17.1965808
        RebootPending       : False
        RebootPendingKey    : False
        CBSRebootPending    : False
        WinUpdRebootPending : False

        NetAdapterName  : Microsoft Virtual Machine Bus Network Adapter
        NICManufacturer : Microsoft
        DHCPEnabled     : False
        MACAddress      : 00:15:5D:01:05:5D
        IPAddress       : {10.1.1.22}
        IPSubnetMask    : {255.255.255.0}
        DefaultGateway  : {10.1.1.1}
        DNSServerOrder  : {10.1.1.10, 10.1.1.11}
        DNSSuffixSearch : {wilhite.ds}
        PhysicalAdapter : True
        Speed           : 10000 Mbit

        DeviceID    : C:
        VolumeName  : OS
        VolumeDirty : False
        Size        : 24.90 GB
        FreeSpace   : 14.21 GB
        PercentFree : 57.05 %

        DeviceID    : D:
        VolumeName  : Data
        VolumeDirty : False
        Size        : 100.00 GB
        FreeSpace   : 61.66 GB
        PercentFree : 61.66 %
.LINK
        Registry Class
        http://msdn.microsoft.com/en-us/library/microsoft.win32.registry.aspx

        Win32_BIOS
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394077(v=vs.85).aspx

        Win32_ComputerSystem
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394102(v=vs.85).aspx

        Win32_OperatingSystem
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394239(v=vs.85).aspx

        Win32_NetworkAdapter
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394216(v=vs.85).aspx

        Win32_NetworkAdapterConfiguration
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394217(v=vs.85).aspx

        Win32_Processor
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394373(v=vs.85).aspx

        Win32_PhysicalMemory
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394347(v=vs.85).aspx

        Win32_LogicalDisk
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394173(v=vs.85).aspx

        Component-Based Servicing
        http://technet.microsoft.com/en-us/library/cc756291(v=WS.10).aspx

        PendingFileRename/Auto Update:
        http://support.microsoft.com/kb/2723674
        http://technet.microsoft.com/en-us/library/cc960241.aspx
        http://blogs.msdn.com/b/hansr/archive/2006/02/17/patchreboot.aspx

        SCCM 2012/CCM_ClientSDK:
        http://msdn.microsoft.com/en-us/library/jj902723.aspx


#>

[CmdletBinding()]
param(
  [Parameter(Position=0,ValueFromPipeline=$true)]
  [Alias("CN","Computer")]
  [String[]]$ComputerName="$env:COMPUTERNAME"
  )

Begin
  {
    $i=0
    #Adjusting ErrorActionPreference to stop on all errors
    $TempErrAct = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    #Defining $CompInfo Select Properties For Correct Display Order
    $CompInfoSelProp = @(
      "Computer"
      "Domain"
      "OperatingSystem"
      "OSArchitecture"
      "BuildNumber"
      "ServicePack"
      "Manufacturer"
      "Model"
      "SerialNumber"
      "Processor"
      "LogicalProcessors"
      "PhysicalMemory"
      "OSReportedMemory"
      "PAEEnabled"
      "InstallDate"
      "LastBootUpTime"
      "UpTime"
      "RebootPending"
      "RebootPendingKey"
      "CBSRebootPending"
            "WinUpdRebootPending"
      )#End $CompInfoSelProp

    #Defining $NetInfo Select Properties For Correct Display Order
    $NetInfoSelProp = @(
      "NICName"
      "NICManufacturer"
      "DHCPEnabled"
      "MACAddress"
      "IPAddress"
      "IPSubnetMask"
      "DefaultGateway"
      "DNSServerOrder"
      "DNSSuffixSearch"
      "PhysicalAdapter"
      "Speed"
      )#End $NetInfoSelProp

    #Defining $VolInfo Select Properties For Correct Display Order
    $VolInfoSelProp = @(
      "DeviceID"
      "VolumeName"
      "VolumeDirty"
      "Size"
      "FreeSpace"
      "PercentFree"
      )#End $VolInfoSelProp

  }#End Begin Script Block

Process
  {
    Foreach ($Computer in $ComputerName)
      {
        Try
          {
            If ($ComputerName.Count -gt 1)
              {
                #Setting up Main Write-Progress Process, If Querying More Than 1 Computer.
                $WriteProgParams = @{
                  Id=1
                  Activity="Processing Get-ComputerInfo For $Computer"
                  Status="Percent Complete: $([int]($i/($ComputerName.Count)*100))%"
                  PercentComplete=[int]($i++/($ComputerName.Count)*100)
                  }#End $WriteProgParam Hashtable
                Write-Progress @WriteProgParams
              }#End If ($ComputerName.Count -gt 1)

            #Gathering WMI Data
            $n,$d = 0,8
            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_Processor" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++
            $WMI_PROC = Get-WmiObject -Class Win32_Processor -ComputerName $Computer

            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_BIOS" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++
            $WMI_BIOS = Get-WmiObject -Class Win32_BIOS -ComputerName $Computer

            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_ComputerSystem" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++
            $WMI_CS = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computer

            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_OperatingSystem" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++
            $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer

            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_PhysicalMemory" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++
            $WMI_PM = Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $Computer

            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_LogicalDisk" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++
            $WMI_LD = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = '3'" -ComputerName $Computer

            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_NetworkAdapter" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++
            $WMI_NA = Get-WmiObject -Class Win32_NetworkAdapter -ComputerName $Computer

            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_NetworkAdapter" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++
            $WMI_NAC = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=$true" -ComputerName $Computer

            #Connecting to the Registry to determine PendingReboot status.
            Write-Progress -ParentId 1 -Activity "Collecting Data: Registry Query" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++
            $RegCon = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"LocalMachine",$Computer)

            #If Windows Vista & Above, CBS Will Not Write To The PFRO Reg Key, Query CBS Key For "RebootPending" Key.
            #Also, since there are properties that are exclusive to 2K8+ marking "Unaval" for computers below 2K8.
            $WinBuild = $WMI_OS.BuildNumber
                        $CBSRebootPend,$RebootPending = $false,$false
            If ($WinBuild -ge 6001)
              {
                #Querying the Component Based Servicing reg key for pending reboot status.
                $RegSubKeysCBS  = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\").GetSubKeyNames()
                $CBSRebootPend  = $RegSubKeysCBS -contains "RebootPending"

                #Values that are present in 2K8+
                $OSArchitecture = $WMI_OS.OSArchitecture
                $LogicalProcs   = $WMI_CS.NumberOfLogicalProcessors

              }#End If ($WinBuild -ge 6001)
            Else
              {
                #Win32_OperatingSystem does not have a value for OSArch in 2K3 & Below
                $OSArchitecture = "**Unavailable**"

                #In order to gather processor count for 2K3 & Below, Win32_Processor Instance Count is needed.
                If ($WMI_PROC.Count -gt 1)
                  {
                    $LogicalProcs = $WMI_PROC.Count
                  }#End If ($WMI_PROC.Count -gt 1)
                Else
                  {
                    $LogicalProcs = 1
                  }#End Else

              }#End Else

            #Querying Session Manager for both 2K3 & 2K8 for the PendingFileRenameOperations REG_MULTI_SZ to set PendingReboot value.
            $RegSubKeySM      = $RegCon.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\")
            $RegValuePFRO     = $RegSubKeySM.GetValue("PendingFileRenameOperations",$false)

            #Querying WindowsUpdate\Auto Update for both 2K3 & 2K8 for "RebootRequired"
            $RegWindowsUpdate = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\").GetSubKeyNames()
            $WUAURebootReq    = $RegWindowsUpdate -contains "RebootRequired"
            $RegCon.Close()

            #Setting the $RebootPending var based on data read from the PendingFileRenameOperations REG_MULTI_SZ and CBS Key.
            If ($CBSRebootPend -or $RegValuePFRO -or $WUAURebootReq)
              {
                $RebootPending = $true
              }#End If ($RegValuePFRO -eq "NoValue")

            #Calculating Memory, Converting InstallDate, LastBootTime, Uptime.
            [int]$Memory  = ($WMI_PM | Measure-Object -Property Capacity -Sum).Sum / 1MB
            $InstallDate  = ([WMI]'').ConvertToDateTime($WMI_OS.InstallDate)
            $LastBootTime = ([WMI]'').ConvertToDateTime($WMI_OS.LastBootUpTime)
            $UpTime       = New-TimeSpan -Start $LastBootTime -End (Get-Date)

            #PAEEnabled is only valid on x86 systems, setting value to false first.
            $PAEEnabled = $false
            If ($WMI_OS.PAEEnabled)
              {
                $PAEEnabled = $true
              }

            #Creating the $CompInfo Object
            New-Object PSObject -Property @{
              Computer            = $WMI_CS.Name
              Domain              = $WMI_CS.Domain.ToUpper()
              OperatingSystem     = $WMI_OS.Caption
              OSArchitecture      = $OSArchitecture
              BuildNumber         = $WinBuild
              ServicePack         = $WMI_OS.ServicePackMajorVersion
              Manufacturer        = $WMI_CS.Manufacturer
              Model               = $WMI_CS.Model
              SerialNumber        = $WMI_BIOS.SerialNumber
              Processor           = ($WMI_PROC | Select-Object -ExpandProperty Name -First 1)
              LogicalProcessors   = $LogicalProcs
              PhysicalMemory      = $Memory
              OSReportedMemory    = [int]$($WMI_CS.TotalPhysicalMemory / 1MB)
              PAEEnabled          = $PAEEnabled
              InstallDate         = $InstallDate
              LastBootUpTime      = $LastBootTime
              UpTime              = $UpTime
              RebootPending       = $RebootPending
              RebootPendingKey    = $RegValuePFRO
              CBSRebootPending    = $CBSRebootPend
                            WinUpdRebootPending = $WUAURebootReq
              } | Select-Object $CompInfoSelProp

            #There may be multiple NICs that have IPAddresses, hence the Foreach loop.
            Foreach ($NAC in $WMI_NAC)
              {
                #Getting properties from $WMI_NA that correlate to the matched Index, this is faster than using $WMI_NAC.GetRelated('Win32_NetworkAdapter').
                $NetAdap = $WMI_NA | Where-Object {$NAC.Index -eq $_.Index}

                #Since there are properties that are exclusive to 2K8+ marking "Unaval" for computers below 2K8.
                If ($WinBuild -ge 6001)
                  {
                    $PhysAdap = $NetAdap.PhysicalAdapter
                    $Speed    = "{0:0} Mbit" -f $($NetAdap.Speed / 1000000)
                  }#End If ($WinBuild -ge 6000)
                Else
                  {
                    $PhysAdap = "**Unavailable**"
                    $Speed    = "**Unavailable**"
                  }#End Else

                #Creating the $NetInfo Object
                New-Object PSObject -Property @{
                  NICName         = $NetAdap.Name
                  NICManufacturer = $NetAdap.Manufacturer
                  DHCPEnabled     = $NAC.DHCPEnabled
                  MACAddress      = $NAC.MACAddress
                  IPAddress       = $NAC.IPAddress
                  IPSubnetMask    = $NAC.IPSubnet
                  DefaultGateway  = $NAC.DefaultIPGateway
                  DNSServerOrder  = $NAC.DNSServerSearchOrder
                  DNSSuffixSearch = $NAC.DNSDomainSuffixSearchOrder
                  PhysicalAdapter = $PhysAdap
                  Speed           = $Speed
                  } | Select-Object $NetInfoSelProp

              }#End Foreach ($NAC in $WMI_NAC)

            #There may be multiple Volumes, hence the Foreach loop.
            Foreach ($Volume in $WMI_LD)
              {
                #Creating the $VolInfo Object
                New-Object PSObject -Property @{
                  DeviceID    = $Volume.DeviceID
                  VolumeName  = $Volume.VolumeName
                  VolumeDirty = $Volume.VolumeDirty
                  Size        = $("{0:F} GB" -f $($Volume.Size / 1GB))
                  FreeSpace   = $("{0:F} GB" -f $($Volume.FreeSpace / 1GB))
                  PercentFree = $("{0:P}" -f $($Volume.FreeSpace / $Volume.Size))
                  } | Select-Object $VolInfoSelProp

              }#End Foreach ($Volume in $WMI_LD)

          }#End Try

        Catch
          {
            Write-Warning "$_"
          }#End Catch

      }#End Foreach ($Computer in $ComputerName)

  }#End Process

End
  {
    #Resetting ErrorActionPref
    $ErrorActionPreference = $TempErrAct
  }#End End

}#End Function Get-ComputerInfo
