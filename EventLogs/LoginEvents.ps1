#Requires -RunAsAdministrator

#References: 
# https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624
# https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
#
# This event is generated when a logon session is created. It is generated on the computer that was accessed.
#               
# The subject fields indicate the account on the local system which requested the logon. This is most commonly a service such as the 
# Server service, or a local process such as Winlogon.exe or Services.exe.
#               
# The logon type field indicates the kind of logon that occurred. The most common types are 2 (interactive) and 3 (network).
#               
# The New Logon fields indicate the account for whom the new logon was created, i.e. the account that was logged on.
#               
# The network fields indicate where a remote logon request originated. Workstation name is not always available and may be left blank in some cases.
#               
# The impersonation level field indicates the extent to which a process in the logon session can impersonate.
#               
# The authentication information fields provide detailed information about this specific logon request.
#    - Logon GUID is a unique identifier that can be used to correlate this event with a KDC event.
#    - Transited services indicate which intermediate services have participated in this logon request.
#    - Package name indicates which sub-protocol was used among the NTLM protocols.
#    - Key length indicates the length of the generated session key. This will be 0 if no session key was requested.
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
	$log2 = (Get-WinEvent -FilterHashtable @{path = $File; ProviderName="Microsoft-Windows-Security-Auditing" ; ID=4624} -ErrorAction Stop)
    Write-Host "(LoginEvents.ps1):" -f Yellow -nonewline; write-host " Selected Security Event Log: ($File)" -f White
    }
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog2 = $log2.toXml()
$Lcount = $xmllog2.Count
Write-Host "Events found: $Lcount" -f White

$Events2 = foreach ($l in $xmllog2) {$e++
			
			#Progress Bar
			write-progress -id 1 -activity "Collecting Security entries with EventID=4624 - $e of $($xmllog2.Count)"  -PercentComplete (($e / $xmllog2.Count) * 100)		
			
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
             
            $Level = if ($l.Event.System.Level -eq 0 ){"Undefined"}
                        elseif($l.Event.System.Level -eq 1){"Critical"}
                        elseif($l.Event.System.Level -eq 2){"Error"}
                        elseif($l.Event.System.Level -eq 3){"Warning"}
                        elseif($l.Event.System.Level -eq 4){"Information"}
                        elseif($l.Event.System.Level -eq 5){"Verbose"}

            $ElevatedToken = if($l.Event.EventData.Data[26].'#text' -eq "%%1842"){"Yes"}
                                elseif($l.Event.EventData.Data[26].'#text' -eq "%%1843"){"No"}
            $VirtualAccount = if($l.Event.EventData.Data[24].'#text' -eq "%%1842"){"Yes"}
                                elseif($l.Event.EventData.Data[24].'#text' -eq "%%1843"){"No"}
            $ImpersonationLevel = if($l.Event.EventData.Data[20].'#text' -eq "%%1832"){"Identification"}
                                elseif($l.Event.EventData.Data[20].'#text' -eq "%%1833"){"Impersonation"}
                                elseif($l.Event.EventData.Data[20].'#text' -eq "%%1834"){"Delegation"}
                                elseif($l.Event.EventData.Data[20].'#text' -eq $null)  {"Anonymous"}
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
            'LogonID' =           $l.Event.EventData.Data[16].'#text'  
			'User Name' =         $l.Event.EventData.Data[1].'#text'
			'SID' =               $l.Event.EventData.Data[0].'#text' 
            'SubjectUserName' =   $l.Event.EventData.Data[1].'#text' 
            'SubjectDomainName' = $l.Event.EventData.Data[2].'#text' 
            'SubjectLogonId' =    $l.Event.EventData.Data[3].'#text'
            'TargetUserSid' =     $l.Event.EventData.Data[4].'#text' 
			'Domain Name' =       $l.Event.EventData.Data[2].'#text'
            'Computer' =          $l.Event.System.Computer            
            'TargetUserName' =    $l.Event.EventData.Data[5].'#text'
            'TargetDomainName' =  $l.Event.EventData.Data[6].'#text'
            'TargetLogonId' =     $l.Event.EventData.Data[7].'#text'
            'LogonType' =         $LogonType
            'LogonProcessName' =  $l.Event.EventData.Data[9].'#text'
            'Auth.PackageName' =  $l.Event.EventData.Data[10].'#text'
            'WorkstationName' =   $l.Event.EventData.Data[11].'#text'
            'LogonGuid' =         $l.Event.EventData.Data[12].'#text'
            'TransmittedServices' = $l.Event.EventData.Data[13].'#text' 
            'LmPackageName' =     $l.Event.EventData.Data[14].'#text' 
            'KeyLength' =         $l.Event.EventData.Data[15].'#text'
            'IpAddress' =         $l.Event.EventData.Data[18].'#text' 
            'IpPort' =            $l.Event.EventData.Data[19].'#text'   
            'ImpersonationLevel' =       $ImpersonationLevel  
            'RestrictedAdminMode'=       $l.Event.EventData.Data[21].'#text' 
            'TargetOutboundUserName' =   $l.Event.EventData.Data[22].'#text'
            'TargetOutboundDomainName' = $l.Event.EventData.Data[23].'#text'
            'VirtualAccount' =     $VirtualAccount   
            'TargetLinkedLogonId' = ([Convert]::ToInt64(($l.Event.EventData.Data[25].'#text'),16)) 
            'ElevatedToken' =      $ElevatedToken  
            'ProcessId' =          ([Convert]::ToInt64(($l.Event.EventData.Data[16].'#text'),16)) 
            'Process Name' =       $l.Event.EventData.Data[17].'#text'
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
Result |Out-GridView -PassThru -Title "$Lcount - Login Events (ID 4624) - Processing Time $t"
write-host "Elapsed Time $t minutes" -f yellow


[gc]::Collect()

