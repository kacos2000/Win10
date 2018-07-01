**Windows 10 *(1703+)* Background Activity Moderator**

- [**BAMparser.ps1** - PowerShell script](https://github.com/kacos2000/Win10-Research/blob/master/Bam/BAMParser.ps1) by [Matthew Green](https://github.com/mgreen27) *(original is [here](https://github.com/mgreen27/Powershell-IR/blob/master/Content/Other/BAMParser.ps1))* for live parsing of the BAM service key:

  ![BAMparser.ps1 results](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Bam/utc_results.JPG)


- [**bam.ps1** - Modification of the above script](https://github.com/kacos2000/Win10-Research/blob/master/Bam/bam.ps1) to get the results in a pop-up Window with Filestamps in locatime

  ![bam.ps1 results](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Bam/results.JPG)

  User can select all lines (Ctrl+A) or specific lines (Ctrl+click) and copy/paste (Ctrl+C and Ctrl+V) the data to a text file or MS Excel  spreadsheet. The Selected lines are also displayed in the console after the user presses the OK button.

  ![bam.ps1 console](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Bam/console.JPG)
  
-  [**bamoffline.ps1** - Offline parser of the BAM key](https://github.com/kacos2000/Win10-Research/blob/master/Bam/bamoffline.ps1) Parse an **offline** system hive *(SYSTEM)* and get the results in a pop-up Window with Filestamps in locatime. The script asks the user to select a *SYSTEM* hive file

    ![Select SYSTEM hive](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Bam/select.JPG)

    Calculates the SHA1 hash of the *SYSTEM* hive file and opens it (Read Only). The results are shown in a popup window with Filestamp in user localtime. User can select all lines (Ctrl+A) or specific lines (Ctrl+click) and copy/paste (Ctrl+C and Ctrl+V) the data to a text file or MS Excel spreadsheet. The Selected lines are also displayed in the console after the user presses the OK button.
  
   ![Offline results](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Bam/o_results.JPG)
  
   After result window is closed (user presses the OK button), a new SHA1 hash of the *SYSTEM* hive file is computed and checked against the original:
  
   ![Offline console](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Bam/o_console.JPG)
  

- [**Documentation**](https://github.com/kacos2000/Win10-Research/blob/master/Bam/BAM%20-%20Background%20Activity%20Moderator.pdf) of the Background Activity Moderator service key


To Do
- [x] Live Parser 
- [x] Offline SYSTEM hive parser
