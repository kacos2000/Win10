<!-- saved from url=(0054) https://kacos2000.github.io/Win10-Research/EventLogs/ --> 
<!-- https://guides.github.com/features/mastering-markdown/ --> 

###  Win 10 Security.evtx EventID: 4616 & System.evtx EventID: 1 parser ###

- [Win 10 Security EventID: 4616 & System EventID: 1 parser](https://github.com/kacos2000/Win10-Research/blob/master/EventLogs/TimeEventsAll.ps1) - PowerShell script to read both **security.evtx** and **security.evtx** logs from a live or offline Win 10 PC, and list all the [EventID:1](http://www.eventid.net/display-eventid-1-source-Microsoft-Windows-Kernel-General-eventno-10866-phase-1.htm) and [EventID:4616](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4616) entries *(The system time was changed)* in a window. Selected rows are saved in a comma separated file (csv).  



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
  
  - [EventID 4616](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4616)  
  - [EventID 4688](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4688)
  
  __________________
   
   Original idea came from the [Jaco](https://twitter.com/jaco_ZA/status/1015495669988122624)'s ["Detecting Time Changes with L2T"](https://www.dfir.co.za/2018/07/07/detecting-time-changes-with-l2t-aint-nobody-got-time-for-that/) *blog post*.
   
   ![File Open](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/T.JPG)
   
  __________________
   
