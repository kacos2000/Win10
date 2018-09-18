 ### Object IDs ###
 
  - **[ObjectID.ps1](https://github.com/kacos2000/Win10/blob/master/ObjectID/ObjectID.ps1)**  -  powershell script listing the NTFS $MFT [ObjectID](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/ntifs/ns-ntifs-_file_objectid_information)'s of files in selected Folder & subfolders. *The idea came from [Phil Moore](https://github.com/randomaccess3)'s [Python script](https://github.com/randomaccess3/SundayFunday/blob/master/ListObjectIDs/allObjectIDs.py)*. The script uses the "[fsutil objectid](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/fsutil-objectid) query" command. **Note:** Must be run as an Administrator.<br>

     Output example:<br>

     Field | Value
     :---- | :-----
     Path                | D:\Temp\jpg<br>
     File/Directory Name | Image.JPG<br>
     ObjectID            | 18f51114-187f-e811-aa2b-18dbf227d093<br>
     BirthVolume ID      | 8a289a36-3d3f-b549-a555-3cf5f3bcf201<br>
     BirthObject ID      | 18f51114-187f-e811-aa2b-18dbf227d093<br>
     Domain ID           | 00000000-0000-0000-0000-000000000000<br><br>

     - **Birth Volume Id**: Birth Volume Id is the Object Id of the Volume on which the Object Id was allocated. It never changes.<br>
     - **Birth Object Id**: Birth Object Id is the first Object Id that was ever assigned to this MFT Record. I.e. If the Object Id is changed for some reason, this field will reflect the original value of the Object Id.<br>
 
   - **[FILETIME Extractor](http://www.kazamiya.net/en/fte)** - "fte(FILETIME Extractor) gets accurate timestamps and several information on NTFS." parses NTFS internal files like $MFT file, $ObjID file, $INDX_ALLOCATION attribute. Supports mounted drives (eg FTK mounted images) also.
  
     ![Sample from Lone Wolf scenario E01](https://raw.githubusercontent.com/kacos2000/Win10/master/ObjectID/fte_lw.JPG)
 

- **[USN.ps1](https://github.com/kacos2000/Win10/blob/master/ObjectID/USN.ps1)** - Powershell script to parse a local or mounted drive and save the $USN journal to a comma separated file. The script uses the "[fsutil usn](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/fsutil-usn) readjournal driveletter csv" command.<br>

  
- **[NTFS.ps1](https://github.com/kacos2000/Win10/blob/master/ObjectID/NTFS.ps1)** - Powershell script to get NTFS information from a local or mounted drive and get user readable results. The last 4 bytes of the Volume Serial number is the [Serial Number](https://en.wikipedia.org/wiki/Volume_serial_number) used by Windows OS. *[(The serial number is a function of
the time/date of the formatting or the diskcopying.)](http://www.faqs.org/faqs/assembly-language/x86/general/part3/)*  The script uses the "[fsutil fsinfo](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/fsutil-fsinfo) ntfsinfo driveletter" command.<br>  
   
   - sample output:
   
     Name                            | Value
     :------                         | :------
     NTFS Volume Serial Number       | B05E-A304-**5EA2-C288**
     NTFS Version                    | 3
     LFS Version                     | 2
     Number Sectors                  | 34.815
     Total Clusters                  | 4.351
     Free Clusters                   | 2.854
     Total Reserved                  | 1.024
     Bytes Per Sector                | 512
     Bytes Per Physical Sector       | 4096
     Bytes Per Cluster               | 4096
     Bytes Per FileRecord Segment    | 1024
     Clusters Per FileRecord Segment | 0
     Mft Valid Data Length           | 262.144
     Mft Start Lcn                   | 1.450
     Mft2 Start Lcn                  | 2
     Mft Zone Start                  | 1.440
     Mft Zone End                    | 2.016
     Max Device Trim Extent Count    | 4.096
     Max Device Trim Byte Count      | 4.294.967.295
     Max Volume Trim Extent Count    | 62
     Max Volume Trim Byte Count      | 1.073.741.824


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
