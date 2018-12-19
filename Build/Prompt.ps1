Import-Module posh-git -Force

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
                $computers = "srv1","srv2"

                do {
                    $results = $computers | ForEach-Object {
                        [pscustomobject]@{
                            HostComputer = $_.toupper()
                            Responding   = Test-Connection -ComputerName $_ -Count 1 -quiet
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
    Write-Host "[ "
    Write-Host "  "$(Get-date).ToString("HH:mm:ss") -ForegroundColor Magenta
    $global:testHash.results.foreach( {
            if ($_.responding) {
                Write-Host "  [" -ForegroundColor DarkGreen -NoNewline
                Write-Host "$up" -ForegroundColor Green -NoNewline
                Write-Host "] " -ForegroundColor DarkGreen -NoNewline
                Write-Host $_.HostComputer -ForegroundColor White
            }
            else {
                Write-Host "    [" -ForegroundColor DarkRed -NoNewline
                Write-host $down -ForegroundColor red -NoNewline
                Write-Host "] " -ForegroundColor DarkRed -NoNewline
                Write-Host $_.HostComputer -ForegroundColor Red
            }

        })

    Write-Host "] " -ForegroundColor DarkGray

    $GitPromptSettings.DefaultPromptSuffix = "> "
    $prompt = & $GitPromptScriptBlock
    "$prompt"
}