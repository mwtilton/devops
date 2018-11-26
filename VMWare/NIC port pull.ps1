#####################################
 ## http://kunaludapi.blogspot.com
 ## Version: 1
 ##
 ## Tested this script on
 ## 1) Powershell v3
 ## 2) Powercli v5.5
 ## 3) Vsphere 5.x
 #####################################
Add-PSSnapin VMware.VimAutomation.core
Add-PSSnapin VMware.VimAutomation.Vds
 $vCenterCred = Get-Credential -Message "vCenter server or esxi credentials"
 $vcenterServer = "10.20.0.4"
 #myvcloud.scalematrix.com
 Connect-viServer -server $vcenterServer -Credential $vCenterCred
 $Collection = @()
 $Esxihosts = Get-VMHost 10.20.7.* #| Where-Object {$_.ConnectionState -eq "Connected"}


 foreach ($Esxihost in $Esxihosts) {
  $Esxcli = Get-EsxCli -VMHost $Esxihost
  $Esxihostview = Get-VMHost $EsxiHost | Get-View
  $NetworkSystem = $Esxihostview.Configmanager.Networksystem
  $Networkview = Get-View $NetworkSystem
  $DvSwitchInfo = Get-VDSwitch -VMHost $Esxihost
  if ($DvSwitchInfo -ne $null) {
     $DvSwitchHost = $DvSwitchInfo.ExtensionData.Config.Host
     $DvSwitchHostView = Get-View $DvSwitchHost.config.host
     $VMhostnic = $DvSwitchHostView.config.network.pnic
     $DVNic = $DvSwitchHost.config.backing.PnicSpec.PnicDevice
  }
  $VMnics = $Esxihost | get-vmhostnetworkadapter -Physical  #$_.NetworkInfo.Pnic
  Foreach ($VMnic in $VMnics){
    $realInfo = $Networkview.QueryNetworkHint($VMnic)
    $pNics = $esxcli.network.nic.list() | where-object {$vmnic.name -eq $_.name} | Select-Object Description, Link
    $Description = $esxcli.network.nic.list()
    if ($vmnic.Name -eq $DVNic) {
      $vSwitch = $DVswitchInfo | where-object {$DVNic -match $vmnic.Name} | select-object -ExpandProperty Name
    }
    else {
      $vSwitchname = $Esxihost | Get-VirtualSwitch | Where-object {$_.nic -eq $VMnic.DeviceName}
      $vSwitch = $vSwitchname.name
    }
    if ($realInfo.lldpinfo -ne $null) {
      $LLDPinfo = $realInfo.lldpinfo
      $SwitchName = $realInfo.lldpinfo.Parameter | Where-Object {$_.Key -eq "System Name"} | Select-Object -ExpandProperty Value
      $SwitchPortVlanID = $realInfo.lldpinfo.Parameter | Where-Object {$_.Key -eq "Vlan ID"} | Select-Object -ExpandProperty Value
      $SwitchPortMTU = $realInfo.lldpinfo.Parameter | Where-Object {$_.Key -eq "MTU"} | Select-Object -ExpandProperty Value
      $SwitchDesc = $realInfo.lldpinfo.Parameter | Where-Object {$_.Key -eq "Port Description"} | Select-Object -ExpandProperty Value
      $Table = New-Object PSObject
      $Table | Add-Member -Name EsxName -Value $esxihost.Name -MemberType NoteProperty
      $Table | Add-Member -Name VMNic -Value $VMnic -MemberType NoteProperty
      $Table | Add-Member -Name vSwitch -Value $vSwitch -MemberType NoteProperty
      $Table | Add-Member -Name Link -Value $pNics.Link -MemberType NoteProperty
      $Table | Add-Member -Name PortNo -Value $LLDPinfo.PortId -MemberType NoteProperty
      $Table | Add-Member -Name SwitchName -Value $SwitchName -MemberType NoteProperty
      $Table | Add-Member -Name SwitchDesc -Value $SwitchDesc -MemberType NoteProperty
      $Table | Add-Member -Name MacAddress -Value $vmnic.Mac -MemberType NoteProperty
      $Table | Add-Member -Name SpeedMB -Value $vmnic.ExtensionData.LinkSpeed.SpeedMB -MemberType NoteProperty
      $Table | Add-Member -Name Duplex -Value $vmnic.ExtensionData.LinkSpeed.Duplex -MemberType NoteProperty
      $Table | Add-Member -Name Pnic-Vendor -Value $pNics.Description -MemberType NoteProperty
      $Table | Add-Member -Name PCI-Slot -Value $vmnic.ExtensionData.Pci -MemberType NoteProperty
      $collection += $Table
    }

  }
 }
 $Collection | Sort-Object esxname, vmnic | ft *
 Disconnect-VIserver * -confirm:$false