
<!-- saved from url=(0059) https://kacos2000.github.io/Win10-Research/Notifications/ --> 

# Windows 10 - Notifications #

  [Notifications_WPNdatabase.sql](https://github.com/kacos2000/Win10-Research/blob/master/Notifications/Notifications_WPNdatabase.sql)<br> SQLite query to parse the Windows 10 Notifications Wpndatabase.
  
  ![Preview](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/Notifications/Not.JPG)
  
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
