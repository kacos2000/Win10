 ### Object IDs ###
 
**[ObjectID.ps1](https://github.com/kacos2000/Win10/blob/master/ObjectID/ObjectID.ps1)**  -  powershell script listing the NTFS $MFT ObjectID's of files in selected Folder & subfolders. <br>
**Note:** Must be run as an Administrator<br>

The script uses the "[fsutil.exe](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/fsutil) objectid query" command.<br>

Output example:<br>

Path                : D:\Temp\jpg<br>
File/Directory Name : Image.JPG<br>
ObjectID            : 18f51114-187f-e811-aa2b-18dbf227d093<br>
BirthVolume ID      : 8a289a36-3d3f-b549-a555-3cf5f3bcf201<br>
BirthObject ID      : 18f51114-187f-e811-aa2b-18dbf227d093<br>
Domain ID           : 00000000-0000-0000-0000-000000000000<br>


*The idea came from [Phil Moore](https://github.com/randomaccess3)'s [Python script](https://github.com/randomaccess3/SundayFunday/blob/master/ListObjectIDs/allObjectIDs.py)*<br>
