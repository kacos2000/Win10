## Win 11 Program-Compatibility


- (Powershell script) Event Log parser<br>
   [Microsoft-Windows-Application-Experience%4Program-Compatibility-Assistant.evtx](https://github.com/kacos2000/Win10/blob/master/ProgramCompatibility/Program-Compatibility-Assistant_evtx.ps1)

- [(pca.ps1)](https://github.com/kacos2000/Win10/blob/master/ProgramCompatibility/pca.ps1), [(pca.exe)](https://github.com/kacos2000/Win10/blob/master/ProgramCompatibility/pca.exe) - Combined parser, for:
   - \Windows\appcompat\pca\PcaAppLaunchDic.txt
   - \Windows\appcompat\pca\PcaGeneralDb0.txt
   - \Windows\appcompat\pca\PcaGeneralDb1.txt
   - Windows\System32\winevt\Logs\Microsoft-Windows-Application-Experience%4Program-Compatibility-Assistant.evtx
   <br>

   ``` 
   Get-Help .\pca.ps1
    pca.ps1 [[-Pca] <string>] [[-Evtx] <string>] [[-OutPath] <string>] [-CSV] [-NoGUI]
    ```


[Note]: Both scripts need to be run 'As Admin'

(The appcompat\pca track Application launches *(except those from Start menu (?))*)

- Related:
  - [aboutdfir Blog post](https://aboutdfir.com/new-windows-11-pro-22h2-evidence-of-execution-artifact/)
  - [13Cubed Video](https://www.youtube.com/watch?v=rV8aErDj06A)
