#Requires -RunAsAdministrator

#References: 
# (Get-WinEvent -ListProvider "Microsoft-Windows-Security-Auditing").Events|Where-Object {$_.Id -eq 4624}
# https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4648
# https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
#
#               
# This event is generated when a process attempts an account logon by explicitly specifying that account’s credentials.
# This most commonly occurs in batch-type configurations such as scheduled tasks, or when using the “RUNAS” command.
# It is also a routine event which periodically occurs during normal operating system activity.
#               
#
# %%1832 Identification
# %%1833 Impersonation
# %%1840 Delegation
# %%1841 Denied by Process Trust Label ACE
# %%1842 Yes
# %%1843 No
# %%1844 System
# %%1845 Not Available
# %%1846 Default
# %%1847 DisallowMmConfig
# %%1848 Off
# %%1849 Auto
# (https://tinyurl.com/y7gx8578)


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
            Write-Host "(LogonAttempted.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}

$F = Get-Folder +"\"
$Folder = $F +"\"
$DesktopPath = ($Env:WinDir+"\System32\winevt\Logs\")

$File = $Folder + "Security.evtx"
$h=0
$sw7 = [Diagnostics.Stopwatch]::StartNew()

Try { 
    Write-Host "(LogonAttempted.ps1):" -f Yellow -nonewline; write-host " Selected Security Event Log: ($File)" -f White 
	$log7 = (Get-WinEvent -FilterHashtable @{path = $File; ProviderName="Microsoft-Windows-Security-Auditing" ; ID=4648} -ErrorAction Stop)
    }
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog7 = $log7.toXml()
$LAcount = $xmllog7.Count
Write-Host "(LogonAttempted.ps1):" -f Yellow -nonewline; write-host " Found: $LAcount in Event Log: ($File)" -f White


$Events7 = foreach ($la in $xmllog7) {$h++
			
			#Progress Bar
			write-progress -id 1 -activity "Collecting Security entries with EventID=4648 - $h of $($LAcount)"  -PercentComplete (($h / $LAcount) * 100)		
			
			# Format output fields
            $version = if ($la.Event.System.Version -eq 0){"Windows Server 2008, Windows Vista"}
                        elseif($la.Event.System.Version -eq 01){"Windows Server 2012, Windows 8"}
                        elseif($la.Event.System.Version -eq 02){"Windows 10"}
             
            $Level = if ($la.Event.System.Level -eq 0 ){"Undefined"}
                        elseif($la.Event.System.Level -eq 1){"Critical"}
                        elseif($la.Event.System.Level -eq 2){"Error"}
                        elseif($la.Event.System.Level -eq 3){"Warning"}
                        elseif($la.Event.System.Level -eq 4){"Information"}
                        elseif($la.Event.System.Level -eq 5){"Verbose"}

            $Date = (Get-Date ($la.Event.System.TimeCreated.SystemTime) -f o)
			
			[PSCustomObject]@{
 			'EventID' =           $la.Event.System.EventID
            'Time Created' =      $Date  
			'RecordID' =          $la.Event.System.EventRecordID
            'Version' =           $version
            'Level' =             $Level
            'Task' =              $la.Event.System.Task
            'Opcode' =            $la.Event.System.Opcode
			'PID' =               ([Convert]::ToInt64(($la.Event.System.Execution.ProcessID),16)) 
			'ThreadID' =          $la.Event.System.Execution.ThreadID
            'User Name' =         $la.Event.EventData.Data[1].'#text'
            'ExecutionPID'   =    $la.Event.System.Execution.ProcessID
            'Computer' =          $la.Event.System.Computer
            'SID' =               $la.Event.EventData.Data[0].'#text' 
            'SubjectUserName' =   $la.Event.EventData.Data[1].'#text' 
            'SubjectDomainName' = $la.Event.EventData.Data[2].'#text' 
            'SubjectLogonId' =    $la.Event.EventData.Data[3].'#text'
            'LogonGuid' =         $la.Event.EventData.Data[4].'#text'
            'TargetUserName' =    $la.Event.EventData.Data[5].'#text'
            'TargetDomainName' =  $la.Event.EventData.Data[6].'#text'
            'TargetLogonGuid' =   $la.Event.EventData.Data[7].'#text'
            'TargetServerName' =  $la.Event.EventData.Data[8].'#text' 
            'TargetInfo' =        $la.Event.EventData.Data[9].'#text'
            'ProcessId' =         ([Convert]::ToInt64(($la.Event.EventData.Data[10].'#text'),16)) 
            'ProcessName' =       $la.Event.EventData.Data[11].'#text'
            'IpAddress' =         $la.Event.EventData.Data[12].'#text'
            'IpPort' =            $la.Event.EventData.Data[13].'#text'
            'Channel' =            $la.Event.System.Channel
            'Keywords' =           $la.Event.System.Keywords
			}

	}

function Result{
$Events7
}

$sw7.stop()
$t7=$sw7.Elapsed
Result |Out-GridView -PassThru -Title "Processed $LAcount Logon Attempted Events (ID 4648) - in $t7"
write-host "Processed $LAcount Logon Attempted Events (ID 4648) - in $t7" -f white


[gc]::Collect()

