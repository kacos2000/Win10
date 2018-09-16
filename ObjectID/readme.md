 ### Object IDs ###
 
  - **[ObjectID.ps1](https://github.com/kacos2000/Win10/blob/master/ObjectID/ObjectID.ps1)**  -  powershell script listing the NTFS $MFT [ObjectID](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/ntifs/ns-ntifs-_file_objectid_information)'s of files in selected Folder & subfolders. *The idea came from [Phil Moore](https://github.com/randomaccess3)'s [Python script](https://github.com/randomaccess3/SundayFunday/blob/master/ListObjectIDs/allObjectIDs.py)*. **Note:** Must be run as an Administrator<br>

     The script uses the "[fsutil.exe](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/fsutil) objectid query" command.<br>

     Output example:<br>

     Field | Value
     :---- | :-----
     Path                | D:\Temp\jpg<br>
     File/Directory Name | Image.JPG<br>
     ObjectID            | 18f51114-187f-e811-aa2b-18dbf227d093<br>
     BirthVolume ID      | 8a289a36-3d3f-b549-a555-3cf5f3bcf201<br>
     BirthObject ID      | 18f51114-187f-e811-aa2b-18dbf227d093<br>
     Domain ID           | 00000000-0000-0000-0000-000000000000<br>


     - **Birth Volume Id**: Birth Volume Id is the Object Id of the Volume on which the Object Id was allocated. It never changes.<br>
     - **Birth Object Id**: Birth Object Id is the first Object Id that was ever assigned to this MFT Record. I.e. If the Object Id is changed for some reason, this field will reflect the original value of the Object Id.<br>
  

- **[USN.ps1](https://github.com/kacos2000/Win10/blob/master/ObjectID/USN.ps1)** - Powershell script to parse a local or mounted drive and save the $USN journal to a comma separated file. <br>

  The script uses the "[fsutil.exe](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/fsutil) usn readjournal driveletter csv" command.<br>


- **References #1:**<br>
   *[Object Identifiers](https://docs.microsoft.com/en-us/windows/desktop/FileIO/distributed-link-tracking-and-object-identifiers)*

   The link tracking service maintains its link to an object by using an object identifier (ID). An object ID is an optional attribute that uniquely identifies a file or directory on a volume.

   An index of all object IDs is stored on the volume. Rename, backup, and restore operations preserve object IDs. However, copy operations do not preserve object IDs, because that would violate their uniqueness.

   You can perform the following operations on object IDs:

       Creation
       Deletion
       Query

   When you create an object ID, you establish the identity of the file to the link tracking service. Conversely, when you delete an object ID, the link tracking service stops maintaining links to the file.


- **References #2:**<br>
   [NTFS File Attributes](https://blogs.technet.microsoft.com/askcore/2010/08/25/ntfs-file-attributes/)<br>
   [_FILE_OBJECTID_INFORMATION structure](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/ntifs/ns-ntifs-_file_objectid_information)<br>
