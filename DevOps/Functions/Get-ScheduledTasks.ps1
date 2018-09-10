function Get-ScheduledTasks {
    Params(
        [string]$Path
    )

    $out = @()

    # Get root tasks
    $schedule.GetFolder($path).GetTasks(0) | % {
        $xml = [xml]$_.xml
        $out += New-Object psobject -Property @{
            "Name" = $_.Name
            "Path" = $_.Path
            "LastRunTime" = $_.LastRunTime
            "NextRunTime" = $_.NextRunTime
            "Actions" = ($xml.Task.Actions.Exec | % { "$($_.Command) $($_.Arguments)" }) -join "`n"
        }
    }

    # Get tasks from subfolders
    $schedule.GetFolder($path).GetFolders(0) | % {
        $out += getTasks($_.Path)
    }

    #Output
    $out
}

$tasks = @()

$schedule = New-Object -ComObject "Schedule.Service"
$schedule.Connect()

# Start inventory
$tasks += getTasks("\")

# Close com
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($schedule) | Out-Null
Remove-Variable schedule

# Output all tasks
$tasks

#------------------------------------------------------------------

. \\server\path\to\invoke-parallel.ps1
$Computers = (get-adcomputer -filter {operatingsystem -like "*server*"}).name
$ErrorActionPreference = "SilentlyContinue"
$Scriptblock =
{
    $path = "\\" + $_ + "\c$\Windows\System32\Tasks"
    $tasks = Get-ChildItem -recurse -Path $path -File
    foreach ($task in $tasks)
    {
        $Details = "" | select ComputerName, Task, User, Enabled, Application
        $AbsolutePath = $task.directory.fullname + "\" + $task.Name
        $TaskInfo = [xml](Get-Content $AbsolutePath)
        $Details.ComputerName = $_
        $Details.Task = $task.name
        $Details.User = $TaskInfo.task.principals.principal.userid
        $Details.Enabled = $TaskInfo.task.settings.enabled
        $Details.Application = $TaskInfo.task.actions.exec.command
        $Details
    }
}
$Report = invoke-parallel -input $Computers -scriptblock $Scriptblock -throttle 400 -runspacetimeout 30 -nocloseontimeout
$Report | ft
