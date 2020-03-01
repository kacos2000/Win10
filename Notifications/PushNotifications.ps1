#Requires -RunAsAdministrator
#
# Properties
# HKLM: \SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PushNotification-Platform/Operational
#
#
#References: 
#
# Critical - Value: 1. Indicates logs for a critical alert.
# Error	- Value: 2. Indicates logs for an error.
# Information - Value: 4. Indicates logs for an informational message.
# Undefined	- Value: 0. Indicates logs at all levels.
# Verbose - Value: 5. Indicates logs at all levels.
# Warning - Value: 3. Indicates logs for a warning.
#
#
clear-host
# Check Validity of script
if ((Get-AuthenticodeSignature $MyInvocation.MyCommand.Path).Status -ne "Valid")
{
	
	$check = [System.Windows.Forms.MessageBox]::Show($this, "WARNING:`n$(Split-path $MyInvocation.MyCommand.Path -Leaf) has been modified since it was signed.`nPress 'YES' to Continue or 'No' to Exit", "Warning", 'YESNO', 48)
	switch ($check)
	{
		"YES"{ Continue }
		"NO"{ Exit }
	}
}
# Show an Open File Dialog and return the file selected by the user
Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.SelectedPath = "C:\Windows\System32\WinEvt\logs\"
	$foldername.Description = "Select the location of Microsoft-Windows-PushNotification-Platform%4Operational.evtx log (\System32\WinEvt\logs\)"
	$foldername.ShowNewFolderButton = $false
	
    if($foldername.ShowDialog() -eq "OK")
		{
        $folder += $foldername.SelectedPath
		 }
	        else  
        {
            Write-Host "(PushNotifications.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}

$F = Get-Folder +"\"
$Folder = $F +"\"
$DesktopPath = ($Env:WinDir+"\System32\winevt\Logs\")
$g=0
$PNFile = $Folder+"Microsoft-Windows-PushNotification-Platform%4Operational.evtx"
$sw8 = [Diagnostics.Stopwatch]::StartNew()
$log8=$xmllog8=$Events8=$null

# PSscript to get the 'keywords for the event"
#
# $v = ((Get-WinEvent -Listprovider Microsoft-Windows-PushNotifications-Platform).events.keywords)
# 
# $val = @(foreach($i in $v) {
#                
#    [PSCustomObject]@{
#        name = $i.name
#        value = "0x"+'{0:x16}'-f $i.value
#        displayname = $i.displayname
#    }
# })|sort-object -Property value -unique 
# 
# $out = foreach ($x in $val){"`"$($x.value)`" = `"$($x.displayname)`""} 
# $out|out-file D:\keyw.txt -append
#

#keyword array
$keyw = @{
            "0x0000000000000001" = "Developer Debug: Isolate Failures in Cloud Toast Notification Delivery"
            "0x0000000000000002" = "Developer Debug: Isolate Failures in Local Toast Notification Delivery"
            "0x0000000000000004" = "Developer Debug: Debugging Raw Notification Delivery Errors"
            "0x0000000000000008" = "Developer Debug: Isolate Failures in Raw Notification Delivery"
            "0x0000000000000100" = "Connection Manager"
            "0x0000000000000200" = "Endpoint Manager"
            "0x0000000000000800" = "Presentation Layer API"
            "0x0000000000001000" = "Platform"
            "0x0000000000002000" = "Debug"
            "0x0000000000004000" = "Connection Provider"
            "0x0000000000008000" = "Performance Scenario: First cloud notification"
            "0x0000000000010000" = "Performance Scenario: First cloud notification with cloud image download"
            "0x0000000000020000" = "Performance Scenario: New cloud notification arrives"
            "0x0000000000040000" = "Performance Scenario: New cloud notification refering cloud images arrives"
            "0x0000000000080000" = "Performance Scenario: MoGo is panning"
            "0x0000000000100000" = "Performance Scenario: MoGo is panning with downloading cloud images"
            "0x0000000000200000" = "Performance Scenario: The Windows Push Notification shutdown"
            "0x0000000000400000" = "WNP Transport Layer"
            "0x0000000000800000" = "WNP Transport Layer"
            "0x0000000001000000" = "Developer Debug: Isolate Failures in Cloud Tile Notification Delivery"
            "0x0000000002000000" = "Developer Debug: Debugging Cloud Connectivity"
            "0x0000000004000000" = "Developer Debug: Debugging Cloud Connectivity - Is device connected?"
            "0x0000000008000000" = "Developer Debug: Debugging Cloud Connectivity - errors"
            "0x0000000010000000" = "Developer Debug: Debugging Platform Setting Changes"
            "0x0000000020000000" = "Developer Debug: Isolate Failures in Local Tile Notification Delivery"
            "0x0000000040000000" = "Developer Debug: Debugging Polling Notification Delivery Errors"
            "0x0000000080000000" = "Developer Support: End-to-End trace for new notification"
            "0x0000200000000000" = ""
            "0x0001000000000000" = "Response Time"
            "0x2000000000000000" = ""
            "0x4000000000000000" = ""
            "0x8000000000000000" = "Microsoft-Windows-Shell-Core/Diagnostic"
}

# Full list of EventIDs & their definition:
# (Get-WinEvent -Listprovider Microsoft-Windows-PushNotifications-Platform).events|select-object -property id, description 
 
# Array of EventID & it's description (key/value):
$pndesc = @{
            "37" = "The Windows Push Notification Platform is required to connect on startup";
            "42" = "Cloud Notifications must be enabled in GP and MDM to receive push notifications";
            "1208" = "WNP Transport Layer resolving DNS completed";
            "1207" = "WNP Transport Layer resolving DNS initiated";
            "1206" = "WNP Transport Layer Disconnect call completed for the Test Connection";
            "1205" = "WNP Transport Layer Disconnect call initiated for the Test Connection";
            "1117" = "Windows Push Notification Service was disco;nnected";
            "1113" = "Device Compact Ticket request completed";
            "1222" = "ConnectWork is requesting ConnectionManager to connect";
            "1238" = "WNP Keep Alive Detector starting Test Connection";
            "1022" = "ConnectWork is requesting ConnectionManager to connect"
            "1025" = "A Power event was fired";
            "1024" = "Internet connection status changed to Connected";
            "1023" = "No internet connection available - ConnectWork is queued for next network status change";
            "1010" = "Raw Notification received" ;
            "1005" = "The Connection Provider status changed to Disconnected";
            "1268" = "WNP Transport Layer received command for the Data Connection";
            "1267" = "WNP Transport Layer sent command for the Data Connection";
            "1261" = "Adding new user to the Windows Push Notification Service"
            "1264" = "Adding new user to the Windows Push Notification Service completed" ;
            "1258" = "WNP Transport Layer for Data Connection received asynchronous connection error";
            "1257" = "WNP Transport Layer for Test Connection called InitializeSecurityContext";
            "1254" = "WNP Transport Layer for Data Connection detected preferred interface change";
            "1240" = "WNP Keep Alive Detector stopping KA measurement";
            "1246" = "WNP Transport Layer was disconnected from the Windows Push Notification Service due to a loss of network connectivity";
            "1252" = "The KA value has converged. Now disconnect test connection";
            "1259" = "WNP Transport Layer for the Data Connection sending out of band keep alive (PNG) request";
            "3111" = "Start Toast Notification Forwarding activity";
            "1315" = "WNP Transport Layer detected a change in WIFI interface connectivity status";
            "1239" = "WNP Keep Alive Detector starting KA measurement";
            "1225" = "WNP Transport Layer received command for the Data Connection";
            "1223" = "WNP Transport Layer sent command for the Data Connection";
            "1218" = "WNP Transport Layer TLS negotiation completed";
            "1217" = "WNP Transport Layer TLS negotiation initiated";
            "1216" = "WNP Transport Layer proxy negotiation completed";
            "1215" = "WNP Transport Layer proxy negotiation initiated for the Data Connection";
            "1213" = "WNP Transport Layer proxy connection initiated";
            "1212" = "WNP Transport Layer initial server connection completed";
            "1211" = "WNP Transport Layer initial server connection initiated";
            "2003" = "The channel table has updated a channel mapping"
            "2002" = "The channel table has removed a channel mapping" ;
            "2001" = "The channel table has added a valid channel mapping";
            "2415" = "An application was unregistered with the following parameters";
            "2413" = "An application was registered";
            "2414" = "An application registration was updated";
            "3056" = "Badge Notification are being cleared";
            "3055" = "Some toast notifications have been cleared";
            "3053" = "Tile is being delivered"
            "3052" = "Toast is being delivered";
            "3049" = "Endpoint is being cleanedup";
            "3144" = "Received WNF_CDP_CDPUSERSVC_READY"
            "3129" = "Sync Dismiss: Dismiss Activities Stop";
            "3128" = "Sync Dismiss: Dismiss Activities Start";
            "3115" = "Stop Toast Notification Forwarding";
            "3114" = "Start Toast Notification Forwarding";
            "3112" = "Stop Toast Notification Forwarding activity";
            "3110" = "Toast Notification Forwarding Global Settings";
            "3007" = "Toast session creation is finished"
            "3006" = "Toast session creation is requested"
            "3001" = "Tile session creation is finished";
            "3000" = "Tile session creation is requested for";
            }

# Get all Event ID data fields:
# $fie =@(foreach ($pn in $xmllog8){"`"$($pn.Event.System.EventID)`" ,`"$($pn.Event.EventData.Data.name)`""})
# $fie| sort|Get-Unique|out-file D:\Costas\Desktop\.temp\id.txt -append

#Just for reference - array of EventID & Data Fields (key/value)
$fields = @{
            "1005"="Status"
            "1010"="NotificationType ChannelId AppUserModelId TrackingId MessageId Timestamp Expiry Tag Group Action OfflineCacheCount CacheRollover OfflineBundleId"
            "1022"=""
            "1023"="WorkItemName"
            "1024"="WasConnected"
            "1025"="PowerEventType IsEnabled"
            "1113"="DeviceId ConnectionType"
            "1117"="Error"
            "1205"="ConnectionType"
            "1206"="ConnectionType"
            "1207"="ConnectionType HostName"
            "1208"="ConnectionType ErrorCode"
            "1211"="ConnectionType HostName Port"
            "1212"="ConnectionType HostName Port"
            "1213"="ConnectionType"
            "1215"="ConnectionType"
            "1216"="ConnectionType"
            "1217"="ConnectionType"
            "1218"="ConnectionType ErrorCode"
            "1223"="Verb TrID Namespace Bytes Payload ConnectionType"
            "1225"="Verb TrID Namespace Bytes Payload ConnectionType"
            "1238"=""
            "1239"="KaValueType KaValue KaMinLimit"
            "1240"=""
            "1246"=""
            "1252"=""
            "1254"="ConnectionType OldIndex OldAddressFamily NewIndex NewAddressFamily NewPhysicalMediumType"
            "1257"="ConnectionType Error"
            "1258"="ConnectionType SocketError"
            "1259"=""
            "1261"="DeviceId UserId UserType"
            "1264"="DeviceId UserId Error"
            "1267"="Verb TrID Namespace Bytes Payload ConnectionType"
            "1268"="Verb TrID Namespace Bytes Payload ConnectionType"
            "1315"="TriggerValue"
            "2001"="ChannelId AppUserModelId ErrorCode"
            "2002"="ChannelId AppUserModelId ErrorCode"
            "2003"="ChannelId AppUserModelId ErrorCode"
            "2413"="PackageFullName AppUserModelId AppSettings AppType ErrorCode"
            "2414"="PackageFullName AppUserModelId AppSettings AppType ErrorCode"
            "2415"="AppUserModelId ErrorCode"
            "3000"="Object ProcessName"
            "3001"="Endpoint SessionId Error ProcessName QueuedTileCloses QueuedTileCleanups"
            "3006"="Object ProcessName"
            "3007"="Endpoint SessionId Error ProcessName"
            "3049"="Object"
            "3052"="TrackingId AppUserModelId SessionId MessageId"
            "3053"="NotificationType TrackingId AppUserModelId SessionId MessageId"
            "3055"="SessionId"
            "3056"="NotificationType AppUserModelId SessionId ErrorCode SessionErrorCode"
            "3110"="IsFwdToCdpEnabled IsMirrorMasterSwitchEnabled MirroringEnabled"
            "3111"=""
            "3112"=""
            "3114"=""
            "3115"=""
            "3128"=""
            "3129"=""
            "3144"=""
            "37"="ChannelsExist"
            "42"="GroupPolicyValue MDMPolicyValue"
}

Try {$log8 = (Get-WinEvent -FilterHashtable @{path = $Folder + "Microsoft-Windows-PushNotification-Platform%4Operational.evtx"; ProviderName= "Microsoft-Windows-PushNotifications-Platform"})
    Write-Host "Selected Event Log:" -f Yellow -nonewline; write-host " $PNFile" -f White }
	catch {}

[xml[]]$xmllog8 = $log8.toxml()

$x8count = $xmllog8.Count
Write-Host "Microsoft-Windows-PushNotifications-Platform entries found: ->" -f Yellow -nonewline; write-host $x8count -f White

$Events8 = foreach ($pn in $xmllog8) {$g++
			
			#Progress Bar
			write-progress -id 1 -activity "Collecting Microsoft-Windows-PushNotification-Platform entry ->  $g of $($x8count)"  -PercentComplete (($g / $x8count) * 100)		
			
			# Format output fields
            $PNversion = if ($pn.Event.System.Version -eq 0){"Win10"}
                        else {$pn.Event.System.Version}
                      
            $PNLevel =      if($pn.Event.System.Level -eq 0){"Undefined"}
                        elseif($pn.Event.System.Level -eq 1){"Critical"}
                        elseif($pn.Event.System.Level -eq 2){"Error"}
                        elseif($pn.Event.System.Level -eq 3){"Warning"}
                        elseif($pn.Event.System.Level -eq 4){"Information"}
                        elseif($pn.Event.System.Level -eq 5){"Verbose"}
                        elseif($pn.Event.System.Level -ge 6){$pn.Event.System.Level}
                        else{""}


            $PNdate = (Get-Date ($pn.Event.System.TimeCreated.SystemTime) -f o)
            $PNevent = $pn.Event.System.EventID
            $pnkeyw = $pn.Event.System.Keywords
            $pl = if($pn.Event.eventdata.data.count -eq 6 -and $PNevent -in (1223,1225,1267,1268)){$pn.Event.EventData.Data[4].'#text'}
            
            # Convert Payload from HEX to Ascii and replace newline, CR and the \x00 character with ascii space
            $Payload = -join($pl-split'(..)'|?{$_}|%{[char]+"0x$_"}) -replace "`n|`r|[\x00]"," "
            
            #export each paylod to xml
            # $pp = -join($pl-split'(..)'|?{$_}|%{[char]+"0x$_"})
            # foreach($i in $pp){if($pn.Event.eventdata.data.count -eq 6){$i|out-file "D:\Costas\Desktop\.temp\Payload\Payload$($pn.Event.System.EventRecordID).xml"}}
                       

			 [PSCustomObject]@{
 		
 	         'EventID' =           $PNevent
              # get matching description from array 
             'EventDescription' =  $pndesc.item($pnevent)
             'Time Created' =      $PNdate  
			 'RecordID' =          $pn.Event.System.EventRecordID
             'Version' =           $PNversion
             'Level' =             $PNLevel
             'Task' =              $pn.Event.System.Task
             'Opcode' =            $pn.Event.System.Opcode
			 'PID' =               ([Convert]::ToInt64(($pn.Event.System.Execution.ProcessID),16))
			 'ThreadID' =          $pn.Event.System.Execution.ThreadID
             'Computer' =          $pn.Event.System.Computer 
             'SID' =               $pn.Event.System.Security.UserID 
             'Verb/TrID/Namespace'=if($pn.Event.eventdata.data.count -eq 6 -and $PNevent -in (1223,1225,1267,1268)){$pn.Event.EventData.Data[0].'#text' + " " + $pn.Event.EventData.Data[1].'#text' + " " + $pn.Event.EventData.Data[2].'#text'}else{}
             'Bytes' =             if($pn.Event.eventdata.data.count -eq 6 -and $PNevent -in (1223,1225,1267,1268)){$pn.Event.EventData.Data[3].'#text'}else{}
             'Payload' =           $Payload      
             'ConnectionType' =    if($pn.Event.eventdata.data.count -eq 6 -and $PNevent -in (1223,1225,1267,1268)){$pn.Event.EventData.Data[5].'#text'}
                                    elseif($PNevent -in (1254,1205,1206,1213,1215,1216,1217,1207,1208,1218,1257,1258,1211,1212)){$pn.Event.EventData.Data[0].'#text'}
                                    elseif($PNevent -in (1254)){$pn.Event.EventData.Data[1].'#text'}else{} 
             'GPV/WIN'   =         if($pn.Event.eventdata.data.count -eq 3){$pn.Event.EventData.Data[0].'#text'}else{}
             'MDMPolicyValue' =    if($pn.Event.eventdata.data.count -eq 3){$pn.Event.EventData.Data[1].'#text'}else{}


             'Status'    =         if($pn.Event.eventdata.data.count -eq 1 -and $PNevent -in (1005) ){$pn.Event.EventData.Data[0].'#text'}else{}
             'HostName'  =         if($pn.Event.eventdata.data.count -eq 3 -and $PNevent -in (1211,1212) ){$pn.Event.EventData.Data[1].'#text'}
                                    elseif($pn.Event.eventdata.data.count -eq 2  -and $PNevent -in (1207) ){$pn.Event.EventData.Data[1].'#text'} else{}
             'Port' =              if($pn.Event.eventdata.data.count -eq 3 -and $PNevent -in (1211,1212) ){$pn.Event.EventData.Data[2].'#text'}else{}
                       
             'GUID' =              $pn.Event.System.Guid
             
              'OldIndex' =           if($pn.Event.eventdata.data.count -eq 6 -and $PNevent -in (1254)){$pn.Event.EventData.Data[1].'#text'}else{}
              'OldAddressFamily' =   if($pn.Event.eventdata.data.count -eq 6 -and $PNevent -in (1254)){$pn.Event.EventData.Data[2].'#text'}else{}
              'NewIndex' =           if($pn.Event.eventdata.data.count -eq 6 -and $PNevent -in (1254)){$pn.Event.EventData.Data[3].'#text'}else{}
              'NewAddressFamily' =   if($pn.Event.eventdata.data.count -eq 6 -and $PNevent -in (1254)){$pn.Event.EventData.Data[4].'#text'}else{}
              'NewPhysicalMediumType' =  if($pn.Event.eventdata.data.count -eq 6 -and $PNevent -in (1254)){$pn.Event.EventData.Data[5].'#text'}else{}

             'Type' =                if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[0].'#text'}else{}
             'ChannelId' =           if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[1].'#text'}else{}
             'ChannelsExist'  =      if($pn.Event.eventdata.data.count -eq 2 -and $PNevent -in (37) ){$pn.Event.EventData.Data[0].'#text'}else{}
             'AppUserModelId' =      if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[2].'#text'}else{}
             'TrackingId' =          if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[3].'#text'}else{}
             'MessageId' =           if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[4].'#text'}else{}
             'Timestamp' =           if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[5].'#text'}else{}
             'Expiry' =              if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[6].'#text'}else{}
             'Tag' =                 if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[7].'#text'}else{}
             'Group' =               if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[8].'#text'}else{}
             'Action' =              if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[9].'#text'}else{}
             'OfflineCacheCount' =   if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[10].'#text'}else{}
             'CacheRollover' =       if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[11].'#text'}else{}
             'OfflineBundleId' =     if($pn.Event.eventdata.data.count -eq 13){$pn.Event.EventData.Data[12].'#text'}else{}

             
             'Correlation' =         if($pn.Event.System.Correlation -ne $null){$pn.Event.System.Correlation}else{}
             'Keywords' =            $pn.Event.System.Keywords
             'Keyword_Description' = $keyw.item($pnkeyw)
			}

	}


