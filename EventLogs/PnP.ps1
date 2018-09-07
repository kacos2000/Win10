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
            Write-Host "(pnp.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}

$F = Get-Folder +"\"
$Folder = $F +"\"
$DesktopPath = ($Env:WinDir+"\System32\winevt\Logs\")

$File = $Folder + "Microsoft-Windows-Kernel-PnP%4Configuration.evtx"
$e=0
$sw = [Diagnostics.Stopwatch]::StartNew()

Try { 
    Write-Host "(PnP.ps1):" -f Yellow -nonewline; write-host " Selected Event Log: ($File)" -f White 
	$log2 = @(Get-WinEvent -FilterHashtable @{path = $File; ProviderName="Microsoft-Windows-Kernel-PnP"} -ErrorAction Stop)
    }
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog2 = $log2.toXml()
$Lcount = $xmllog2.Count
Write-Host "(PnP.ps1):" -f Yellow -nonewline; write-host " Found: $Lcount entries in Event Log: ($File)" -f White

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
                    elseif($l.Event.System.Opcode -eq 10){'QueryStart'}
                    elseif($l.Event.System.Opcode -eq 11){'QueryStop'}
                    elseif($l.Event.System.Opcode -eq 12){'ProcessingStart'}
                    elseif($l.Event.System.Opcode -eq 13){'ProcessingStop'}
                      else{$l.Event.System.Opcode}

            $Date = (Get-Date ($l.Event.System.TimeCreated.SystemTime) -f o)
			
			[PSCustomObject]@{
 			'EventID' =            $l.Event.System.EventID
            'Description' =        $description
            'Time Created' =       $Date  
			'RecordID' =           $l.Event.System.EventRecordID
            'Version' =            $version
            'Level' =              $Level
            'Task' =               $l.Event.System.Task
            'Opcode' =             $Opcode
			'PID' =                ([Convert]::ToInt64(($l.Event.System.Execution.ProcessID),16))
			'ThreadID' =           $l.Event.System.Execution.ThreadID

			'Device Instance ID' = $l.Event.EventData.Data[0].'#text' 
            'Driver Name' =        $l.Event.EventData.Data[1].'#text' 
            'Class GUID' =         $l.Event.EventData.Data[2].'#text' 
            'Driver Date' =        $l.Event.EventData.Data[3].'#text'
            'Driver Version' =     $l.Event.EventData.Data[4].'#text'
            'Driver Provider' =    $l.Event.EventData.Data[5].'#text'
            'Driver Inbox' =       $l.Event.EventData.Data[6].'#text'
            'Driver Section' =     $l.Event.EventData.Data[7].'#text'
            'Driver Rank' =        $l.Event.EventData.Data[8].'#text'
            'Matching Device ID' = $l.Event.EventData.Data[9].'#text'
            'Outranked Drivers' =  $l.Event.EventData.Data[10].'#text'
            'Device Updated' =     $l.Event.EventData.Data[11].'#text'
            'Status' =             $l.Event.EventData.Data[12].'#text'
            'Computer' =           $l.Event.System.Computer            
            'Channel' =            $l.Event.System.Channel
            'Correlation' =        $l.Event.System.Correlation.ActivityID
            'Keywords' =           $l.Event.System.Keywords
			}

	}



function Result{
$Events2
}

$sw.stop()
$t=$sw.Elapsed

# Display Output
Result |Out-GridView -PassThru -Title "Processed $Lcount Microsoft-Windows-Kernel-PnP Events - in $t"
write-host "Processed $Lcount Microsoft-Windows-Kernel-PnP Events - in $t" -f white


[gc]::Collect()

