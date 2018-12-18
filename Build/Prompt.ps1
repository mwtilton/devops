function prompt {

    $up = 0x25b2 -as [char]
    $down = 0x25bc -as [char]

    Try {
        Get-Variable -Name testHash -Scope global -ErrorAction Stop | Out-Null
    }
    catch {
         #create the runspace and synchronized hashtable
        $global:testHash = [hashtable]::Synchronized(@{HostComputer = $env:computername;results = ""; date= (Get-Date)})
        $newRunspace = [runspacefactory]::CreateRunspace()
        #set apartment state if available
        if ($newRunspace.ApartmentState) {
            $newRunspace.ApartmentState = "STA"
        }
        $newRunspace.ThreadOptions = "ReuseThread"
        $newRunspace.Open()
        $newRunspace.SessionStateProxy.SetVariable("testHash", $testHash)

        $pscmd = [PowerShell]::Create().AddScript( {
                #define the list of computers to test
                $computers = "$env:computername",""

                do {
                    $results = $computers | ForEach-Object {
                        [pscustomobject]@{
                            HostComputer = $_.toupper()
                            Responding   = Test-WSMan -ComputerName $_
                        }
                    }

                    $global:testHash.results = $results
                    $global:testHash.date = Get-Date
                    #set a sleep interval between tests
                    Start-Sleep -Seconds 5
                } while ($True)

            })

        $pscmd.runspace = $newrunspace
        [void]$psCmd.BeginInvoke()

    } #catch
    Write-Host "[" -NoNewline
    Write-Host $(Get-date).ToString("HH:mm:ss") -ForegroundColor DarkGreen -NoNewline
    $global:testHash.results.foreach( {
            Write-Host $_.HostComputer -NoNewline
            if ($_.responding) {
                Write-Host $up -ForegroundColor green -NoNewline
            }
            else {
                Write-Host $down -ForegroundColor red -NoNewline
            }
        })

    Write-Host "] " -ForegroundColor DarkGray -NoNewline

    "$($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
}