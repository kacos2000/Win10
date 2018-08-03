
<!-- saved from url=(0059) https://kacos2000.github.io/Win10-Research/Notifications/ --> 

# Windows 10 - Notifications #

 - [Notifications_WPNdatabase.sql](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/Notifications_WPNdatabase.sql)<br> SQLite query to parse the Windows 10 Notifications Wpndatabase.
  
  ![Preview](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/Not.JPG)
  
 - [Notifications.ps1](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/Notifications.ps1)<br> Powershell script to parse the Windows 10 Notifications Wpndatabase as well as information from the XML blobs:
   1. ![Preview1](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps1.JPG)
   2. ![Preview2](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps2.JPG)
   3. ![Preview3](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps3.JPG)
   4. ![Preview4](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps4.JPG)
  
 - [wpn.ps1](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/wpn.ps1)<br> Powershell script to parse NTUSER.dat 
  (\Software\Microsoft\Windows\CurrentVersion\PushNotifications\wpnidm) entries:
  
   ![wpn](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps0a.JPG)
  
   How the output of [Notifications.ps1](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/Notifications.ps1) & [wpn.ps1](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/wpn.ps1) are linked together:
  ![wpn/notifications Link](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/ps0.JPG)
  
  
  **Other Information:**
  
  - Database location: C:\Users\%username%\AppData\Local\Microsoft\Windows\Notifications\wpndatabase.db  
  - Backup (settings): NTUSER.DAT: Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup  
  - Image store location: C:\Users\%username%\AppData\Local\Microsoft\Windows\Notifications\wpnidm:
  
     - NTUSER.DAT: Software\Microsoft\Windows\CurrentVersion\PushNotifications\wpnidm   
     ![Notifications](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/wpnidm.JPG)
     - image: link image to application 
     ![Notifications1](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/wpnidm1.JPG)
     - image folder view
     ![Notifications1](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/wpnidm2.JPG)
     - Expiration Date of Notification related to the image (Filetime):<br>
     ![Notifications1](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/wpnidm3.JPG)
     
   - **Typical XML blob structure:**
  
     | Badge      | Tile       
     | :---:      | :---:    
     |            |            
     | ![b](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/x1.JPG) | ![t](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/x2.JPG)
  
  
