## Windows 10 1809/1903: YourPhone app ##

In Windows 10 1809 *(Oct 2018 version upgrade)* the new [YourPhone app](https://www.microsoft.com/en-us/p/your-phone/9nmpj99vjbwv?ocid=AID681541_aff_7593_1243925&activetab=pivot:overviewtab) allows a user to synchronise Messages & Contacts and the most recent 25 Photos in an Android phone with a Win10 workstation. The folder **"C:\Users\ %username%\AppData\Local\Packages\Microsoft.YourPhone_8wekyb3d8bbwe\LocalCache\Indexed\GUID\System\Database\"** has the **Phone.db**, an SQLite database with all synchronised messages & contacts.
   
   ![dB](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/PhonedBJPG.JPG)

  * SQLite query to view the [**Contacts**](https://github.com/kacos2000/Win10/blob/master/YourPhone/phonedb_contacts.sql)<br>
  
     Contacts as displayed in the App:<br>
     ![Contacts](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/Contacts.JPG)

   * SQLite query to view the  [**SMS Messages**](https://github.com/kacos2000/Win10/blob/master/YourPhone/phonedb_messages.sql)

     Messages as displayed in the App:<br>
     ![Messages](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/messages.JPG)

     Photos as seen in the App:<br>
     ![Photos in App](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/Photos.JPG)<br>
      *Note: [.heic](https://en.wikipedia.org/wiki/High_Efficiency_Image_File_Format) images are synced (can be found in the 'Recent Photos' folder as seen below), but are not displayed in YourPhone's app window.*

     Photos as seen in the "**C:\Users\ %UserName% \AppData\Local\Packages\Microsoft.YourPhone_8wekyb3d8bbwe\LocalCache\Indexed\GUID\User\PhoneName\Recent Photos**" folder:<br>

     ![Photos in Folder](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/Photos1.JPG)
         
     
     *(Tested with Win 10 version 1809 (Build 17755.1) & Win10 version 1903 (Build 18875.1000) &Android 7.1.1)*<br>

   * SQLite query to view the  [**Notifications**](https://github.com/kacos2000/Win10/blob/master/YourPhone/phone_notifications.sql) found at **"C:\Users\ %username% \AppData\Local\Packages\Microsoft.YourPhone_8wekyb3d8bbwe\LocalCache\Indexed\GUID\System\Database\Notifications.db"** <br>
     ![hint](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/notif.JPG)

   * Separate folders (GUID) for each connected phone:<br>
   
     ![folders](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/y1.JPG)
   
   * Settings.db lists all the applications installed on the phone, their version number, and icon (blob):</br>
   
     ![Applications](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/y2.JPG)
