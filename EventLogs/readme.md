<!-- saved from url=(0054) https://kacos2000.github.io/Win10-Research/EventLogs/ --> 
<!-- https://guides.github.com/features/mastering-markdown/ --> 
####  Lists  ####
- [keywords1](https://github.com/kacos2000/Win10/blob/master/EventLogs/keywords.md) - 
  Powershell script to list all eventlog keywords and the resulting list *(from Win10 Pro version 1803)*
- [keywords2](https://github.com/kacos2000/Win10/blob/master/EventLogs/keywords2.md) - 
  Powershell script to list all event specific generated keywords and sample list *(from the Win10 Pro version 1803 "Microsoft-Windows-PushNotifications-Platform" event provider)*
 - [OpCodes](https://github.com/kacos2000/Win10/blob/master/EventLogs/OpCodes.md)  - Powershell script to list all OpCodes, their Name & DisplayName for AllEvent providers, and 2 csv lists 

###  Win 10 *(version 1709+)* Microsoft-Windows-Partition/Diagnostic.evtx EventID: 1006 parser  ###

- [Win 10 Microsoft-Windows-Partition/Diagnostic EventID: 1006 parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/ProcessCreatedEvents.ps1) - PowerShell script to read a live or offline **Microsoft-Windows-Partition/Diagnostic.evtx** log and list all the [EventID: 1006](https://df-stream.com/2018/05/partition-diagnostic-event-log-and-usb-device-tracking-p1/) entries in a window. Selected rows are saved in a comma separated file (csv). This log has 71 fields with diagnostic information for all Storage Devices (including USB and virtual drives like vhd/vhdxs or images mounted with [Arsenal Image Mounter](https://arsenalrecon.com/)). Among them, the MBR or VBR:

  *Part of the results window:*
  ![PartoftheResults](https://raw.githubusercontent.com/kacos2000/Win10/master/EventLogs/pd00.JPG)

  *VBR0 entry (size & bytes) of a USB stick:*
  ![VBR](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/pd0.JPG)

  *VBR above saved & opened with [Active Disk Editor](http://www.disk-editor.org/)*
  ![VbrinActiveDiskEditor](https://raw.githubusercontent.com/kacos2000/Win10/master/EventLogs/pd1.JPG)
  
  *Mbr log entry (copy/pasted to [HxD](https://mh-nexus.de/en/hxd/))*
  ![MBR](https://raw.githubusercontent.com/kacos2000/Win10/master/EventLogs/mb.JPG)
  
  *GPT Partition table entry of same drive in [Active Disk Editor](http://www.disk-editor.org/)*
  ![MbrinActiveDiskEditor](https://raw.githubusercontent.com/kacos2000/Win10/master/EventLogs/mb1.JPG)


###  Win 10 Microsoft-Windows-Kernel-PnP/Configuration.evtx parser  ###

- [Win 10 Microsoft-Windows-Kernel-PnP parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/PnP.ps1) - PowerShell script to read a live or offline **Microsoft-Windows-Kernel-PnP/Configuration.evtx** log and list all the  entries. Should also work from Win7 onwards. 

     ![preview](https://raw.githubusercontent.com/kacos2000/Win10/master/EventLogs/pnp.JPG)

###  Win 10 Microsoft-Windows-PowerShell/Operational.evtx EventIDs: 24577,40961, 40962 parser  ###

- [Win 10 Microsoft-Windows-PowerShell parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/Powershell.ps1) - PowerShell script to read a live or offline **Microsoft-Windows-PowerShell/Operational.evtx** log and list all the  entries. Should also work from Win7 onwards. Curiously, Powershell script execution is not recorded - just console startups. Only Powershell ISE script execution.

    - Event ID: 40961 - PowerShell console is starting up
    - Event ID: 40962 - PowerShell console is ready for user input
    - Event ID: 40962 - Windows PowerShell ISE has started to run script XXX

###  Win 10 Microsoft-Windows-VolumeSnapshot-Driver/Operational.evtx parser  ###

- [Win 10 Microsoft-Windows-VolumeSnapshot-Driver parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/VolumeSnapshot.ps1) - PowerShell script to read a live or offline **Microsoft-Windows-VolumeSnapshot-Driver/Operational.evtx** log and list all the  entries. Should also work from Win7 onwards. (*[Exploring Volume Shadow (VSS) snapshots (pdf)](https://github.com/kacos2000/Win10/blob/master/EventLogs/VolumeShadow.pdf)*)

     ![preview](https://raw.githubusercontent.com/kacos2000/Win10/master/EventLogs/vsJPG.JPG)
     
###  Win 10 Microsoft-Windows-VHDMP-Operational.evtx parser  ###

- [Win 10 Microsoft-Windows-VHDMP-Operational parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/VHD_log.ps1) - PowerShell script to read a live or offline **Microsoft-Windows-VHDMP-Operational.evtx** log and list all the  entries. (Supports Event IDs: 1,2,50,51)

###  Win 10 Security.evtx EventID: 4688 parser  ###

- [Win 10 Security EventID: 4688 parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/ProcessCreatedEvents.ps1) - PowerShell script to read a live or offline **security.evtx** log and list all the [EventID: 4688](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4688) entries *(A new process has been created)* . 

###  Win 10 Security.evtx EventID: 4624/4634/4647 parser  ###

- [Win 10 Security EventID: 4634/4747 parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/LogOnOFFevents.ps1) - PowerShell script to read a live or offline **security.evtx** log and list all the [EventID: 4624](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624) *(An account was successfully logged on)*, [EventID: 4634](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4634) *(An account was logged off)* and [EventID: 4647](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4647) *(User initiated logoff)* entries in a window.

###  Win 10 Security.evtx EventID: 4634/4647 parser  ###

- [Win 10 Security EventID: 4634/4747 parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/LogoffEvents.ps1) - PowerShell script to read a live or offline **security.evtx** log and list all the [EventID: 4634](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4634) *(An account was logged off)* and [EventID: 4647](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4647) *(User initiated logoff)* entries in a window.
The main difference between “[4647: User initiated logoff](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4647).” and 4634 event is that 4647 event is generated when logoff procedure was initiated by specific account using logoff function, and 4634 event shows that session was terminated and no longer exists.

###  Win 10 Security.evtx EventID: 4624 parser  ###

- [Win 10 Security EventID: 4624 parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/LoginEvents.ps1) - PowerShell script to read a live or offline **security.evtx** log and list all the [EventID: 4624](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624) entries *(An account was successfully logged on)* in a window. 

###  Win 10 Security.evtx EventID: 4648 parser  ###

- [Win 10 Security EventID: 4648 parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/LogonAttempted.ps1) - PowerShell script to read a live or offline **security.evtx** log and list all the [EventID: 4648](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4648) entries *(A logon was attempted using explicit credentials)* in a window. 

###  Win 10 Security.evtx EventID: 4616 & System.evtx EventID: 1 parser ###

- [Win 10 Security EventID: 4616 & System EventID: 1 parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/TimeEventsAll.ps1) - PowerShell script to read both **security.evtx** and **system.evtx** logs from a live or offline Win 10 PC, and list all the [EventID:1](http://www.eventid.net/display-eventid-1-source-Microsoft-Windows-Kernel-General-eventno-10866-phase-1.htm) and [EventID: 4616](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4616) entries *(The system time was changed)* in a window. Selected rows are saved in a comma separated file (csv).  
  
  The [script](https://github.com/kacos2000/Win10/blob/master/EventLogs/TimeEventsAll.ps1) *(needs to be executed from an Administrator console)*. 

  - Event Providers *(type the following in a powershell prompt to see the event template)*: 
     - "Microsoft-Windows-Kernel-General" (ID: 1)<br>
        `(Get-WinEvent -ListProvider "Microsoft-Windows-Kernel-General").Events|Where-Object {$_.Id -eq 1}`<br>
        
        * Event **Reason** Nr#:<br>
          1 = An application or system component changed the time<br>
          2 = System time synchronized with the hardware clock<br>
          3 = System time adjusted to the new time zone
      
     - "Microsoft-Windows-Security-Auditing" (ID: 4616)<br>
        `(Get-WinEvent -ListProvider "Microsoft-Windows-Security-Auditing").Events|Where-Object {$_.Id -eq 4616}`

###  Win 10 Microsoft-Windows-Winlogon/Operational.evtx parser  ###

- [Win 10 Microsoft-Windows-Winlogon parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/WinLogon.ps1) - PowerShell script to read a live or offline **Microsoft-Windows-Winlogon/Operational.evtx** log and list all the relevant entries in a window. 


###  Win 10 Security.evtx EventID: 4616 parser  ###

- [Win 10 Security EventID: 4616 parser](https://github.com/kacos2000/Win10/blob/master/EventLogs/TimeEvents.ps1) - PowerShell script to read a live or offline **security.evtx** log and list all the [EventID: 4616](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4616) entries *(The system time was changed)* in a window. Selected rows are saved in a comma separated file (csv).  

   The [script](https://github.com/kacos2000/Win10/blob/master/EventLogs/TimeEvents.ps1) *(needs to be executed from an Administrator console)* will parse the following information for any 4616 event ID:

   -  Field              | Description
      ------------       | -------------
      Time Created       | DateTime the event was recorded
      EventID            | Record ID of the Event
      PID                | Process ID
      ThreadID           | Thread ID
      User Name          | UserName associated with the event 
      SID                | Security descriptor
      Domain Name        | Domain Name
      New Time           | New Time
      Previous Time      | Previous Time
      Change             | Difference between New and Previous times
      Process Name       | The process that initiated the Time change 
      
       ![File Open](https://raw.githubusercontent.com/kacos2000/Win10/master/EventLogs/O.JPG)
  
    - [Are Windows timezone written in registry reliable?](https://stackoverflow.com/questions/47104967/are-windows-timezone-written-in-registry-reliable)
    - `tzutil  /l` : List timezones
    - [Finding	Advanced Attacks and Malware With Only 6 Windows EventID’s (pdf)](https://conf.splunk.com/session/2015/conf2015_MGough_MalwareArchaelogy_SecurityCompliance_FindingAdvnacedAttacksAnd.pdf)
  
 
###  Windows Security Audit Events with message schema [spreadsheet](https://download.microsoft.com/download/8/E/1/8E11AD26-98A1-4EE3-9F7F-1DB4EB18BADF/WindowsSecurityAuditEvents.xlsx) from Microsoft.  ###
       
 eof
 __________________

**Note:** Old Windows event IDs can be converted to new event IDs [by adding 4096](https://www.andreafortuna.org/2019/06/12/windows-security-event-logs-my-own-cheatsheet/) to the Event ID<br>
eg: 528 *(Successful Logon)* + 4096 = 4624<br>
 __________________
   
     - To Do:
       - [X] [List all event log *'keywords'*](keywords.md)
       - [X] [List all eventlog-generated *'keywords'*](keywords2.md)
       - [X] List all [OpCodes](OpCodes.md) 
       - [X] Parse EventID 4616
       - [X] Parse EventID 4624/4634/4647 together 
       - [X] Parse EventIDs 4624/4528/4540 (Audit Logon = Success & Failure)
       - [X] Parse EventIDs 4634/4647 (An account was logged off/User initiated logoff)
       - [X] Parse Microsoft-Windows-Winlogon/Operational.evtx
       - [X] Check / Parse EventID 4625
       - [X] Check / Parse EventID 4648
       - [ ] Check / Parse EventIDs 4663/4567 (Audit File	System = Success, (Audit Registry = Success ))
       - [ ] Check / Parse EventID 4675
       - [X] Check / Parse EventID 4688 (Audit Process Creation =	Success)
       - [ ] Check / Parse EventID [4720](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4720)): A user account was created
       - [ ] Check / Parse EventID [4726](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4726)): A user account was deleted
       - [ ] Check / Parse EventIDs 5140/5560 (Audit File	Share	=	Success )
       - [ ] Check / Parse EventID 5156 (Audit Filtering Platform Connection = Success)
       - [ ] Check / Parse EventIDs 7045/7040 
       - [ ] ~~Correlate entries in EventIDs 4616, 4624, 4688 etc~~
       - [X] [Parse EventLog Microsoft-Windows-PushNotification-Platform/Operational.evtx](https://github.com/kacos2000/Win10/blob/master/Notifications/wpn.ps1)
       - [X] Parse Microsoft-Windows-Kernel-PnP/Configuration.evtx      
       - [X] Parse Microsoft-Windows-VolumeSnapshot-Driver/Operational.evtx
       - [X] Parse Microsoft-Windows-VHDMP-Operational.evtx       
       - [X] Parse Microsoft-Windows-PowerShell/Operational.evtx
       - [X] Check /Parse EventID 1006 of Microsoft-Windows-Partition/Diagnostic.evtx [(USB Device Tracking ..)](https://df-stream.com/2018/07/partition-diagnostic-event-log-and-usb-device-tracking-p2/)
      
