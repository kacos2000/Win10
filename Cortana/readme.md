## Windows Search ###

**[Powershell script](https://github.com/kacos2000/Win10/blob/master/Cortana/Search_AppCache.ps1)** to parse AppCache?????????????.txt files in either:<br>
  '$env:LOCALAPPDATA"\Packages\ **Microsoft.Windows.Cortana_cw5n1h2txyewy** \LocalState\DeviceSearchCache\' (Win10 -v1909) or <br>
  '$env:LOCALAPPDATA"\Packages\ **Microsoft.Windows.Search_cw5n1h2txyewy** \LocalState\DeviceSearchCache\' (Win10 v2004+) folders <br>
  
  *Note: Not sure from which update exactly, but Cortana was separated from Windows Seach & became a separate MS Store app* 
  
  ![sample_output](https://raw.githubusercontent.com/kacos2000/Win10/master/Cortana/C_AppCache.JPG)

  **NOTE:** The 'Type,Name,Path,Description' (Jumplist) fields are from the recently used list/history of the respective app if Type = 1!<br>
  as seen in the search Window:<br>
  
  ![SW](https://raw.githubusercontent.com/kacos2000/Win10/master/Cortana/ln.JPG)


### A brief look at IndexedDB.edb
   *(Full path: '$env:LOCALAPPDATA"\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\AppData\Indexed DB\IndexedDB.edb')*
   
   The (**T2**) table (mruWithIndex) seems to contain similar info to AppCache*.txt, but in a BLOB:<br>
   
 ```    <Row>
        <Column Name="autoIncObjectCount" Value="1870"/>
        <Column Name="dataBlob" Value="AAAAARsAAAAWAAAATABhAHMAdABVAHAAZABhAHQAZQBkAAAABgAAAAybHl8wAAAAUwB1AGcAZwBlAHMAdABpAG8AbgBFAG4AZwBhAGcAZQBtAGUAbgB0AEQAYQB0AGEAGwAAAKYAAAAzADYACQB7ADEAQQBDADEANABFADcANwAtADAAMgBFADcALQA0AEUANQBEAC0AQgA3ADQANAAtADIARQBCADEAQQBFADUAMQA5ADgAQgA3AH0AXABXAGkAbgBkAG8AdwBzAFAAbwB3AGUAcgBTAGgAZQBsAGwAXAB2ADEALgAwAFwAUABvAHcAZQByAFMAaABlAGwAbABfAEkAUwBFAC4AZQB4AGUAAAAbAAAAIgAAAHAAcgBlAGYAaQB4AEwAYQB1AG4AYwBoAEMAbwB1AG4AdAAAAAYAAAAYAAAAHAAAAGwAYQBzAHQATABhAHUAbgBjAGgAVABpAG0AZQAGAAAADJseXxIAAABnAHIAbwB1AHAAVAB5AHAAZQAAAAYAAAAkAAAA////////////////"/>
        <Column Name="I-1-Date"/>
        <Column Name="I-1-Number"/>
        <Column Name="I-1-String"/>
        <Column Name="I-1-VariantType" Value="4"/>
        <Column Name="I-2-Date"/>
        <Column Name="I-2-Number" Value="1595841292"/>
        <Column Name="I-2-String"/>
        <Column Name="I-2-VariantType" Value="1"/>
      </Row> 
 ```

Decoded, the above dataBlob looks like:
    ```
          L a s t U p d a t e d      �_0   S u g g e s t i o n E n g a g e m e n t D a t a    �   3 6 	 { 1 A C 1 4 E 7 7 - 0 2 E 7 - 4 E 5 D - B 7 4 4 - 2 E B 1 A E 5 1 9 8 B 7 } \ W i n d o w s P o w
     e r S h e l l \ v 1 . 0 \ P o w e r S h e l l _ I S E . e x e      "   p r e f i x L a u n c h C o u n t            l a s t L a u n c h T i m e    �_   g r o u p T y p e      $ 
     ```
     <br><br>
*'$env:LOCALAPPDATA"\Packages\Microsoft.Windows.Cortana_cw5n1h2txyew\AppData\Indexed DB\IndexedDB.edb''s **T-8** table (mruWithIndex) contains similar info too.*

 - Microsoft.Windows.**Search**_cw5n1h2txyewy\AppData\Indexed DB\IndexedDB.edb object store friendly names:
 1. mruWithIndexStore
 2. mruWithIndex
 3. msb
 4. mru
 5. person
 6. bookmark
 7. qna
 8. location
 9. token
        <br>
   - Microsoft.Windows.**Cortana**_cw5n1h2txyew\AppData\Indexed DB\IndexedDB.edb object store friendly names:
 1. mruWithIndexStore
 2. BingClientStore 
 3. BingClientStore2 
 4. mruWithIndex  
 <br>

