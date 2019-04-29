
<!-- saved from url=(0059) https://kacos2000.github.io/Win10/Notifications/ --> 

# Windows 10 - Notifications #

   - *Definitions:*
       * *A [tile](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/tile-schema) is an app's representation on the Start menu. Every UWP app has a tile - sizes: small, medium, wide, and large.*
       * *A [badge](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/badges) provides status or summary info in the form of a system-provided glyph or a number from 1-99.*
       * *A [toast](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/toast-schema) notification is a notification a UWP app sends to the user via a pop-up UI element (toast or banner).*
______________________________________________________________________________________________________   

   - Time notifications were last seen by the user:<br> 
NTUSER.dat - \Software\Microsoft\Windows\CurrentVersion\Notifications - ValueName: TimestampWhenSeen Value:(Filetime)
______________________________________________________________________________________________________   

 - [**Notifications.sql**](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/Notifications.sql)<br> SQLite query to parse the Windows 10 Notifications Wpndatabase.
  
    ![Preview](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/Not.JPG)
  
 - [**Notifications.ps1**](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/Notifications.ps1)
    <br> Powershell script to parse the Windows 10 Notifications Wpndatabase as well as information from the XML blobs: 
      **UPDATED** - Toasts, Tiles & Badges now work ok *(till proven otherwise)* :)
   - ![Preview1](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps1.JPG)
   - ![Preview2](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps2.JPG)
   - ![Preview3](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps3.JPG)
   - ![Preview4](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps4.JPG)
  
  
 - [**wpn.ps1**](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/wpn.ps1)<br> Powershell script to parse NTUSER.dat 
  (\Software\Microsoft\Windows\CurrentVersion\PushNotifications\wpnidm) entries:
  
   ![wpn](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps0a.JPG)
  
   How the output of [Notifications.ps1](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/Notifications.ps1) & [wpn.ps1](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/wpn.ps1) are linked together:
   ![wpn/notifications Link](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps0.JPG)
  
  
  - [**PushBackup.ps1**](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/PushBackup.ps1)<br> 
   Powershell script to parse NTUSER.dat 
  (Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup) entries:
   ![PushNotifications Backup](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/B1.JPG)
   
   - [**PushBackup.sql**](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/PushBackup.sql)<br> 
     SQLite query to parse the *(Windows 10 Notifications Wpndatabase)* WNSPushChannel table.
   
     Comparison of the results of [PushBackup.sql](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/PushBackup.sql) and [PushBackup.ps1](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/PushBackup.ps1):
     ![PushNotifications Backup](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/B2.JPG)
______________________________________________________________________________________________________   
   * **[Microsoft Notifications Visualizer:](https://www.microsoft.com/en-us/p/notifications-visualizer/9nblggh5xsl1?rtc=1)**
     
     * A very usefull app *(MS Store)* - Simply create a new document, and copy/paste the XML Blob from the database:
   
       *DB Browser for SQLite:*<br>
       ![DB Browser for SQLite](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/v1.JPG)
     
      *Visualizer Window:*<br>
     ![Visualizer Window](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/v2.JPG)
 
______________________________________________________________________________________________________  
  **Other Information:**
  
  - Database location: C:\Users\%username%\AppData\Local\Microsoft\Windows\Notifications\wpndatabase.db  
  - Backup (settings): 
     * **NTUSER.DAT: Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup** 
     ![](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/wfn1.JPG)
  
  - Image store location: C:\Users\%username%\AppData\Local\Microsoft\Windows\Notifications\wpnidm:
  
     * NTUSER.DAT: Software\Microsoft\Windows\CurrentVersion\PushNotifications\wpnidm   
     ![Notifications](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/wpnidm.JPG)
     * image: link image to application 
     ![Notifications1](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/wpnidm1.JPG)
     * image folder view
     ![Notifications1](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/wpnidm2.JPG)
     * Expiration Date of Notification related to the image (Filetime):<br>
     ![Notifications1](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/wpnidm3.JPG)
     
   - **Typical XML blob structure:**
  
     | Badge      | Tile    | Toast     
     | :---:      | :---:   | :---:    
     |            |         |            
     | ![b](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/x1.JPG) | ![t](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/x2.JPG) | ![t](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/x3.JPG)
  
  ______________________________________________________________________________________________________  
  
   * **References:**
      - [Win10 'YourPhone' app, Notifications & Timeline - A quick test](https://www.linkedin.com/pulse/win10-yourphone-app-notifications-timeline-quick-katsavounidis/)   
      - [Microsoft Notifications Visualizer](https://www.microsoft.com/en-us/p/notifications-visualizer/9nblggh5xsl1?rtc=1)
      - [Toast content](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/adaptive-interactive-toasts)
      - [Toast content schema](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/toast-schema)
      - [Tiles for UWP apps](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/creating-tiles)
      - [Badge notifications for UWP apps](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/badges)
      - [Notification delivery method](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/choosing-a-notification-delivery-method)
      - [Create adaptive tiles](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/create-adaptive-tiles)
      - [**By default, tile and badge notifications expire three days after being downloaded**. When a notification expires, the content is removed from the tile or queue and is no longer shown to the user. ](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/windows-push-notification-services--wns--overview)
