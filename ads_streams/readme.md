<!-- saved from url=(0023) https://kacos2000.github.io/Win10-Research/ads_streams/ --> 
<!-- https://guides.github.com/features/mastering-markdown/ --> 

**[Zone.Identifier ADS view](https://github.com/kacos2000/Win10-Research/blob/master/ads_streams/streams.ps1)** PowerShell script to list the Zone.Identifier ADS contents of files in a folder.  More info at [Phill Moore's blog](https://thinkdfir.com/2018/06/17/zone-identifier-kmditemwherefroms/) and at [Hacking Exposed](http://www.hecfblog.com/2018/06/daily-blog-402-solution-saturday-62318.html).

   The [script](https://github.com/kacos2000/Win10-Research/blob/master/ads_streams/streams.ps1) *(preferably executed in an Administrator console)* will parse recursively any selected folder and provide:

   -  Field                     | Description
      ------------              | -------------
      Path                      | File path
      File/Directory Name       | File or subdirectory name
      MD5 Hash (File Hash only) | The MD5 hash of the File
      Owner / sid               | The owner (name if run on local machine) or SID descriptor
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
   
   
   - *[Text file output]("https://raw.githubusercontent.com/kacos2000/Win10-Research/master/ads_streams/streams%2002-07-2018%2007-44.txt")* 
   
       Sample text file: ![txt file](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/ads_streams/txt.JPG)
       
       
     
       
         
