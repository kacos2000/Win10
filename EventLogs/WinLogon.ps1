#Requires -RunAsAdministrator


# Winlogon:
# 
#     A part of the Windows operating system that provides interactive logon support. 
#     Winlogon is designed around an interactive logon model that consists of three parts: 
#     the Winlogon executable, 
#     a Graphical Identification and Authentication dynamic-link 
#     library (DLL) referred to as the GINA, and 
#     any number of network providers.
#
# Ref:https://docs.microsoft.com/en-us/windows/desktop/SecGloss/w-gly
# https://docs.microsoft.com/en-us/windows/desktop/SecAuthN/winlogon
# 

# Show an Open File Dialog and return the file selected by the user
Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.SelectedPath = "C:\Windows\System32\WinEvt\logs\"
	$foldername.Description = "Select the location of 'Microsoft-Windows-Winlogon/Operational.evtx' log (\System32\WinEvt\logs\)"
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

$File = $Folder + "Microsoft-Windows-Winlogon%4Operational.evtx"
$e=0
$sw = [Diagnostics.Stopwatch]::StartNew()

Try { 
    Write-Host "(Winlogon.ps1):" -f Yellow -nonewline; write-host " Selected Event Log: ($File)" -f White 
	$log10 = @(Get-WinEvent -FilterHashtable @{path = $File; ProviderName="Microsoft-Windows-Winlogon"} -ErrorAction Stop)
    }
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog = $log10.toXml()
$Lcount = $xmllog.Count
 

#Get all the event log entries
$Events10 = foreach ($l in $xmllog) {$e++
			
			#Progress Bar
			write-progress -id 1 -activity "Collecting WinLogon entries - $e of $($Lcount)"  -PercentComplete (($e / $Lcount) * 100)		
			
          

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
                    elseif($l.Event.System.Opcode -eq 201) {'NotificationPended'}
                    elseif($l.Event.System.Opcode -eq 202) {'NotificationFailed'}
                      else{$l.Event.System.Opcode}

            $Date = (Get-Date ($l.Event.System.TimeCreated.SystemTime) -f o)
			
			[PSCustomObject]@{
 			'EventID' =            $l.Event.System.EventID
            'Time Created' =       $Date  
			'RecordID' =           $l.Event.System.EventRecordID
            'Level' =              $Level
            'Task' =               $l.Event.System.Task
            'Opcode' =             $Opcode
            'PID' =                ([Convert]::ToInt64(($l.Event.System.Execution.ProcessID),16))
			'ThreadID' =           $l.Event.System.Execution.ThreadID
            'Security UserID' =    if($l.Event.System.Security.UserID -eq 'S-1-5-18'){'Local System'}else{$l.Event.System.Security.UserID}
                                   # https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems

            'Event'        =       if($l.Event.System.EventID -in (1,2)){}else{$l.Event.EventData.Data[0].'#text'}
            'SubscriberName'  =    if($l.Event.System.EventID -in (1,2)){}else{$l.Event.EventData.Data[1].'#text'}
                                   # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\GPExtensions
                                   # Ref: https://docs.microsoft.com/en-us/windows/desktop/secauthn/registry-entries

            'Computer' =           $l.Event.System.Computer            
            'Version' =            $version
            'Correlation' =        $l.Event.System.Correlation.ActivityID
            'Provider Name' =      $l.Event.System.provider.Name
            'Provider GUID' =      $l.Event.System.provider.GUID  
            'Channel' =            $l.Event.System.Channel
            'Keywords' =           $l.Event.System.Keywords
			}

	}



function Result{
$Events10
}

$sw.stop()
$t=$sw.Elapsed

# Display Output
Result |Out-GridView -PassThru -Title "Processed $Lcount Microsoft-Windows-Winlogon events - in $t"
write-host "Processed $Lcount Microsoft-Windows-Winlogon events - in $t" -f white


[gc]::Collect()

