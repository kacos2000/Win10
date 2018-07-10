<!-- saved from url=(0056) https://kacos2000.github.io/Win10-Research/ads_streams/ --> 
<!-- https://guides.github.com/features/mastering-markdown/ --> 

# [ADS Streams view](https://github.com/kacos2000/Win10-Research/blob/master/ads_streams/streams.ps1) #

PowerShell script to list [Alternate Data Stream](https://blogs.technet.microsoft.com/askcore/2013/03/24/alternate-data-streams-in-ntfs/) *(NTFS)* and view the Zone.Identifier contents of files in a folder.  

   The [script](https://github.com/kacos2000/Win10-Research/blob/master/ads_streams/streams.ps1) *(preferably executed in an Administrator console)* will parse recursively any selected folder and provide:

   -  Field                     | Description
      ------------              | -------------
      Path                      | File path
      File/Directory Name       | File or subdirectory name
      MD5 Hash (File Hash only) | The MD5 hash of the File
      Owner / sid               | The owner name *(if run on local machine)* or SID descriptor
      Length                    | File Size
      LastWriteTime             | Last time file was written
      Attributes                | File Attributes
      Stream1                   | Alternate Data Stream 1 (usually :$Data)
      Stream2                   | Alternate Data Stream 2
      Stream3                   | Alternate Data Stream 3
      ZoneId1                   | Zone.Identifier *(if exists)* entry 1
      ZoneId2                   | Zone.Identifier *(if exists)* entry 2
      ZoneId3                   | Zone.Identifier *(if exists)* entry 3
      ZoneId4                   | Zone.Identifier *(if exists)* entry 4


   - *File Open Dialog:* User is asked to select a folder:
  
      ![File Open](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/ads_streams/s_o.JPG)
   

   - *Results window:* The outcome - user has the option to sort the results by clicking on a column. User can select all lines (Ctrl+A) or specific lines (Ctrl+click) and copy/paste (Ctrl+C and Ctrl+V) the data to a text file or MS Excel spreadsheet. The Selected lines are saved to a text file after the user presses the OK button.
  
      ![Results](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/ads_streams/s_results.JPG)
   
   
   - *[Text file output](streams%2002-07-2018%2007-44.txt)* 
   
       ![txt file](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/ads_streams/txt.JPG)
       
       
     
   - **References:**<br> 
   
      Zone.Identifier Zones:
   
       **ZoneID** | **Description**
        -- | -----
        0 | Computer
        1 | Local intranet
        2 | Trusted sites
        **3** | **Internet**
        4 | Restricted sites
      
      - [Mark of the Web](https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/compatibility/ms537628(v=vs.85))<br>
      - [Internet Explorer Local Machine Zone Lockdown](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc782928(v=ws.10))<br> 
      - [About URL Security Zones](https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms537183(v=vs.85))<br>
      - [URL Policy Flags](https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms537179%28v%3dvs.85%29)<br>
      - [Adding Sites to the Enhanced Security Configuration Zones](https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms537181(v%3dvs.85))<br>
      - [Zone Identifier == kMDItemWhereFroms?](https://thinkdfir.com/2018/06/17/zone-identifier-kmditemwherefroms/)<br>
      - [Hacking Exposed](http://www.hecfblog.com/2018/06/daily-blog-402-solution-saturday-62318.html)<br>
      - [The Tale of SettingContent-ms Files](https://posts.specterops.io/the-tale-of-settingcontent-ms-files-f1ea253e4d39?gi=57a1d1779f80)
