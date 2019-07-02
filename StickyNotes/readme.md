### Microsoft Sticky Notes ###

![](https://i2.wp.com/techrad.io/wp-content/uploads/2018/11/Sticky-Notes.png?w=630&ssl=1)<br>
App available [in the MS Store](https://www.microsoft.com/en-us/p/microsoft-sticky-notes/9nblggh4qghw?activetab=pivot:overviewtab)<br>
<br>
- Application folder:<br>
       C:\Users\%username%\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe<br>
- Database:<br>
        C:\Users\%username%\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\plum.sqlite<br>
- Media folder:<br>
        C:\Users\%username%\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\media<br>
- SQLite query for [Plum.sqlite](https://github.com/kacos2000/Win10/blob/master/StickyNotes/StickyNotes_plum_sqlite.sql)<br>

Note: the query gets only a few of the possible data for each note. You should manually examine the following fiels of the 'Note' table:

   - Text   *(Showing entries like)*: <br>
       \id=b20ba1c4-a202-4bda-8f38-7d4569308298 json field <br>
       \id=d8807874-22dd-41a1-bb30-081c4c22dc79  <br>
       \id=8eb848de-117f-432f-8aa5-d2262a79431a Edit remotely <br>
   
   - LastServerVersion *(which has a json with the full note data)*: <br> <br>
   
     ![json](https://raw.githubusercontent.com/kacos2000/Win10/master/StickyNotes/json.JPG)
