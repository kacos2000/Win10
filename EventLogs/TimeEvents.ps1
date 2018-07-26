#Requires -RunAsAdministrator

# Show an Open File Dialog and return the file selected by the user
Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.SelectedPath = "C:\Windows\System32\WinEvt\logs\"
	$foldername.Description = "Select the location of Security.evtx log (\System32\WinEvt\logs\)"
	$foldername.ShowNewFolderButton = $false
	
    if($foldername.ShowDialog() -eq "OK")
		{
        $folder += $foldername.SelectedPath
		 }
	        else  
        {
            Write-Host "(TimeEvents.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}

$F = Get-Folder +"\"
$Folder = $F +"\"

$DesktopPath = ($Env:WinDir+"\System32\winevt\Logs\")

$File = $Folder + "security.evtx"
Write-Host "(TimeEvents.ps1):" -f Yellow -nonewline; write-host " Selected Event Log: ($File)" -f White
$c = 0

Try {   
	$log = (Get-WinEvent -FilterHashtable @{path = $File; ID=4616} -ErrorAction Stop) 
    Write-Host "(TimeEvents.ps1):" -f Yellow -nonewline; write-host " Selected Security Event Log: ($File)" -f White
	}
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog = $log.toXml()
$count = $xmllog.Count

$Events = foreach ($i in $xmllog) {$c++
			
			$Previous = [DateTime] ($i.Event.EventData.Data[4].'#text')
			$New = [DateTime] ($i.Event.EventData.Data[5].'#text')
            $version = if ($l.Event.System.Version -eq 0){Windows Server 2008, Windows Vista}
                        elseif($l.Event.System.Version -eq 01){Windows Server 2012, Windows 8}
                        else {$l.Event.System.Version}

                         
            $Level = if ($p.Event.System.Level -eq 0 ){"Undefined"}
                        elseif($p.Event.System.Level -eq 1){"Critical"}
                        elseif($p.Event.System.Level -eq 2){"Error"}
                        elseif($p.Event.System.Level -eq 3){"Warning"}
                        elseif($p.Event.System.Level -eq 4){"Information"}
                        elseif($p.Event.System.Level -eq 5){"Verbose"}
			
			#Progress Bar
			write-progress -activity "Collecting entries with EventID=4616 - $c of $count)"  -PercentComplete (($c / $count) * 100)		
			# Format output fields
			
			[PSCustomObject]@{ 
			'Time Created' =  Get-Date ($i.Event.System.TimeCreated.SystemTime) -format o
			'EventID' =       $i.Event.System.EventRecordID
			'Level' =         $Level
            'PID' =           [Convert]::ToInt64(($i.Event.System.Execution.ProcessID),16) 
			'ThreadID' =      $i.Event.System.Execution.ThreadID
            'LogonID' =       $i.Event.EventData.Data[6].'#text'
			'User Name' =     $i.Event.EventData.Data[1].'#text'
			'SID' =           $i.Event.EventData.Data[0].'#text'
			'Domain Name' =   $i.Event.EventData.Data[2].'#text'
			'New Time' =      Get-Date ($i.Event.EventData.Data[5].'#text') 
			'Previous Time' = Get-Date ($i.Event.EventData.Data[4].'#text') 
			'Change' =        ($New - $Previous) 
			'Process Name' =  $i.Event.EventData.Data[7].'#text'
			}

	}
			
#Format of the txt filename and path:
$filenameFormat = $env:userprofile + "\desktop\TimeEvents_" + (Get-Date -Format "dd-MM-yyyy_hh-mm") + ".csv"
Write-host "Selected Rows will be saved as: " -f Yellow -nonewline; Write-Host $filenameFormat -f White

#Output results to screen table (and saves selected rows to txt) 		
$Events|Out-GridView -PassThru -Title "A total of $count entries were found with EventID=4616 (The system time was changed) in $File "|Export-Csv -Path $filenameFormat
#notepad $filenameFormat
[gc]::Collect() 
