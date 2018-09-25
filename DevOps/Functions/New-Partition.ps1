Function New-Partition {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $csv # Path of the GPO GUID Folder under the main Backup Folder
    )
    NEW-ITEM â€“name listdisk.txt â€“itemtype file â€“force | OUT-NULL
    ADD-CONTENT â€“path listdisk.txt â€œLIST DISKâ€
    $LISTDISK=(DISKPART /S LISTDISK.TXT)
    $DiskID=$LISTDISK[-1].substring(7,5)
    $DiskID=$LISTDISK[-1].substring(7,5).trim()
    $SIZE=$LISTDISK[-1].substring(25,9)
    $SIZE=$LISTDISK[-1].substring(25,9).replace(" ","")
    NEW-ITEM -Name detail.txt -ItemType file -force | OUT-NULL

    ADD-CONTENT -Path detail.txt "SELECT DISK $DISKID"

    ADD-CONTENT -Path detail.txt "DETAIL DISK"

    $DETAIL=(DISKPART /S DETAIL.TXT)
    $TYPE=$DETAIL[10].substring(9).trim()
    $DRIVELETTER=$DETAIL[-1].substring(15,1)
    $MODEL=$DETAIL[8]
    $LENGTH=$SIZE.length
    $MULTIPLIER=$SIZE.substring($length-2,2)
    $INTSIZE=$SIZE.substring(0,$length-2)
    SWITCH($MULTIPLIER){
        KB { $MULT = 1KB }
        MB { $MULT = 1MB }
        GB { $MULT = 1GB }
    }
    $DISKTOTAL=([convert]::ToInt16($intsize,10))*$MULT
<#
    NEW-ITEM â€“name listdisk.txt â€“itemtype file â€“force | OUT-NULL
    ADD-CONTENT â€“path listdisk.txt â€œLIST DISKâ€
    $LISTDISK=(DISKPART /S LISTTDISK.TXT)
    $TOTALDISK=($LISTDISK.Count)-9

    for ($d=0;$d -le $TOTALDISK;$d++)
    {

        $SIZE=$LISTDISK[-1-$d].substring(25,9).replace(" ","")
        $DISKID=$LISTDISK[-1-$d].substring(7,5).trim()

        NEW-ITEM -Name detail.txt -ItemType file -force | OUT-NULL
        ADD-CONTENT -Path detail.txt "SELECT DISK $DISKID"
        ADD-CONTENT -Path detail.txt "DETAIL DISK"
        $DETAIL=(DISKPART /S DETAIL.TXT)

        $MODEL=$DETAIL[8]
        $TYPE=$DETAIL[10].substring(9)
        $DRIVELETTER=$DETAIL[-1].substring(15,1)

        $LENGTH=$SIZE.length
        $MULTIPLIER=$SIZE.substring($length-2,2)
        $INTSIZE=$SIZE.substring(0,$length-2)

        SWITCH($MULTIPLIER)
        {
            KB { $MULT = 1KB }
            MB { $MULT = 1MB }
            GB { $MULT = 1GB }
        }

        $DISKTOTAL=([convert]::ToInt16($INTSIZE,10))*$MULT

        [pscustomobject]@{DiskNum=$DISKID;Model=$MODEL;Type=$TYPE;DiskSize=$DISKTOTAL;DriveLetter=$DRIVELETTER}
    }

#>

}
