#Requires -RunAsAdministrator

#References: 
# https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4688
# https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
#
#               
# The authentication information fields provide detailed information about this specific logon request.
#    - Logon GUID is a unique identifier that can be used to correlate this event with a KDC event.
#    - Transited services indicate which intermediate services have participated in this logon request.
#    - Package name indicates which sub-protocol was used among the NTLM protocols.
#    - Key length indicates the length of the generated session key. This will be 0 if no session key was requested.
# Critical - Value: 1. Indicates logs for a critical alert.
# Error	- Value: 2. Indicates logs for an error.
# Information - Value: 4. Indicates logs for an informational message.
# Undefined	- Value: 0. Indicates logs at all levels.
# Verbose - Value: 5. Indicates logs at all levels.
# Warning - Value: 3. Indicates logs for a warning.
#
# https://msdn.microsoft.com/en-us/library/microsoft.windowsazure.diagnostics.loglevel.aspx 
# https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.logging.loglevel?view=aspnetcore-2.1
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

#https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4688


#    %%1936  - Type 1 is a full token with no privileges removed or groups disabled.  A full token is only used if User Account Control is disabled or if the user is the built-in Administrator account or a service account.
#    %%1937 - Type 2 is an elevated token with no privileges removed or groups disabled.  An elevated token is used when User Account Control is enabled and the user chooses to start the program using Run as administrator.  An elevated token is also used when an application is configured to always require administrative privilege or to always require maximum privilege, and the user is a member of the Administrators group.
#    %%1938 - Type 3 is the normal value when UAC is enabled and a user simply starts a program from the Start Menu.  It's a limited token with administrative privileges removed and administrative groups disabled.  The limited token is used when User Account Control is enabled, the application does not require administrative privilege, and the user does not choose to start the program using Run as administrator.
#
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
            Write-Host "(4688ProcessEvents.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}

