<!-- saved from url=(0054) https://kacos2000.github.io/Win10-Research/EventLogs/ --> 
<!-- https://guides.github.com/features/mastering-markdown/ --> 

###  Win 10 Microsoft-Windows-Partition/Diagnostic.evtx EventID: 1006 parser  ###

- [Win 10 EventID: 1006 parser](https://github.com/kacos2000/Win10-Research/blob/master/EventLogs/ProcessCreatedEvents.ps1) - PowerShell script to read a live or offline **Microsoft-Windows-Partition/Diagnostic.evtx** log and list all the [EventID:1006](https://df-stream.com/2018/05/partition-diagnostic-event-log-and-usb-device-tracking-p1/) entries in a window. Selected rows are saved in a comma separated file (csv). 71 fields with diagnostic information on Storage Devices (including USB). Among them, the MBR or VBR:

  *Part of the results window:*
  ![PartoftheResults](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/pd00.JPG)

  *VBR0 entry (size & bytes) of a USB stick:*
  ![VBR](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/pd0.JPG)

  *VBR above saved & opened with [Active Disk Editor](http://www.disk-editor.org/)*
  ![VbrinActiveDiskEditor](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/pd1.JPG)
  
  *Mbr log entry (copy/pasted to [HxD](https://mh-nexus.de/en/hxd/))*
  ![MBR](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/mb.JPG)
  
  *GPT Partition table entry of same drive in [Active Disk Editor](http://www.disk-editor.org/)*
  ![MbrinActiveDiskEditor](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/mb1.JPG)

###  Win 10 Security.evtx EventID: 4688 parser  ###

- [Win 10 EventID: 4688 parser](https://github.com/kacos2000/Win10-Research/blob/master/EventLogs/ProcessCreatedEvents.ps1) - PowerShell script to read a live or offline **security.evtx** log and list all the [EventID:4688](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4688) entries *(A new process has been created)* in a window. 

###  Win 10 Security.evtx EventID: 4624 parser  ###

- [Win 10 EventID: 4624 parser](https://github.com/kacos2000/Win10-Research/blob/master/EventLogs/LoginEvents.ps1) - PowerShell script to read a live or offline **security.evtx** log and list all the [EventID:4624](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624) entries *(An account was successfully logged on)* in a window. Selected rows are saved in a comma separated file (csv).  

###  Win 10 Security.evtx EventID: 4616 & System.evtx EventID: 1 parser ###

- [Win 10 Security EventID: 4616 & System EventID: 1 parser](https://github.com/kacos2000/Win10-Research/blob/master/EventLogs/TimeEventsAll.ps1) - PowerShell script to read both **security.evtx** and **system.evtx** logs from a live or offline Win 10 PC, and list all the [EventID:1](http://www.eventid.net/display-eventid-1-source-Microsoft-Windows-Kernel-General-eventno-10866-phase-1.htm) and [EventID:4616](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4616) entries *(The system time was changed)* in a window. Selected rows are saved in a comma separated file (csv).  
  
  The [script](https://github.com/kacos2000/Win10-Research/blob/master/EventLogs/TimeEventsAll.ps1) *(needs to be executed from an Administrator console)*. 

  - Event Providers *(type the following in a powershell prompt to see the event template)*: 
     - "Microsoft-Windows-Kernel-General" (ID: 1)<br>
        `(Get-WinEvent -ListProvider "Microsoft-Windows-Kernel-General").Events|Where-Object {$_.Id -eq 1}`<br>
        
        * Event **Reason** Nr#:<br>
          1 = An application or system component changed the time<br>
          2 = System time synchronized with the hardware clock<br>
          3 = System time adjusted to the new time zone
      
     - "Microsoft-Windows-Security-Auditing" (ID: 4616)<br>
        `(Get-WinEvent -ListProvider "Microsoft-Windows-Security-Auditing").Events|Where-Object {$_.Id -eq 4616}`

###  Win 10 Security.evtx EventID: 4616 parser  ###

- [Win 10 EventID: 4616 parser](https://github.com/kacos2000/Win10-Research/blob/master/EventLogs/TimeEvents.ps1) - PowerShell script to read a live or offline **security.evtx** log and list all the [EventID:4616](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4616) entries *(The system time was changed)* in a window. Selected rows are saved in a comma separated file (csv).  

   The [script](https://github.com/kacos2000/Win10-Research/blob/master/EventLogs/TimeEvents.ps1) *(needs to be executed from an Administrator console)* will parse the following information for any 4616 event ID:

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
      
       ![File Open](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/O.JPG)
  
    - [EventID 4616](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4616) The system time was changed
    - [EventID 4624](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624) An account was successfully logged on
    - [EventID 4688](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4688) A new process has been created
    - [Are Windows timezone written in registry reliable?](https://stackoverflow.com/questions/47104967/are-windows-timezone-written-in-registry-reliable)
    - `tzutil  /l` : List timezones
    - [Finding	Advanced Attacks and Malware With Only 6 Windows EventID’s (pdf)](https://conf.splunk.com/session/2015/conf2015_MGough_MalwareArchaelogy_SecurityCompliance_FindingAdvnacedAttacksAnd.pdf)
  
  __________________
   
     Original idea came from the [Jaco](https://twitter.com/jaco_ZA/status/1015495669988122624)'s ["Detecting Time Changes with L2T"](https://www.dfir.co.za/2018/07/07/detecting-time-changes-with-l2t-aint-nobody-got-time-for-that/) *blog post*.
   
     ![File Open](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/T.JPG)
   
  __________________
   
     - To Do:
       - [X] Parse 4616
       - [X] Parse 4624/4528/4540 (Audit Logon = Success & Failure)
       - [X] Check / Parse 4625
       - [ ] Check / Parse 4648
       - [ ] Check / Parse 4663/4567 (Audit File	System	=	Success, (Audit Registry =	Success ) )
       - [ ] Check / Parse 4675
       - [X] Check / Parse 4688 (Audit Process Creation =	Success)
       - [ ] Check / Parse 5140/5560 (Audit File	Share	=	Success )
       - [ ] Check / Parse 5156 (Audit Filtering Platform Connection = Succes)
       - [ ] Check / Parse 7045/7040 
       - [ ] ~~Correlate event id entries in 4616, 4624, 4688 etc~~
       - [X] Check Event ID 1006 of Microsoft-Windows-Partition%4Diagnostic.evtx [(USB Device Tracking ..)](https://df-stream.com/2018/07/partition-diagnostic-event-log-and-usb-device-tracking-p2/)
      
