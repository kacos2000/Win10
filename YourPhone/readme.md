## Windows 10 1809/1903: YourPhone app ##

In Windows 10 1809 *(Oct 2018 version upgrade)* the new [YourPhone app](https://www.microsoft.com/en-us/p/your-phone/9nmpj99vjbwv?ocid=AID681541_aff_7593_1243925&activetab=pivot:overviewtab) allows a user to synchronise Messages & Contacts and the most recent 25 Photos in an Android phone with a Win10 workstation. The folder **"C:\Users\%username%\AppData\Local\Packages\Microsoft.YourPhone_8wekyb3d8bbwe\LocalCache\Indexed\<GUID>\System\Database\"** has the **Phone.db**, an SQLite database with all synchronised messages & contacts.
   
   ![dB](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/PhonedBJPG.JPG)

  * SQLite query to view the [**Contacts**](https://github.com/kacos2000/Win10/blob/master/YourPhone/phonedb_contacts.sql)<br>
  
     Contacts as displayed in the App:<br>
     ![Contacts](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/Contacts.JPG)

   * SQLite query to view the  [**SMS Messages**](https://github.com/kacos2000/Win10/blob/master/YourPhone/phonedb_messages.sql)

     Messages as displayed in the App:<br>
     ![Messages](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/messages.JPG)

     Photos as seen in the App:<br>
     ![Photos in App](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/Photos.JPG)

     Photos as seen in the "**C:\Users\%UserName%\AppData\Local\Packages\Microsoft.YourPhone_8wekyb3d8bbwe\LocalCache\Indexed\1C8ABB45-8138-4600-8CA0-13FD3A82F826\User\%PhoneName%\Recent Photos**" folder:<br>

     ![Photos in Folder](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/Photos1.JPG)
     
     
     *(Tested with Win 10 version 1809 (Build 17755.1) & Win10 version 1903 (Build 18875.1000) &Android 7.1.1)*<br>

   * SQLite query to view the  [**Notifications**](https://github.com/kacos2000/Win10/blob/master/YourPhone/phone_notifications.sql) which is still in beta (v1903)<br>
   ![hint](https://raw.githubusercontent.com/kacos2000/Win10/master/YourPhone/notif.JPG)
