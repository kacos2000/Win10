**Windows 10 Search [PowerShell Jumplist Parser](https://github.com/kacos2000/Win10-Research/blob/master/JumpList/Jumplist.ps1)**


Reads contents of precollected (*not live*) **NTUser.dat** from the location:
*HKCU -> Software\Microsoft\Windows\CurrentVersion\Search\JumplistData*

Starts by allowing user to select NTUser.dat file:

![File selection](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/JumpList/select.JPG)

Calculates hash of file and opens it (*Read Only*). The results are shown in a popup window with Filestamp in user localtime.
User can select all lines (Ctrl+A) or specific lines (Ctrl+click) and copy/paste (Ctrl+C and Ctrl+V) the data to a text file or MS Excel spreadsheet. The Selected lines are also displayed in the console after the user presses the OK button.

![Jumplist data](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/JumpList/results.JPG)

After result window is closed, a new hash of the file is computed and checked against the original:

![Hash Check](https://raw.githubusercontent.com/kacos2000/Win10-Research/master/JumpList/HashCheck.JPG)
