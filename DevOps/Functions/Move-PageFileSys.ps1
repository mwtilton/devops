Function Move-PageFileSys {
    $computer = Get-WmiObject Win32_computersystem -EnableAllPrivileges
    $computer.AutomaticManagedPagefile = $false
    $computer.Put()
    $CurrentPageFile = Get-WmiObject -Query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
    $CurrentPageFile.delete()
    Set-WMIInstance -Class Win32_PageFileSetting -Arguments @{name="d:\pagefile.sys";InitialSize = 0; MaximumSize = 0}
}