$F = Get-Folder +"\"
$Folder = $F +"\"
$DesktopPath = ($Env:WinDir+"\System32\winevt\Logs\")

$File = $Folder + "Security.evtx"
Write-Host "(LoginEvents.ps1):" -f Yellow -nonewline; write-host " Selected Event Log: ($File)" -f White
$f=0

$sw3 = [Diagnostics.Stopwatch]::StartNew()
Try {  
	$log3 = (Get-WinEvent -FilterHashtable @{path = $File; ProviderName="Microsoft-Windows-Security-Auditing" ; ID=4688} -ErrorAction Stop)
    Write-Host "(LoginEvents.ps1):" -f Yellow -nonewline; write-host " Selected Security Event Log: ($File)" -f White
    }
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog3 = $log3.toXml()
$Procount = $xmllog3.Count
Write-Host "Events found: $Lcount" -f White

$Events3 = foreach ($p in $xmllog3) {$f++
			
			#Progress Bar
			write-progress -id 1 -activity "Collecting Security entries with EventID=4688 - $f of $($xmllog3.Count)"  -PercentComplete (($f / $xmllog3.Count) * 100)		
			
			# Format output fields
            $version = if ($p.Event.System.Version -eq 0){"Windows Server 2008, Windows Vista"}
                        elseif($p.Event.System.Version -eq 01){"Windows Server 2012R2, Windows 8.1"}
                        elseif($p.Event.System.Version -eq 02){"Windows 10"}
            $LogonType = if ($p.Event.EventData.Data[8].'#text' -eq 2 ){"Interactive"}
                        elseif($p.Event.EventData.Data[8].'#text' -eq 3){"Network"}
                        elseif($p.Event.EventData.Data[8].'#text' -eq 4){"Batch"}
                        elseif($p.Event.EventData.Data[8].'#text' -eq 5){"Service"}
                        elseif($p.Event.EventData.Data[8].'#text' -eq 7){"Unlock"}
                        elseif($p.Event.EventData.Data[8].'#text' -eq 8){"NetworkCleartext"}
                        elseif($p.Event.EventData.Data[8].'#text' -eq 9){"NewCredentials"}
                        elseif($p.Event.EventData.Data[8].'#text' -eq 10){"RemoteInteractive"}
                        elseif($p.Event.EventData.Data[8].'#text' -eq 11){"CachedInteractive"}
                            else {$p.Event.EventData.Data[8].'#text'}
            
            $MandatoryLabel = if ($p.Event.EventData.Data[14].'#text' -eq 'S-1-16-0' ){"Untrusted"}
                        elseif($p.Event.EventData.Data[14].'#text' -eq 'S-1-16-4096'){"Low integrity"}
                        elseif($p.Event.EventData.Data[14].'#text' -eq 'S-1-16-8192'){"Medium integrity"}
                        elseif($p.Event.EventData.Data[14].'#text' -eq 'S-1-16-8448'){"Medium high integrity"}
                        elseif($p.Event.EventData.Data[14].'#text' -eq 'S-1-16-12288'){"High integrity"}
                        elseif($p.Event.EventData.Data[14].'#text' -eq 'S-1-16-16384'){"System integrity"}
                        elseif($p.Event.EventData.Data[14].'#text' -eq 'S-1-16-20480'){"Protected process"}
            
            $Level = if ($p.Event.System.Level -eq 0 ){"Undefined"}
                        elseif($p.Event.System.Level -eq 1){"Critical"}
                        elseif($p.Event.System.Level -eq 2){"Error"}
                        elseif($p.Event.System.Level -eq 3){"Warning"}
                        elseif($p.Event.System.Level -eq 4){"Information"}
                        elseif($p.Event.System.Level -eq 5){"Verbose"}


            $ElevatedTokenLevel = if($p.Event.EventData.Data[6].'#text' -eq "%%1936"){"Default (1)"}
                                elseif($p.Event.EventData.Data[6].'#text' -eq "%%1937"){"Full (2)"}
                                elseif($p.Event.EventData.Data[6].'#text' -eq "%%1938"){"Limited (3)"}


            $Date = (Get-Date ($p.Event.System.TimeCreated.SystemTime) -f o)
			
			[PSCustomObject]@{
 			'EventID' =           $p.Event.System.EventID
            'Time Created' =      $Date  
			'RecordID' =          $p.Event.System.EventRecordID
            'Version' =           $version
            'Level' =             $Level
            'Task' =              $p.Event.System.Task
            'Opcode' =            $p.Event.System.Opcode
			'PID' =               [Convert]::ToInt64(($p.Event.System.Execution.ProcessID),16)
			'ThreadID' =          $p.Event.System.Execution.ThreadID
            'Computer' =          $p.Event.System.Computer 
            'NewProcessId'  =     [Convert]::ToInt64(($p.Event.EventData.Data[4].'#text'),16)
            'NewProcessName'=     $p.Event.EventData.Data[5].'#text'
            'TokenElevationType'= $ElevatedTokenLevel 
            'ProcessId' =          [Convert]::ToInt64(($p.Event.EventData.Data[7].'#text'),16)
            'ParentProcessName' = $p.Event.EventData.Data[13].'#text'
            'CommandLine' =       $p.Event.EventData.Data[8].'#text'
            'SubjectUserSid' =    $p.Event.EventData.Data[0].'#text'
            'SubjectUserName' =   $p.Event.EventData.Data[1].'#text' 
            'SubjectDomainName' = $p.Event.EventData.Data[2].'#text' 
            'SubjectLogonId' =    $p.Event.EventData.Data[3].'#text'
            'TargetUserSid' =     $p.Event.EventData.Data[9].'#text' 
            'TargetUserName' =    $p.Event.EventData.Data[10].'#text'
            'TargetDomainName' =  $p.Event.EventData.Data[11].'#text'
            'TargetLogonId' =     $p.Event.EventData.Data[12].'#text'
            'MandatoryLabel' =    $MandatoryLabel
            'Channel' =           $p.Event.System.Channel
            'Correlation' =       $p.Event.System.Correlation
            'Keywords' =          $p.Event.System.Keywords
			}

	}

function Result{
$Events3
}

$sw3.stop()
$t3=$sw3.Elapsed
Result |Out-GridView -PassThru -Title "$Procount - 'Process Created' Events (ID 4688) - Processing Time $t3"
write-host "Elapsed Time $t3 minutes" -f yellow


[gc]::Collect()