function Result{
$Events8
}

#Format of the txt filename and path:
$filenameFormat = $env:userprofile + "\desktop\PushNotifications" + (Get-Date -Format "dd-MM-yyyy_hh-mm") + ".csv"
Write-host "Selected Rows will be saved as: " -f Yellow -nonewline; Write-Host $filenameFormat -f White

$sw8.stop()
$t8=$sw8.Elapsed
Result |Out-GridView -PassThru -Title "'Microsoft-Windows-PushNotifications-Platform' Events -> $x8count - Processing Time $t8"#Export-Csv -Path $filenameFormat
write-host "Elapsed Time $t8" -f yellow


[gc]::Collect()


# SIG # Begin signature block
# MIIfcAYJKoZIhvcNAQcCoIIfYTCCH10CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCIGMwtPKbuCd3R
# A2T4IfzEIHyIueY8Mu7YMeyCQu9EmaCCGf4wggQVMIIC/aADAgECAgsEAAAAAAEx
# icZQBDANBgkqhkiG9w0BAQsFADBMMSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3Qg
# Q0EgLSBSMzETMBEGA1UEChMKR2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2ln
# bjAeFw0xMTA4MDIxMDAwMDBaFw0yOTAzMjkxMDAwMDBaMFsxCzAJBgNVBAYTAkJF
# MRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWdu
# IFRpbWVzdGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyMIIBIjANBgkqhkiG9w0BAQEF
# AAOCAQ8AMIIBCgKCAQEAqpuOw6sRUSUBtpaU4k/YwQj2RiPZRcWVl1urGr/SbFfJ
# MwYfoA/GPH5TSHq/nYeer+7DjEfhQuzj46FKbAwXxKbBuc1b8R5EiY7+C94hWBPu
# TcjFZwscsrPxNHaRossHbTfFoEcmAhWkkJGpeZ7X61edK3wi2BTX8QceeCI2a3d5
# r6/5f45O4bUIMf3q7UtxYowj8QM5j0R5tnYDV56tLwhG3NKMvPSOdM7IaGlRdhGL
# D10kWxlUPSbMQI2CJxtZIH1Z9pOAjvgqOP1roEBlH1d2zFuOBE8sqNuEUBNPxtyL
# ufjdaUyI65x7MCb8eli7WbwUcpKBV7d2ydiACoBuCQIDAQABo4HoMIHlMA4GA1Ud
# DwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBSSIadKlV1k
# sJu0HuYAN0fmnUErTDBHBgNVHSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYm
# aHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wNgYDVR0fBC8w
# LTAroCmgJ4YlaHR0cDovL2NybC5nbG9iYWxzaWduLm5ldC9yb290LXIzLmNybDAf
# BgNVHSMEGDAWgBSP8Et/qC5FJK5NUPpjmove4t0bvDANBgkqhkiG9w0BAQsFAAOC
# AQEABFaCSnzQzsm/NmbRvjWek2yX6AbOMRhZ+WxBX4AuwEIluBjH/NSxN8RooM8o
# agN0S2OXhXdhO9cv4/W9M6KSfREfnops7yyw9GKNNnPRFjbxvF7stICYePzSdnno
# 4SGU4B/EouGqZ9uznHPlQCLPOc7b5neVp7uyy/YZhp2fyNSYBbJxb051rvE9ZGo7
# Xk5GpipdCJLxo/MddL9iDSOMXCo4ldLA1c3PiNofKLW6gWlkKrWmotVzr9xG2wSu
# kdduxZi61EfEVnSAR3hYjL7vK/3sbL/RlPe/UOB74JD9IBh4GCJdCC6MHKCX8x2Z
# faOdkdMGRE4EbnocIOM28LZQuTCCBMYwggOuoAMCAQICDCRUuH8eFFOtN/qheDAN
# BgkqhkiG9w0BAQsFADBbMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2ln
# biBudi1zYTExMC8GA1UEAxMoR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBT
# SEEyNTYgLSBHMjAeFw0xODAyMTkwMDAwMDBaFw0yOTAzMTgxMDAwMDBaMDsxOTA3
# BgNVBAMMMEdsb2JhbFNpZ24gVFNBIGZvciBNUyBBdXRoZW50aWNvZGUgYWR2YW5j
# ZWQgLSBHMjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANl4YaGWrhL/
# o/8n9kRge2pWLWfjX58xkipI7fkFhA5tTiJWytiZl45pyp97DwjIKito0ShhK5/k
# Ju66uPew7F5qG+JYtbS9HQntzeg91Gb/viIibTYmzxF4l+lVACjD6TdOvRnlF4RI
# shwhrexz0vOop+lf6DXOhROnIpusgun+8V/EElqx9wxA5tKg4E1o0O0MDBAdjwVf
# ZFX5uyhHBgzYBj83wyY2JYx7DyeIXDgxpQH2XmTeg8AUXODn0l7MjeojgBkqs2Iu
# YMeqZ9azQO5Sf1YM79kF15UgXYUVQM9ekZVRnkYaF5G+wcAHdbJL9za6xVRsX4ob
# +w0oYciJ8BUCAwEAAaOCAagwggGkMA4GA1UdDwEB/wQEAwIHgDBMBgNVHSAERTBD
# MEEGCSsGAQQBoDIBHjA0MDIGCCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxz
# aWduLmNvbS9yZXBvc2l0b3J5LzAJBgNVHRMEAjAAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMEYGA1UdHwQ/MD0wO6A5oDeGNWh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5j
# b20vZ3MvZ3N0aW1lc3RhbXBpbmdzaGEyZzIuY3JsMIGYBggrBgEFBQcBAQSBizCB
# iDBIBggrBgEFBQcwAoY8aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNl
# cnQvZ3N0aW1lc3RhbXBpbmdzaGEyZzIuY3J0MDwGCCsGAQUFBzABhjBodHRwOi8v
# b2NzcDIuZ2xvYmFsc2lnbi5jb20vZ3N0aW1lc3RhbXBpbmdzaGEyZzIwHQYDVR0O
# BBYEFNSHuI3m5UA8nVoGY8ZFhNnduxzDMB8GA1UdIwQYMBaAFJIhp0qVXWSwm7Qe
# 5gA3R+adQStMMA0GCSqGSIb3DQEBCwUAA4IBAQAkclClDLxACabB9NWCak5BX87H
# iDnT5Hz5Imw4eLj0uvdr4STrnXzNSKyL7LV2TI/cgmkIlue64We28Ka/GAhC4evN
# GVg5pRFhI9YZ1wDpu9L5X0H7BD7+iiBgDNFPI1oZGhjv2Mbe1l9UoXqT4bZ3hcD7
# sUbECa4vU/uVnI4m4krkxOY8Ne+6xtm5xc3NB5tjuz0PYbxVfCMQtYyKo9JoRbFA
# uqDdPBsVQLhJeG/llMBtVks89hIq1IXzSBMF4bswRQpBt3ySbr5OkmCCyltk5lXT
# 0gfenV+boQHtm/DDXbsZ8BgMmqAc6WoICz3pZpendR4PvyjXCSMN4hb6uvM0MIIF
# PDCCBCSgAwIBAgIRALjpohQ9sxfPAIfj9za0FgUwDQYJKoZIhvcNAQELBQAwfDEL
# MAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UE
# BxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtT
# ZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwHhcNMjAwMjIwMDAwMDAwWhcNMjIw
# MjE5MjM1OTU5WjCBrDELMAkGA1UEBhMCR1IxDjAMBgNVBBEMBTU1NTM1MRUwEwYD
# VQQIDAxUaGVzc2Fsb25pa2kxDzANBgNVBAcMBlB5bGFpYTEbMBkGA1UECQwSMzIg
# Qml6YW5pb3UgU3RyZWV0MSMwIQYDVQQKDBpLYXRzYXZvdW5pZGlzIEtvbnN0YW50
# aW5vczEjMCEGA1UEAwwaS2F0c2F2b3VuaWRpcyBLb25zdGFudGlub3MwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDa2C7McRZbPAGLVPCcYCmhqbVRVGBV
# JXZhqJKFbJA95o2z4AiyB7C/cQGy1F3c3jW9Balp3uESAsy6JrJI+g62vxzk6chx
# tcre1PPnjqdcDQyetHRA7ZseDnFhk6DvxDR0emBHmdycAjWq3kACWwkKQADyuQ3D
# 6MxRhG3InKkv+e1OjVjW8zJobo8wxfVVrxDML8TIOu2QzgpCMf67gcFtzhtkNYKO
# 0ukSgVZ4YXrv8tenw5jLxR9Yv5RKGE1yXzafUy17RsxsEIEZx2IGBxmSF2HJCSbW
# vEXtcVslnzmttRS+tyNBxnXB/NK8Zf2h189414mjZy/pfUmTMQwcZOKdAgMBAAGj
# ggGGMIIBgjAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUH9X2tKd+540Ixy1znv3RfwoyR9cwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEAG
# A1UdIAQ5MDcwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwuc2Vj
# dGlnby5jb20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3JsMHMGCCsGAQUFBwEB
# BGcwZTA+BggrBgEFBQcwAoYyaHR0cDovL2NydC5zZWN0aWdvLmNvbS9TZWN0aWdv
# UlNBQ29kZVNpZ25pbmdDQS5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLnNl
# Y3RpZ28uY29tMA0GCSqGSIb3DQEBCwUAA4IBAQBbQmN6mJ6/Ff0c3bzLtKFKxbXP
# ZHjHTxB74mqp38MGdhMfPsQ52I5rH9+b/d/6g6BKJnTz293Oxcoa29+iRuwljGbv
# /kkjM80iALnorUQsk+RA+jCJ9XTqUbiWtb2Zx828GoCE8OJ1EyAozVVEA4bcu+nc
# cAFDd78YGyguDMHaYfnWjA2R2HkT4nYSu2u80+FeRuodmnB2dcM89k0a+XjuhDuG
# 8DJRcI2tjRZnR7geRHwVEFFPc/ZdAjRaFpAUgEArCWoIHAMtIf0W/fdtXrbdIeg9
# ibmcGiFH70Q/VvaXoDx+9qYLeYvEtAAEiHflfFElV2WIC+N47DLZxpkO7D68MIIF
# 3jCCA8agAwIBAgIQAf1tMPyjylGoG7xkDjUDLTANBgkqhkiG9w0BAQwFADCBiDEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNl
# eSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMT
# JVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTAwMjAx
# MDAwMDAwWhcNMzgwMTE4MjM1OTU5WjCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQCAEmUXNg7D2wiz0KxXDXbtzSfTTK1Qg2HiqiBNCS1kCdzOiZ/MPans9s/B3PHT
# sdZ7NygRK0faOca8Ohm0X6a9fZ2jY0K2dvKpOyuR+OJv0OwWIJAJPuLodMkYtJHU
# YmTbf6MG8YgYapAiPLz+E/CHFHv25B+O1ORRxhFnRghRy4YUVD+8M/5+bJz/Fp0Y
# vVGONaanZshyZ9shZrHUm3gDwFA66Mzw3LyeTP6vBZY1H1dat//O+T23LLb2VN3I
# 5xI6Ta5MirdcmrS3ID3KfyI0rn47aGYBROcBTkZTmzNg95S+UzeQc0PzMsNT79uq
# /nROacdrjGCT3sTHDN/hMq7MkztReJVni+49Vv4M0GkPGw/zJSZrM233bkf6c0Pl
# fg6lZrEpfDKEY1WJxA3Bk1QwGROs0303p+tdOmw1XNtB1xLaqUkL39iAigmTYo61
# Zs8liM2EuLE/pDkP2QKe6xJMlXzzawWpXhaDzLhn4ugTncxbgtNMs+1b/97lc6wj
# Oy0AvzVVdAlJ2ElYGn+SNuZRkg7zJn0cTRe8yexDJtC/QV9AqURE9JnnV4eeUB9X
# VKg+/XRjL7FQZQnmWEIuQxpMtPAlR1n6BB6T1CZGSlCBst6+eLf8ZxXhyVeEHg9j
# 1uliutZfVS7qXMYoCAQlObgOK6nyTJccBz8NUvXt7y+CDwIDAQABo0IwQDAdBgNV
# HQ4EFgQUU3m/WqorSs9UgOHYm8Cd8rIDZsswDgYDVR0PAQH/BAQDAgEGMA8GA1Ud
# EwEB/wQFMAMBAf8wDQYJKoZIhvcNAQEMBQADggIBAFzUfA3P9wF9QZllDHPFUp/L
# +M+ZBn8b2kMVn54CVVeWFPFSPCeHlCjtHzoBN6J2/FNQwISbxmtOuowhT6KOVWKR
# 82kV2LyI48SqC/3vqOlLVSoGIG1VeCkZ7l8wXEskEVX/JJpuXior7gtNn3/3ATiU
# FJVDBwn7YKnuHKsSjKCaXqeYalltiz8I+8jRRa8YFWSQEg9zKC7F4iRO/Fjs8PRF
# /iKz6y+O0tlFYQXBl2+odnKPi4w2r78NBc5xjeambx9spnFixdjQg3IM8WcRiQyc
# E0xyNN+81XHfqnHd4blsjDwSXWXavVcStkNr/+XeTWYRUc+ZruwXtuhxkYzeSf7d
# NXGiFSeUHM9h4ya7b6NnJSFd5t0dCy5oGzuCr+yDZ4XUmFF0sbmZgIn/f3gZXHlK
# YC6SQK5MNyosycdiyA5d9zZbyuAlJQG03RoHnHcAP9Dc1ew91Pq7P8yF1m9/qS3f
# uQL39ZeatTXaw2ewh0qpKJ4jjv9cJ2vhsE/zB+4ALtRZh8tSQZXq9EfX7mRBVXyN
# WQKV3WKdwrnuWih0hKWbt5DHDAff9Yk2dDLWKMGwsAvgnEzDHNb842m1R0aBL6KC
# q9NjRHDEjf8tM7qtj3u1cIiuPhnPQCjY/MiQu12ZIvVS5ljFH4gxQ+6IHdfGjjxD
# ah2nGN59PRbxYvnKkKj9MIIF9TCCA92gAwIBAgIQHaJIMG+bJhjQguCWfTPTajAN
# BgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJz
# ZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNU
# IE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBB
# dXRob3JpdHkwHhcNMTgxMTAyMDAwMDAwWhcNMzAxMjMxMjM1OTU5WjB8MQswCQYD
# VQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdT
# YWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJDAiBgNVBAMTG1NlY3Rp
# Z28gUlNBIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
# AQoCggEBAIYijTKFehifSfCWL2MIHi3cfJ8Uz+MmtiVmKUCGVEZ0MWLFEO2yhyem
# mcuVMMBW9aR1xqkOUGKlUZEQauBLYq798PgYrKf/7i4zIPoMGYmobHutAMNhodxp
# ZW0fbieW15dRhqb0J+V8aouVHltg1X7XFpKcAC9o95ftanK+ODtj3o+/bkxBXRIg
# CFnoOc2P0tbPBrRXBbZOoT5Xax+YvMRi1hsLjcdmG0qfnYHEckC14l/vC0X/o84X
# pi1VsLewvFRqnbyNVlPG8Lp5UEks9wO5/i9lNfIi6iwHr0bZ+UYc3Ix8cSjz/qfG
# FN1VkW6KEQ3fBiSVfQ+noXw62oY1YdMCAwEAAaOCAWQwggFgMB8GA1UdIwQYMBaA
# FFN5v1qqK0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQWBBQO4TqoUzox1Yq+wbutZxoD
# ha00DjAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHSUE
# FjAUBggrBgEFBQcDAwYIKwYBBQUHAwgwEQYDVR0gBAowCDAGBgRVHSAAMFAGA1Ud
# HwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RS
# U0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2BggrBgEFBQcBAQRqMGgwPwYI
# KwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FB
# ZGRUcnVzdENBLmNydDAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0
# LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEATWNQ7Uc0SmGk295qKoyb8QAAHh1iezrX
# MsL2s+Bjs/thAIiaG20QBwRPvrjqiXgi6w9G7PNGXkBGiRL0C3danCpBOvzW9Ovn
# 9xWVM8Ohgyi33i/klPeFM4MtSkBIv5rCT0qxjyT0s4E307dksKYjalloUkJf/wTr
# 4XRleQj1qZPea3FAmZa6ePG5yOLDCBaxq2NayBWAbXReSnV+pbjDbLXP30p5h1zH
# QE1jNfYw08+1Cg4LBH+gS667o6XQhACTPlNdNKUANWlsvp8gJRANGftQkGG+OY96
# jk32nw4e/gdREmaDJhlIlc5KycF/8zoFm/lv34h/wCOe0h5DekUxwZxNqfBZslkZ
# 6GqNKQQCd3xLS81wvjqyVVp4Pry7bwMQJXcVNIr5NsxDkuS6T/FikyglVyn7URnH
# oSVAaoRXxrKdsbwcCtp8Z359LukoTBh+xHsxQXGaSynsCz1XUNLK3f2eBVHlRHjd
# Ad6xdZgNVCT98E7j4viDvXK6yz067vBeF5Jobchh+abxKgoLpbn0nu6YMgWFnuv5
# gynTxix9vTp3Los3QqBqgu07SqqUEKThDfgXxbZaeTMYkuO1dfih6Y4KJR7kHvGf
# Wocj/5+kUZ77OYARzdu1xKeogG/lU9Tg46LC0lsa+jImLWpXcBw8pFguo/NbSwfc
# Mlnzh6cabVgxggTIMIIExAIBATCBkTB8MQswCQYDVQQGEwJHQjEbMBkGA1UECBMS
# R3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9T
# ZWN0aWdvIExpbWl0ZWQxJDAiBgNVBAMTG1NlY3RpZ28gUlNBIENvZGUgU2lnbmlu
# ZyBDQQIRALjpohQ9sxfPAIfj9za0FgUwDQYJYIZIAWUDBAIBBQCgTDAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAvBgkqhkiG9w0BCQQxIgQg3CKIYTCer2Lmbpqr
# FXfJ8YzfQDfS2QEeHp1vwKntxKkwDQYJKoZIhvcNAQEBBQAEggEAEuJX91iSY3gn
# izYpYqjzZewNo7zQodVe6kSUjvs6HiMDsTPosIbGln1WoMg8tCcfz1rTYdUjDj9t
# XyLmET+gAf38t67ZNk95LcHL5MJP9Y00smzDS1N9zyitGL+lAMdwpjqzisSV0YUs
# BjD5IHAA/EeuiDNvWMGUiuTmjiKZKRvpoMSaKqBd8iplibEu7CaXwRWQq9RUfX3J
# EVorsBfhnJ9XaswtS0Gd5S1QfVeWU7g6Tn9xEfLPfzoze/qr3LYWTKspPzWA3Zi2
# e2LZ+68UrVo5Cv7geUH8SorBvoGMCJZAPqqtBGLRlObXu2AcqsN1BjW2CtdDOoAm
# mGB6u0R4aqGCArkwggK1BgkqhkiG9w0BCQYxggKmMIICogIBATBrMFsxCzAJBgNV
# BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9i
# YWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyAgwkVLh/HhRTrTf6
# oXgwDQYJYIZIAWUDBAIBBQCgggEMMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
# HAYJKoZIhvcNAQkFMQ8XDTIwMDMwMTEyMjc0NlowLwYJKoZIhvcNAQkEMSIEIMmM
# xbVOdz1Ctib1ZqWDbVUBi+Wuitc4WNMTysGemI8QMIGgBgsqhkiG9w0BCRACDDGB
# kDCBjTCBijCBhwQUPsdm1dTUcuIbHyFDUhwxt5DZS2gwbzBfpF0wWzELMAkGA1UE
# BhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2Jh
# bFNpZ24gVGltZXN0YW1waW5nIENBIC0gU0hBMjU2IC0gRzICDCRUuH8eFFOtN/qh
# eDANBgkqhkiG9w0BAQEFAASCAQC+vPfuOskjfZFmbYsqAAWL3Z7LpxjYddRMkCw4
# /VD0uQOec8xELw0f3aRPC/UOmIA2j7T/lDqPX/fQgtVtoHPMEWI10xfdmQUZq2t+
# Wc2hyIXRyMOGCSbb6FX1cTjxFybyETbtHu6/CmcZ3TmzvSLOD4cFJO/10ksGWrHv
# 2mkX3q0pzNjBDz2ZFkAG0YirZzn7p3hEhBlafr0XdIZS31KD3CIPRaby+HPNV4vp
# KaoW9mvsrH8uVmvFPwHUvx+69WCnuIr98bJ9V9wewfqTVbh4lN4fXfDkKVxirmvz
# y8tykjF5Dv6nzv2Z77M5YsCyPsETQ/aGWtvhm8zlzR9DQxY3
# SIG # End signature block
