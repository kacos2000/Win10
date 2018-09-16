 ### Object IDs ###
 
**[ObjectID.ps1](https://github.com/kacos2000/Win10/blob/master/ObjectID/ObjectID.ps1)**  -  powershell script listing the NTFS $MFT ObjectID's of files in selected Folder & subfolders. <br>
**Note:** Must be run as an Administrator<br>

The script uses the "[fsutil.exe](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/fsutil) objectid query" command.<br>

Output values include:<br>

Path                : D:\User\Desktop\Export<br>
File/Directory Name : Test<br>
ObjectID            : 6a6e640572fe811a9d39cb6d061df70<br>
BirthVolume ID      : 8a289a363d3fb549a5553cf5f3bcf201<br>
BirthObject ID      : b6a6e640572fe811a9d39cb6d061df70<br>
Domain ID           : 00000000000000000000000000000000<br>


*The idea came from [Phil Moore](https://github.com/randomaccess3)'s [Python script](https://github.com/randomaccess3/SundayFunday/blob/master/ListObjectIDs/allObjectIDs.py)*<br>
