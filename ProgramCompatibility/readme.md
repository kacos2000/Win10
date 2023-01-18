## Win 11 Program-Compatibility


- (Powershell script) Event Log parser<br>
   [Microsoft-Windows-Application-Experience%4Program-Compatibility-Assistant.evtx](https://github.com/kacos2000/Win10/blob/master/ProgramCompatibility/Program-Compatibility-Assistant_evtx%20.ps1)

- [(pca.ps1) Combined parser for:](https://github.com/kacos2000/Win10/blob/master/ProgramCompatibility/pca.ps1)<br>
- [(pca.exe) Combined parser for:](https://github.com/kacos2000/Win10/blob/master/ProgramCompatibility/pca.exe)<br>
   - \Windows\appcompat\pca\PcaAppLaunchDic.txt
   - \Windows\appcompat\pca\PcaGeneralDb0.txt
   - \Windows\appcompat\pca\PcaGeneralDb1.txt
   - Windows\System32\winevt\Logs\Microsoft-Windows-Application-Experience%4Program-Compatibility-Assistant.evtx

      ![image](https://user-images.githubusercontent.com/11378310/213296113-8c83ecee-f687-45ea-a822-d3e07487d0fa.png)

[Note]: Both scripts need to be run 'As Admin'

(The appcompat\pca track Application launches *(except those from Start menu (?))*)

- Related:
  - [aboutdfir Blog post](https://aboutdfir.com/new-windows-11-pro-22h2-evidence-of-execution-artifact/)
  - [13Cubed Video](https://www.youtube.com/watch?v=rV8aErDj06A)
