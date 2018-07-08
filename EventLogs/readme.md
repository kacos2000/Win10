<!-- saved from url=(0023) https://kacos2000.github.io/Win10-Research/EventLogs/ --> 
<!-- https://guides.github.com/features/mastering-markdown/ --> 

**[Win 10 Event log ID: 4616 parser.](https://github.com/kacos2000/Win10-Research/blob/master/EventLogs/TimeEvents.ps1)** PowerShell script to read a live or offline **security.evtx** log and list all the EventID:4616 entries *(The system time was changed)* in a window. Selected rows are saved in a comma separated file (csv).  

   The [script](https://github.com/kacos2000/Win10-Research/blob/master/EventLogs/TimeEvents.ps1) *(needs to be executed from an Administrator console)* will parse the following information for any 4616 event ID:

   -  Field              | Description
      ------------       | -------------
      Time Created       | DateTime the event was recorded
      EventRecordID      | Record ID of the Event
      ProcessID          | Process ID
      ThreadID           | Thread ID
      User Name          | UserName associated with the event 
      SID                | SID descriptor
      Domain Name        | Domain Name
      New Time           | New Time
      Previous Time      | Previous Time
      Change             | Difference between New and Previous times
      Process Name       | The process that initiated the Time change 
      
   ![File Open](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/O.JPG)
   
   
   Original idea came from the [Swanepoel Method blog post](https://www.dfir.co.za/2018/07/07/detecting-time-changes-with-l2t-aint-nobody-got-time-for-that/).
   
   ![File Open](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/EventLogs/T.JPG)
   
