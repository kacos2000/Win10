<!-- saved from url=(0054) https://kacos2000.github.io/Win10-Research/EventLogs/ --> 
<!-- https://guides.github.com/features/mastering-markdown/ --> 

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
  
  __________________
   
     Original idea came from the [Jaco](https://twitter.com/jaco_ZA/status/1015495669988122624)'s ["Detecting Time Changes with L2T"](https://www.dfir.co.za/2018/07/07/detecting-time-changes-with-l2t-aint-nobody-got-time-for-that/) *blog post*.
   
     ![File Open](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/T.JPG)
   
  __________________
   
     - To Do:
       - [X] Parse 4624
       - [ ] Check / Parse 4625
       - [ ] Check / Parse 4648
       - [ ] Check / Parse 4675 
       - [ ] ~~Correlate event id entries in 4616, 4624, 4688 etc~~
       - [ ] Check Event ID 1006 of Microsoft-Windows-Partition%4Diagnostic.evtx [(USB Device Tracking ..)](https://df-stream.com/2018/07/partition-diagnostic-event-log-and-usb-device-tracking-p2/)
      
