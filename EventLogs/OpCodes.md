### OpCodes ### 
[opcode:](https://docs.microsoft.com/en-us/windows/desktop/WES/eventmanifestschema-opcode-opcodelisttype-element) Contains a numeric value that identifies the activity or a point within an activity that the application was performing 
when it raised the event .

  * **Powershell script** to list all OpCodes, their Name & DisplayName for AllEvent providers:
  
        # OpCodes:

        # Get all listprovider names into an array
        $pnames = @((Get-WinEvent -ListLog * -ErrorAction SilentlyContinue).ProviderName|sort-object|get-unique)
        $pcount = $pnames.count
        $e=0

        $opcodes = foreach($p in $pnames){$e++;
                write-progress -activity "List provider:$($p) ->  $($e) of $($pcount)"  -PercentComplete (($e / $($pcount)) * 100)
                # get all opcodes for each listprovider (from the above array)            
                $listprovider = if(((Get-WinEvent -Listprovider $p -ErrorAction SilentlyContinue).events|select-object -property id, opcode).opcode -ne $false)
                                {((Get-WinEvent -Listprovider $p -ErrorAction SilentlyContinue).events|select-object -property id, opcode)}
                #format output
                foreach($i in $listprovider){
                        [PSCustomObject]@{
                                    Provider = $p
                                    EventId = $i.id
                                    '#' = $i.opcode.value.count
                                    Value = $i.opcode.value
                                    Name = $i.opcode.name
                                    Displayname = $i.opcode.displayname
               }
            }
        }
        #output results to table
        $opcodes|sort -property Provider, EventID, Value  |format-table -autosize
           

      * Sample Output<br> 
           * [Full output in comma separated text *(csv)*](https://raw.githubusercontent.com/kacos2000/Win10/master/EventLogs/OpCodes.csv)<br><br>
           

         Provider | EventID | Count | Value | Name  | Display Name 
         :---- | :--: | :---: | :---: | :---:  | :---:
         LsaSrv | 6225 | 1 | 1 | win:Start | Start    
         LsaSrv | 6226 | 1 | 2 | win:Stop | Stop   
         LsaSrv | 6227 | 1 | 1 | win:Start | Start   
         LsaSrv | 6228 | 1 | 2 | win:Stop | Stop
         LsaSrv | 6229 | 1 | 1 | win:Start | Start 
         LsaSrv | 6230 | 1 | 2 | win:Stop | Stop
         LsaSrv | 6231 | 1 | 1 | win:Start  | Start
         LsaSrv | 6232 | 1 | 2 | win:Stop | Stop    


       * Sample Output when sorted by unique Name. *(From 791 eventlog providers - Win10 Pro (version 1803) )*<br>
         `$kw|sort -property Value, Name, Displayname -unique  |format-table -autosize`<br>
            * [Full output in comma separated text *(csv)*](https://raw.githubusercontent.com/kacos2000/Win10/master/EventLogs/OpCodes2.csv)<br><br>
            
            

         | Provider| EventID | Value | Name | DisplayName 
         | :----- | :----: | :----:| :----- |  :-----
         | AESMService| 0 | 0|  |  
         | Microsoft-Windows-PriResources-Deployment| 1000 | 0| win:Info |  
         | Microsoft-Windows-SenseIR| 11 | 0| win:Info | Info 
         | Microsoft-Windows-PriResources-Deployment| 1 | 1| win:Start |  
         | Microsoft-Windows-Shell-Core| 18952 | 1| win:Start | Start 
         | Microsoft-Windows-PriResources-Deployment| 2 | 2| win:Stop |  
         | Microsoft-Windows-VolumeSnapshot-Driver| 119 | 2| win:Stop | Stop 
         | Microsoft-WindowsPhone-ConfigManager2| 88 | 4| win:DC_Stop | DCStop 
         | Microsoft-Windows-Bits-Client| 1 | 7| win:Resume | Resume 
         | Microsoft-Windows-Kernel-PnP| 271 | 8| win:Suspend | Suspend 
         | Microsoft-Windows-Spell-Checking| 1 | 9| win:Send | Send 
         | Microsoft-Windows-Bits-Client| 19 | 10| AcceptPacket | replying to an incoming request 
         | Microsoft-Windows-GPIO-ClassExtension| 1000 | 10| AcpiEventMethodStart |  
         | Microsoft-Windows-Winsock-AFD| 4016 | 10| AFD_OPCODE_OPEN | Open 

       


