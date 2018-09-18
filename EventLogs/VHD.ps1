#Requires -RunAsAdministrator


# Show an Open File Dialog and return the file selected by the user
Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.SelectedPath = "C:\Windows\System32\WinEvt\logs\"
	$foldername.Description = "Select the location of 'Microsoft-Windows-VHDMP-Operational.evtx' log (\System32\WinEvt\logs\)"
	$foldername.ShowNewFolderButton = $false
	
    if($foldername.ShowDialog() -eq "OK")
		{
        $folder += $foldername.SelectedPath
		 }
	        else  
        {
            Write-Host "(VHD.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}

$F = Get-Folder +"\"
$Folder = $F +"\"
$DesktopPath = ($Env:WinDir+"\System32\winevt\Logs\")

$File = $Folder + "Microsoft-Windows-VHDMP-Operational.evtx"
$e=0
$sw = [Diagnostics.Stopwatch]::StartNew()

Try { 
    Write-Host "(VHD.ps1):" -f Yellow -nonewline; write-host " Selected Event Log: ($File)" -f White 
	$log9 = @(Get-WinEvent -FilterHashtable @{path = $File; ProviderName="Microsoft-Windows-VHDMP"} -ErrorAction Stop)
    }
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog = $log9.toXml()
$Lcount = $xmllog.Count
Write-Host "(VHD.ps1):" -f Yellow -nonewline; write-host " Found: $Lcount entries in Event Log: ($File)" -f White

#Get unique event descriptions for each EventID
$des = foreach ($el in $log9){
            
            [PSCustomObject]@{
                            'Eid'  = $el.id
                            'Desc' = $el.message.Split([Environment]::NewLine)|Select -First 1 
                              }                             }
$des = ($des |Sort-Object -property eid -Unique)        

#Get all the event log entries
$Events9 = foreach ($l in $xmllog) {$e++
			
			#Progress Bar
			write-progress -id 1 -activity "Collecting VHD related entries - $e of $($Lcount)"  -PercentComplete (($e / $Lcount) * 100)		
			
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

            $Opcode =   if($l.Event.System.Opcode -eq 0) {'Win:Info'}
                    elseif($l.Event.System.Opcode -eq 1) {'Win:Start'}
                    elseif($l.Event.System.Opcode -eq 2) {'Win:Stop'}
                    elseif($l.Event.System.Opcode -eq 8) {'Suspend'}
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
            'Level' =              $Level
            'Task' =               $l.Event.System.Task
            'Opcode' =             $Opcode
			'PID' =                ([Convert]::ToInt64(($l.Event.System.Execution.ProcessID),16))
			'ThreadID' =           $l.Event.System.Execution.ThreadID
            'Security UserID' =    $l.Event.System.Security.UserID
            'Vhd Meta Ops' =       if($l.Event.System.EventID -in (50,51)){$l.Event.EventData.Data[0].'#text'}else{}
            'Status'   =           if($l.Event.System.EventID -in (51))   {$l.Event.EventData.Data[2].'#text'}else{}
            'VHD File Name'  =     if($l.Event.System.EventID -in (50,51)){$l.Event.EventData.Data[1].'#text'}
                               elseif($l.Event.System.EventID -in (1,2))  {$l.Event.EventData.Data[0].'#text'}else{} 
            'VHD Disk Number' =    if($l.Event.System.EventID -in (1,2))  {$l.Event.EventData.Data[1].'#text'}else{} 
            'Target VHD Filename' =if($l.Event.System.EventID -in (50))   {$l.Event.EventData.Data[2].'#text'}
                               elseif($l.Event.System.EventID -in (1,2))  {$l.Event.EventData.Data[0].'#text'}else{}
            'Computer' =           $l.Event.System.Computer            
            'Channel' =            $l.Event.System.Channel
            'Version' =            $version
            'Correlation' =        $l.Event.System.Correlation.ActivityID
            'Keywords' =           $l.Event.System.Keywords
			}

	}



function Result{
$Events9
}

$sw.stop()
$t=$sw.Elapsed

# Display Output
Result |Out-GridView -PassThru -Title "Processed $Lcount Microsoft-Windows-VHDMP Events (Event IDs: 1,2,50,51) - in $t"
write-host "Processed $Lcount Microsoft-Windows-VHDMP Events (Event IDs: 1,2,50,51) - in $t" -f white


[gc]::Collect()

