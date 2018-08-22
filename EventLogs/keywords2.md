*Continued from [keywords.md](keywords.md)*<br>
*Sctipt to get the full list of keywords in [keywords3.md](keywords3.md) -- [CSV output file](https://github.com/kacos2000/Win10/blob/master/EventLogs/keyall.csv)*<br>

### Event log 'Keywords' *p2*


Apparently, each event log uses new 'keywords' created from a combination of the main 'keywords' found in the [previous page](keywords.md). 

 - Example: 
    
    - The keyword **0x80000000a1878800**:<br> 
    
      ![0x80000000a1878800](https://raw.githubusercontent.com/kacos2000/Win10/master/EventLogs/80000000a1878800.JPG)<br>
      
      * is created from the combination of:

        | keywords (in Decimal): | Name: |Display Name: 
        |  :----  |  :---- |  :----
        | -9223372036854775808 | - | Microsoft-Windows-Shell-Core/Diagnostic*
        | 4611686018427387904 | wpndev_NotificationE2E | Developer Support: End-to-End trace for new notification Developer 
        | 2147483648 | wpndebug_localtile_isolate | Debug: Isolate Failures in Local Tile Notification Delivery Developer 
        | 536870912 | wpndebug_cloudtile_isolate | Debug: Isolate Failures in Cloud Tile Notification Delivery 
        | 16777216 | wpntroubleshoot | WNP Transport Layer Performance
        | 8388608 | wpnperf_NewCloudNotificationArrivalWithCloudImage | Scenario: New cloud notification refering cloud images arrives Performance
        | 262144 | wpnperf_NewCloudNotificationArrival | Scenario: New cloud notification arrives Performance
        | 31072 | wpnperf_FirstCloudNotificationWithCloudImage | Scenario: First cloud notification with cloud image download Performance
        | 65536 | wpnperf_FirstCloudNotification | Scenario: First cloud notification Presentation Layer API  
        | 32768 | wpnui | Routing Services*
        | 2048 | - | StationId*

          *(\* Name taken from the previous page)*
      
     Adding all these Decimal values, and converting the total to HEX: *(powershell terminal command)*<br> 
     `"0x"+'{0:x16}'-f (-9223372036854775808 + 2147483648 + 536870912 + 16777216 + 8388608 + 262144 + 131072 + 65536 + 32768 + 2048)`<br>
     gives *(powershell terminal output)*:  **0x80000000a1878800**<br>



  * Powershell Script to list all keywords for each event ID from an eventlog List provider, and get the unique keywords 

        # List all event Log providers:
        # (Get-WinEvent -ListLog * ).ProviderNames|sort|get-unique

        # Change 'Listprovider' name to get the keyword names & descriptions for that provider
        $listprovider = @((Get-WinEvent -Listprovider Microsoft-Windows-PushNotifications-Platform).events|select-object -property id, keywords)

        $kw = foreach($i in $listprovider){
            $kn=$vd=$vdn=$null
            #Get all possible keyword values (decimal) and add them together        
            $kvv=0;(0..20)|foreach{$kvv += $i.keywords.value[$_]}

            foreach($n in $i.keywords.name.count)        {if($n -ge 1)  {$kn  += "$($i.keywords.name[0..$n]) "}} 
            foreach($v in $i.keywords.value.count)       {if($v -ge 1) {$vd  += "$($i.keywords.value[0..$v]) "}}
            foreach($d in $i.keywords.displayname.count) {if($d -ge 1) {$vdn += "$($i.keywords.displayname[0..$d]) "}}

            [PSCustomObject]@{
                id = $i.id
                '#' = $i.keywords.value.count
                ValueHEX = "0x"+'{0:x16}'-f $kvv
                ValueDEC= $vd
                Name = $kn
                Displayname = $vdn
            }
        }

        $kw |sort -property ValueHEX -Unique|sort -property '#' |format-table -AutoSize




___________________________________________________________________________________________________________________________

  * Result:

    | New HEX Keyword | Keywords Count |Keywords (values in DEC) | Name(s)
    | :----------------: | :--: | :----------------- | :-------------------------------- 
    | 0x8000000000000000 | 1 |   |  
    | 0x2000000000400000 | 2 | 2305843009213693952 4194304  |  wnptrans  
    | 0x8000000000000100 | 2 | -9223372036854775808 256  |  wpnconn  
    | 0x8000000000400000 | 2 | -9223372036854775808 4194304  |  wnptrans  
    | 0x8000000000000800 | 2 | -9223372036854775808 2048  |  wpnui  
    | 0x4000000000400000 | 2 | 4611686018427387904 4194304  |  wnptrans  
    | 0x8000000000002000 | 2 | -9223372036854775808 8192  |  wpndbg  
    | 0x4000000000000100 | 2 | 4611686018427387904 256  |  wpnconn  
    | 0x4000000000000200 | 2 | 4611686018427387904 512  |  wpnend  
    | 0x4000000000000800 | 2 | 4611686018427387904 2048  |  wpnui  
    | 0x4000000000002000 | 2 | 4611686018427387904 8192  |  wpndbg  
    | 0x4000000000001000 | 2 | 4611686018427387904 4096  |  wpnplat  
    | 0x4000000000004000 | 2 | 4611686018427387904 16384  |  wpnprv  
    | 0x8000000000800200 | 3 | -9223372036854775808 8388608 512  |  wpntroubleshoot wpnend  
    | 0x4001000000004000 | 3 | 4611686018427387904 281474976710656 16384  |  win:ResponseTime wpnprv  
    | 0x8000000000600000 | 3 | -9223372036854775808 4194304 2097152  |  wnptrans wpnperf_Shutdown  
    | 0x8000000000800100 | 3 | -9223372036854775808 8388608 256  |  wpntroubleshoot wpnconn  
    | 0x4000000080000800 | 3 | 4611686018427387904 2147483648 2048  |  wpndev_NotificationE2E wpnui  
    | 0x4000000080000200 | 3 | 4611686018427387904 2147483648 512  |  wpndev_NotificationE2E wpnend  
    | 0x4000000000801000 | 3 | 4611686018427387904 8388608 4096  |  wpntroubleshoot wpnplat  
    | 0x4000000000800800 | 3 | 4611686018427387904 8388608 2048  |  wpntroubleshoot wpnui  
    | 0x4000000000800200 | 3 | 4611686018427387904 8388608 512  |  wpntroubleshoot wpnend  
    | 0x4000000000201000 | 3 | 4611686018427387904 2097152 4096  |  wpnperf_Shutdown wpnplat  
    | 0x8000000006400000 | 4 | -9223372036854775808 67108864 33554432 4194304  |  wpndebug_connectivity_isConnected wpndebug_connectivity wnptrans  
    | 0x8000000000800104 | 4 | -9223372036854775808 8388608 256 4  |  wpntroubleshoot wpnconn wpndebug_raw_dropped  
    | 0x800000000a004000 | 4 | -9223372036854775808 134217728 33554432 16384  |  wpndebug_connectivity_error wpndebug_connectivity wpnprv  
    | 0x8000000000418000 | 4 | -9223372036854775808 4194304 65536 32768  |  wnptrans wpnperf_FirstCloudNotificationWithCloudImage wpnperf_FirstCloudNotification  
    | 0x800000000001c000 | 4 | -9223372036854775808 65536 32768 16384  |  wpnperf_FirstCloudNotificationWithCloudImage wpnperf_FirstCloudNotification wpnprv  
    | 0x800000000a400000 | 4 | -9223372036854775808 134217728 33554432 4194304  |  wpndebug_connectivity_error wpndebug_connectivity wnptrans  
    | 0x8000000010800200 | 4 | -9223372036854775808 268435456 8388608 512  |  wpndebug_platform_setting wpntroubleshoot wpnend  
    | 0x8000000040800200 | 4 | -9223372036854775808 1073741824 8388608 512  |  wpndebug_polling_error wpntroubleshoot wpnend  
    | 0x8000000002801000 | 4 | -9223372036854775808 33554432 8388608 4096  |  wpndebug_connectivity wpntroubleshoot wpnplat  
    | 0x8000000080000208 | 4 | -9223372036854775808 2147483648 512 8  |  wpndev_NotificationE2E wpnend wpndebug_raw_isolate  
    | 0x8000200000800100 | 4 | -9223372036854775808 35184372088832 8388608 256  |  ms:Telemetry wpntroubleshoot wpnconn  
    | 0x4000000080000208 | 4 | 4611686018427387904 2147483648 512 8  |  wpndev_NotificationE2E wpnend wpndebug_raw_isolate  
    | 0x4000000040800200 | 4 | 4611686018427387904 1073741824 8388608 512  |  wpndebug_polling_error wpntroubleshoot wpnend  
    | 0x4000000010800200 | 4 | 4611686018427387904 268435456 8388608 512  |  wpndebug_platform_setting wpntroubleshoot wpnend  
    | 0x400000000a004000 | 4 | 4611686018427387904 134217728 33554432 16384  |  wpndebug_connectivity_error wpndebug_connectivity wpnprv  
    | 0x4000000000019000 | 4 | 4611686018427387904 65536 32768 4096  |  wpnperf_FirstCloudNotificationWithCloudImage wpnperf_FirstCloudNotification wpnplat  
    | 0x4000000000418000 | 4 | 4611686018427387904 4194304 65536 32768  |  wnptrans wpnperf_FirstCloudNotificationWithCloudImage wpnperf_FirstCloudNotification  
    | 0x4000000000180800 | 4 | 4611686018427387904 1048576 524288 2048  |  wpnperf_MoGoPanningWithCloudImage wpnperf_MoGoPanning wpnui  
    | 0x400000000001c000 | 4 | 4611686018427387904 65536 32768 16384  |  wpnperf_FirstCloudNotificationWithCloudImage wpnperf_FirstCloudNotification wpnprv  
    | 0x8000000006800100 | 5 | -9223372036854775808 67108864 33554432 8388608 256  |  wpndebug_connectivity_isConnected wpndebug_connectivity wpntroubleshoot wpnconn  
    | 0x4000000000150800 | 5 | 4611686018427387904 1048576 262144 65536 2048  |  wpnperf_MoGoPanningWithCloudImage wpnperf_NewCloudNotificationArrivalWithCloudImage wpnperf_FirstCloudNotificationWithCloudImage wpnui  
    | 0x40000000a0800202 | 6 | 4611686018427387904 2147483648 536870912 8388608 512 2  |  wpndev_NotificationE2E wpndebug_localtile_isolate wpntroubleshoot wpnend wpndebug_localtoast_isolate  
    | 0x4000000080800803 | 6 | 4611686018427387904 2147483648 8388608 2048 2 1  |  wpndev_NotificationE2E wpntroubleshoot wpnui wpndebug_localtoast_isolate wpndebug_cloudtoast_isolate  
    | 0x4000000080150800 | 6 | 4611686018427387904 2147483648 1048576 262144 65536 2048  |  wpndev_NotificationE2E wpnperf_MoGoPanningWithCloudImage wpnperf_NewCloudNotificationArrivalWithCloudImage wpnperf_FirstCloudNotificationWithCloudImage wpnui  
    | 0x8000000080800803 | 6 | -9223372036854775808 2147483648 8388608 2048 2 1  |  wpndev_NotificationE2E wpntroubleshoot wpnui wpndebug_localtoast_isolate wpndebug_cloudtoast_isolate  
    | 0x8000000006818100 | 7 | -9223372036854775808 67108864 33554432 8388608 65536 32768 256  |  wpndebug_connectivity_isConnected wpndebug_connectivity wpntroubleshoot wpnperf_FirstCloudNotificationWithCloudImage wpnperf_FirstCloudNotification wpnconn  
    | 0x4000000080078800 | 7 | 4611686018427387904 2147483648 262144 131072 65536 32768 2048  |  wpndev_NotificationE2E wpnperf_NewCloudNotificationArrivalWithCloudImage wpnperf_NewCloudNotificationArrival wpnperf_FirstCloudNotificationWithCloudImage wpnperf_FirstCloudNotification wpnui  
    | 0x800000000a81c000 | 7 | -9223372036854775808 134217728 33554432 8388608 65536 32768 16384  |  wpndebug_connectivity_error wpndebug_connectivity wpntroubleshoot wpnperf_FirstCloudNotificationWithCloudImage wpnperf_FirstCloudNotification wpnprv  
    | 0x40000000a1878800 | 10 | 4611686018427387904 2147483648 536870912 16777216 8388608 262144 131072 65536 32768 2048  |  wpndev_NotificationE2E wpndebug_localtile_isolate wpndebug_cloudtile_isolate wpntroubleshoot wpnperf_NewCloudNotificationArrivalWithCloudImage wpnperf_NewCloudNotificationArrival wpnperf_FirstCloudNotificationWithCloudImage wpnperf_FirstCloudNotification wpnui  
    | 0x80000000a1878800 | 10 | -9223372036854775808 2147483648 536870912 16777216 8388608 262144 131072 65536 32768 2048  |  wpndev_NotificationE2E wpndebug_localtile_isolate wpndebug_cloudtile_isolate wpntroubleshoot wpnperf_NewCloudNotificationArrivalWithCloudImage wpnperf_NewCloudNotificationArrival wpnperf_FirstCloudNotificationWithCloudImage wpnperf_FirstCloudNotification wpnui  
    | 0x8000000081878109 | 11 | -9223372036854775808 2147483648 16777216 8388608 262144 131072 65536 32768 256 8 1  |  wpndev_NotificationE2E wpndebug_cloudtile_isolate wpntroubleshoot wpnperf_NewCloudNotificationArrivalWithCloudImage wpnperf_NewCloudNotificationArrival wpnperf_FirstCloudNotificationWithCloudImage wpnperf_FirstCloudNotification wpnconn wpndebug_raw_isolate wpndebug_cloudtoast_isolate  

___________________________________________________________________________________________________________________________

* Back to [keywords.md](keywords.md)<br>
* Complete list of keywords in [keywords3.md](keywords3.md)<br>
* Other info: [OpCodes](OpCodes.md)
