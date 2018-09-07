#Requires -RunAsAdministrator


# Show an Open File Dialog and return the file selected by the user
Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.SelectedPath = "C:\Windows\System32\WinEvt\logs\"
	$foldername.Description = "Select the location of 'Microsoft-Windows-Kernel-PnP%4Configuration.evtx' log (\System32\WinEvt\logs\)"
	$foldername.ShowNewFolderButton = $false
	
    if($foldername.ShowDialog() -eq "OK")
		{
        $folder += $foldername.SelectedPath
		 }
	        else  
        {
            Write-Host "(Powershell.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}

$F = Get-Folder +"\"
$Folder = $F +"\"
$DesktopPath = ($Env:WinDir+"\System32\winevt\Logs\")

$File = $Folder + "Microsoft-Windows-PowerShell%4Operational.evtx"
$e=0
$sw = [Diagnostics.Stopwatch]::StartNew()

Try { 
    Write-Host "(Powershell.ps1):" -f Yellow -nonewline; write-host " Selected Event Log: ($File)" -f White 
	$log2 = @(Get-WinEvent -FilterHashtable @{path = $File; ProviderName="Microsoft-Windows-PowerShell"; ID = 40962,40961,24577} -ErrorAction Stop)
    }
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog2 = $log2.toXml()
$Lcount = $xmllog2.Count
Write-Host "(Powershell.ps1):" -f Yellow -nonewline; write-host " Found: $Lcount entries in Event Log: ($File)" -f White

#Get unique event descriptions for each EventID
$des = foreach ($el in $log2){
            
            [PSCustomObject]@{
                            'Eid'  = $el.id
                            'Desc' = $el.message.Split([Environment]::NewLine)|Select -First 1 
                              }                             }
$des = ($des |Sort-Object -property eid -Unique)        

#Get all the event log entries
$Events2 = foreach ($l in $xmllog2) {$e++
			
			#Progress Bar
			write-progress -id 1 -activity "Collecting VolumeSnapshot entries - $e of $($Lcount)"  -PercentComplete (($e / $Lcount) * 100)		
			
            #Get event description
            $description = foreach ($d in $des){if(($l.Event.System.EventID) -in $d.eid){$d.Desc}}
            

			# Format output fields
            $version =     if ($l.Event.System.Version -eq 0){"Windows Server 2008, Windows Vista/Win10"}
                        elseif($l.Event.System.Version -eq 1){"Windows Server 2012, Windows 8/Win10"}
                        elseif($l.Event.System.Version -eq 2){"Windows 10"}
                        
             
            $Level =       if ($l.Event.System.Level -eq 0){"Undefined"}
                        elseif($l.Event.System.Level -eq 1){"Critical"}
                        elseif($l.Event.System.Level -eq 2){"Error"}
                        elseif($l.Event.System.Level -eq 3){"Warning"}
                        elseif($l.Event.System.Level -eq 4){"Information"}
                        elseif($l.Event.System.Level -eq 5){"Verbose"}

            $Opcode =   if($l.Event.System.Opcode -eq 0){'Win:Info'}
                    elseif($l.Event.System.Opcode -eq 1){'Win:Start'}
                    elseif($l.Event.System.Opcode -eq 2){'Win:Stop'}
                    elseif($l.Event.System.Opcode -eq 8){'Suspend'}
                    elseif($l.Event.System.Opcode -eq 10){'Open (Async)'}
                    elseif($l.Event.System.Opcode -eq 11){'Close (Async)'}
                    elseif($l.Event.System.Opcode -eq 12){'Connect'}
                    elseif($l.Event.System.Opcode -eq 13){'Disconnect'}
                    elseif($l.Event.System.Opcode -eq 21){'Send (async)'}
                    elseif($l.Event.System.Opcode -eq 22){'Receive (Async)'}
                    elseif($l.Event.System.Opcode -eq 24){'Serialization Settings'}
                    elseif($l.Event.System.Opcode -eq 23){'Rehydration'}
                    elseif($l.Event.System.Opcode -eq 19){'Exception'}
                    elseif($l.Event.System.Opcode -eq 20){'Method'}
                    elseif($l.Event.System.Opcode -eq 25){'Shutting Down'}
                      else{$l.Event.System.Opcode}

            $Date = (Get-Date ($l.Event.System.TimeCreated.SystemTime) -f o)
			
			[PSCustomObject]@{
 			'EventID' =            $l.Event.System.EventID
            'Time Created' =       $Date  
			'RecordID' =           $l.Event.System.EventRecordID
            'Version' =            $version
            'Level' =              $Level
            'Task' =               $l.Event.System.Task
            'Opcode' =             $Opcode
			'PID' =                ([Convert]::ToInt64(($l.Event.System.Execution.ProcessID),16))
			'ThreadID' =           $l.Event.System.Execution.ThreadID
			'Filename' =           if($l.Event.System.EventID -eq 24577){$l.Event.EventData.Data.'#text' }else{}
            'Computer' =           $l.Event.System.Computer
            'Channel' =            $l.Event.System.Channel
            'Correlation' =        $l.Event.System.Correlation.ActivityID
            'Description' =        $description
            'Keywords' =           $l.Event.System.Keywords
			}

	}



function Result{
$Events2
}

$sw.stop()
$t=$sw.Elapsed

# Display Output
Result |Out-GridView -PassThru -Title "Processed $Lcount Microsoft-Windows-PowerShell Events (40962,40961,24577) - in $t"
write-host "Processed $Lcount Microsoft-Windows-PowerShell Events (40962,40961,24577) - in $t" -f white


[gc]::Collect()

