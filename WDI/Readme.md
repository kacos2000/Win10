### Windows Diagnostics Infrastructure ###
**Path**: "\Windows\System32\WDI"

  - **[WDI.ps1](https://github.com/kacos2000/Win10/blob/master/WDI/WDI.ps1)**  - Powershell script that uses [Microsoft TraceRpt.Exe](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/tracerpt_1) to convert all Event Trace Logs *(.ETL)* of the target "\Windows\System32\WDI" folder to the respective summary.txt and eventlog.csv (comma separated file). It also copies the StartupInfo folder and it's contents. Target output folder is the user's 'Desktop\WDI_currentdatetime'. 
  
    - **Sample images:**
      
      Source of the test image file: [LoneWolf.E01 Scenario](https://digitalcorpora.org/corpora/scenarios/2018-lone-wolf-scenario)<br>
      
      Snapshot.etl <br>
      
      ![Snapshot.etl](https://raw.githubusercontent.com/kacos2000/Win10/master/WDI/s_txt.JPG)
      
      S-1-5-21-2734969515-1644526556-1039763013-1001_StartupInfo3.xml <br>
      
      ![S-1-5-21-2734969515-1644526556-1039763013-1001_StartupInfo3.xml](https://raw.githubusercontent.com/kacos2000/Win10/master/WDI/Logfiles_xml.JPG)
      
      
      Logfiles\StartupInfo contents from the same image file as above<br>
      Each has the Startup tasks & processes (Run/RunOnce, etc) per user (SID filename)
      
      ![StartupInfo](https://raw.githubusercontent.com/kacos2000/Win10/master/WDI/Logfiles.JPG)
      
      
