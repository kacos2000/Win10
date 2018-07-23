#Requires -RunAsAdministrator

#References: 
# https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624
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
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/340632d1-60f0-4cc5-ad6f-f8c841107d0d/translate-value-1833quot-on-impersonationlevel-and-similar-values?forum=winservergen


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

$File = $Folder + "Security.evtx"
Write-Host "(LoginEvents.ps1):" -f Yellow -nonewline; write-host " Selected Event Log: ($File)" -f White
$e=0

$sw = [Diagnostics.Stopwatch]::StartNew()
Try {  
	$log2 = Get-WinEvent -FilterHashtable @{path = $File; ProviderName="Microsoft-Windows-Security-Auditing" ; ID=4624} -ErrorAction Stop
    Write-Host "(LoginEvents.ps1):" -f Yellow -nonewline; write-host " Selected Security Event Log: ($File)" -f White
    }
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog2 = $log2.toXml()
$Lcount = $xmllog2.Count

$Events2 = foreach ($l in $xmllog2) {$e++
			
			#Progress Bar
			write-progress -id 1 -activity "Collecting Security entries with EventID=4624 - $e of $Lcount"  -PercentComplete (($e / $Lcount) * 100)		
			# Format output fields

            $version = if ($l.Event.System.Version -eq 0){"Windows Server 2008, Windows Vista"}
                        elseif($l.Event.System.Version -eq 01){"Windows Server 2012, Windows 8"}
                        elseif($l.Event.System.Version -eq 02){"Windows 10"}
            $LogonType = if ($l.Event.EventData.Data[8].'#text' -eq 2 ){"Interactive"}
                            elseif($l.Event.EventData.Data[8].'#text' -eq 3){"Network"}
                            elseif($l.Event.EventData.Data[8].'#text' -eq 4){"Batch"}
                            elseif($l.Event.EventData.Data[8].'#text' -eq 5){"Service"}
                            elseif($l.Event.EventData.Data[8].'#text' -eq 7){"Unlock"}
                            elseif($l.Event.EventData.Data[8].'#text' -eq 8){"NetworkCleartext"}
                            elseif($l.Event.EventData.Data[8].'#text' -eq 9){"NewCredentials"}
                            elseif($l.Event.EventData.Data[8].'#text' -eq 10){"RemoteInteractive"}
                            elseif($l.Event.EventData.Data[8].'#text' -eq 11){"CachedInteractive"}
                            else {$l.Event.EventData.Data[8].'#text'}

              $ElevatedToken = if($l.Event.EventData.Data[26].'#text' -eq "%%1842"){"Yes"}
                                elseif($l.Event.EventData.Data[26].'#text' -eq "%%1843"){"No"}
			
			[PSCustomObject]@{ 
			'EventID' = $l.Event.System.EventID
            'Time Created' = Get-Date ($l.Event.System.TimeCreated.SystemTime) -format o
			'RecordID' = $l.Event.System.EventRecordID
            'Version' = $version
            'Level' = $l.Event.System.Level
            'Task' = $l.Event.System.Task
            'Opcode' = $l.Event.System.Opcode
			'PID' = [Convert]::ToInt64(($l.Event.System.Execution.ProcessID),16) 
			'ThreadID' = $l.Event.System.Execution.ThreadID
            'LogonID' =  [Convert]::ToInt64(($l.Event.EventData.Data[16].'#text'),16)  # [Type = HexInt64]
			'User Name' = $l.Event.EventData.Data[1].'#text'
			'SID' = $l.Event.EventData.Data[0].'#text' # SID of account that reported information
            'SubjectUserName' = $l.Event.EventData.Data[1].'#text' # [Type = UnicodeString]
            'SubjectDomainName' = $l.Event.EventData.Data[2].'#text' # [Type = UnicodeString]
            'SubjectLogonId' = $l.Event.EventData.Data[3].'#text'
            'TargetUserSid' = $l.Event.EventData.Data[4].'#text' # SID
			'Domain Name' = $i.Event.EventData.Data[2].'#text'
            'Computer' = $l.Event.System.Computer            
            'TargetUserName' = $l.Event.EventData.Data[5].'#text'
            'TargetDomainName' = $l.Event.EventData.Data[6].'#text'
            'TargetLogonId' = $l.Event.EventData.Data[7].'#text'
            'LogonType' = $LogonType
            'LogonProcessName' = $l.Event.EventData.Data[9].'#text'
            'AuthenticationPackageName' = $l.Event.EventData.Data[10].'#text' #“HKLM\SYSTEM\CurrentControlSet\Control\Lsa\OSConfig”
            'WorkstationName' = $l.Event.EventData.Data[11].'#text'
            'LogonGuid' = $l.Event.EventData.Data[12].'#text'
            'TransmittedServices' = $l.Event.EventData.Data[13].'#text' #[Type = UnicodeString] [Kerberos-only]
            'LmPackageName' = $l.Event.EventData.Data[14].'#text' #(NTLM only)[Type = UnicodeString]: “NTLM V1”, “NTLM V2”, “LM”
            'KeyLength' = $l.Event.EventData.Data[15].'#text'
            'IpAddress' = $l.Event.EventData.Data[18].'#text' # [Type = UnicodeString]: ::1 or 127.0.0.1 means localhost.
            'IpPort' = $l.Event.EventData.Data[19].'#text'   # 0 for interactive logons
            'ImpersonationLevel' = $l.Event.EventData.Data[20].'#text'
            'RestrictedAdminMode' = $l.Event.EventData.Data[21].'#text' # [Type = UnicodeString]: This is a Yes/No flag
            'TargetOutboundUserName' = $l.Event.EventData.Data[22].'#text'
            'TargetOutboundDomainName' = $l.Event.EventData.Data[23].'#text'
            'VirtualAccount' = $l.Event.EventData.Data[24].'#text'
            'TargetLinkedLogonId' = [Convert]::ToInt64(($l.Event.EventData.Data[25].'#text'),16) #Linked Logon ID - [Type = HexInt64]
            'ElevatedToken' = $ElevatedToken  # [Type = UnicodeString]: a “Yes” or “No” flag.
            'ProcessId' = [Convert]::ToInt64(($l.Event.EventData.Data[16].'#text'),16) 
            'Process Name' = $l.Event.EventData.Data[17].'#text'
            'Channel' = $l.Event.System.Channel
            'Correlation' = $l.Event.System.Correlation.ActivityID
            'Keywords' = $l.Event.System.Keywords
			}

	}

function Result{

$Events2
}
$sw.stop()
$t=$sw.Elapsed
Result |Out-GridView -PassThru -Title "$Lcount - Login Events (ID 4624) - Processing Time $t"
write-host "Elapsed Time $t minutes" -f yellow
