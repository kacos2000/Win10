#Requires -RunAsAdministrator

#References: 
# https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4634
# https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4647
#
# 4634: This event shows that logon session was terminated and no longer exists.
# 4647: This event is generated when a logoff is initiated. No further user-initiated activity can occur. 
# This event can be interpreted as a logoff event.
#               
# The subject fields indicate the account on the local system which requested the logon. This is most commonly a service such as the 
# Server service, or a local process such as Winlogon.exe or Services.exe.
#               
# The main difference between “4647: User initiated logoff.” and 4634 event is that 4647 event 
# is generated when logoff procedure was initiated by specific account using logoff function, 
# and 4634 event shows that session was terminated and no longer exists.
# 4647 is more typical for Interactive and RemoteInteractive logon types when user was logged off using standard methods. 
# You will typically see both 4647 and 4634 events when logoff procedure was initiated by user.
# It may be positively correlated with a “4624: An account was successfully logged on.” event using 
# the Logon ID value. Logon IDs are only unique between reboots on the same computer.
#
# https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
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
            Write-Host "(LogoffEvents.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}

$F = Get-Folder +"\"
$Folder = $F +"\"
$DesktopPath = ($Env:WinDir+"\System32\winevt\Logs\")

$File = $Folder + "Security.evtx"
$e=0
$sw = [Diagnostics.Stopwatch]::StartNew()

Try { 
    Write-Host "(LogOffEvents.ps1):" -f Yellow -nonewline; write-host " Selected Security Event Log: ($File)" -f White 
	$log2 = (Get-WinEvent -FilterHashtable @{path = $File; ProviderName="Microsoft-Windows-Security-Auditing" ; ID=4634,4647} -ErrorAction Stop)
    }
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog2 = $log2.toXml()
$Lcount = $xmllog2.Count
Write-Host "(LogoffEvents.ps1):" -f Yellow -nonewline; write-host " Found: $Lcount entries in Event Log: ($File)" -f White


$Events2 = foreach ($l in $xmllog2) {$e++
			
			#Progress Bar
			write-progress -id 1 -activity "Collecting Security entries with EventIDs 4634 and 4647 - $e of $($Lcount)"  -PercentComplete (($e / $Lcount) * 100)		
			
			# Format output fields
            $version =     if ($l.Event.System.Version -eq 0){"Windows Server 2008, Windows Vista - Win10"}
                          else{$l.Event.System.Version}
            $LogonType =   if ($l.Event.EventData.Data[4].'#text' -eq 2){"Interactive"}
                        elseif($l.Event.EventData.Data[4].'#text' -eq 3){"Network"}
                        elseif($l.Event.EventData.Data[4].'#text' -eq 4){"Batch"}
                        elseif($l.Event.EventData.Data[4].'#text' -eq 5){"Service"}
                        elseif($l.Event.EventData.Data[4].'#text' -eq 7){"Unlock"}
                        elseif($l.Event.EventData.Data[4].'#text' -eq 8){"NetworkCleartext"}
                        elseif($l.Event.EventData.Data[4].'#text' -eq 9){"NewCredentials"}
                        elseif($l.Event.EventData.Data[4].'#text' -eq 10){"RemoteInteractive"}
                        elseif($l.Event.EventData.Data[4].'#text' -eq 11){"CachedInteractive"}
                         else {$l.Event.EventData.Data[4].'#text'}
            
            $Level =       if ($l.Event.System.Level -eq 0){"Undefined"}
                        elseif($l.Event.System.Level -eq 1){"Critical"}
                        elseif($l.Event.System.Level -eq 2){"Error"}
                        elseif($l.Event.System.Level -eq 3){"Warning"}
                        elseif($l.Event.System.Level -eq 4){"Information"}
                        elseif($l.Event.System.Level -eq 5){"Verbose"}

            $Date = (Get-Date ($l.Event.System.TimeCreated.SystemTime) -f o)
			
			[PSCustomObject]@{
 			'EventID' =           $l.Event.System.EventID
            'Time Created' =      $Date  
			'RecordID' =          $l.Event.System.EventRecordID
            'Version' =           $version
            'Level' =             $Level
            'Task' =              $l.Event.System.Task
            'Opcode' =            $l.Event.System.Opcode
			'PID' =               ([Convert]::ToInt64(($l.Event.System.Execution.ProcessID),16))
			'ThreadID' =          $l.Event.System.Execution.ThreadID
            'TargetUserSid' =     $l.Event.EventData.Data[0].'#text' 
            'TargetUserName' =    $l.Event.EventData.Data[1].'#text'
            'TargetDomainName' =  $l.Event.EventData.Data[2].'#text'
            'TargetLogonId' =     $l.Event.EventData.Data[3].'#text'
            'Computer' =          $l.Event.System.Computer            
            'LogonType' =         $LogonType
            'Channel' =           $l.Event.System.Channel
            'Correlation' =       $l.Event.System.Correlation.ActivityID
            'Keywords' =          $l.Event.System.Keywords
			}

	}

function Result{
$Events2
}

$sw.stop()
$t=$sw.Elapsed
Result |Out-GridView -PassThru -Title "Processed $Lcount LogOff Events (IDs 4634, 4647) - in $t"
write-host "Processed $Lcount Log Off Events (IDs 4634, 4647) - in $t" -f white


[gc]::Collect()

