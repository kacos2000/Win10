#Requires -RunAsAdministrator

# Show an Open File Dialog and return the file selected by the user
Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.SelectedPath = "C:\Windows\System32\WinEvt\logs\"
	$foldername.Description = "Select the location of Security.evtx log"
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
$c=1

Try {
	$Event = (Get-WinEvent -FilterHashtable @{path = $File; ID=4616} -ErrorAction Stop)    
	$log = (Get-WinEvent -FilterHashtable @{path = $File; ID=4616})
	}
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog = $log.toXml()

$Events = foreach ($i in $xmllog) {$c++
			Write-Progress -Activity "Collecting event entries with ID = 4616" -Status "Entry $c of $($xmllog.Count))" -PercentComplete (($c / $xmllog.Count)*100)
			$Previous = [DateTime] ($i.Event.EventData.Data[4].'#text')
			$New = [DateTime] ($i.Event.EventData.Data[5].'#text')
						
			# Format output fields
			
			[PSCustomObject]@{ 
			'Time Created' = Get-Date ($i.Event.System.TimeCreated.SystemTime) -format o
			'EventID' = $i.Event.System.EventRecordID
			'PID' = $i.Event.System.Execution.ProcessID
			'ThreadID' = $i.Event.System.Execution.ThreadID
			'User Name' = $i.Event.EventData.Data[1].'#text'
			'SID' = $i.Event.EventData.Data[0].'#text'
			'Domain Name' = $i.Event.EventData.Data[2].'#text'
			'New Time' = Get-Date ($i.Event.EventData.Data[5].'#text') 
			'Previous Time' = Get-Date ($i.Event.EventData.Data[4].'#text') 
			'Change' = ($New - $Previous) 
			'Process Name' = $i.Event.EventData.Data[7].'#text'
			}
	}
			
#Format of the txt filename and path:
$filenameFormat = $env:userprofile + "\desktop\TimeEvents_" + (Get-Date -Format "dd-MM-yyyy_hh-mm") + ".csv"
Write-host "Selected Rows will be saved as: " -f Yellow -nonewline; Write-Host $filenameFormat -f White

#Output results to screen table (and saves selected rows to txt) 		
$Events|Out-GridView -PassThru -Title "$File events related to ID 4616 (The system time was changed)"|Export-Csv -Path $filenameFormat
#notepad $filenameFormat
[gc]::Collect() 
