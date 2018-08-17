### OpCodes ### 
[opcode:](https://docs.microsoft.com/en-us/windows/desktop/WES/eventmanifestschema-opcode-opcodelisttype-element) Contains a numeric value that identifies the activity or a point within an activity that the application was performing 
when it raised the event .

  * **Powershell script** to list all OpCodes, their Name & DisplayName for AllEvent providers:
  
        # OpCodes:

        # Get all listprovider names into an array
        $pnames = @((Get-WinEvent -ListLog * -ErrorAction SilentlyContinue).ProviderNames|sort-object|get-unique)
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
        
  * Sample Output 

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


    * Output - from 791 eventlog providers  *(Win10 Pro (version 1803) )*, when sorted by unique Name<br>
      `$kw|sort -property name -unique  |format-table -autosize`
      
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
        | Microsoft-Windows-AllJoyn| 2 | 10| AJOpCodeError | Error 
        | Microsoft-Windows-ATAPort| 100 | 10| ATAPORT_OPCODE_DEV_ENUM_INIT |  
        | Microsoft-Windows-Security-UserConsentVerifier| 101 | 10| AuditResultOpcode | Result 
        | Microsoft-Windows-BitLocker-DrivePreparationTool| 4099 | 10| bdecfg:Initialization | Initialization 
        | Microsoft-Windows-WorkFolders| 8001 | 10| ChangeUpdateStart |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1001 | 10| Connect | This event is raised during the connection process 
        | Microsoft-Windows-Security-EnterpriseData-FileRevocationManager| 1 | 10| CreateIdentity | Protect Identity operation. 
        | Microsoft-Windows-DeviceSetupManager| 300 | 10| DeviceUxReady |  
        | Microsoft-Windows-Energy-Estimation-Engine| 39 | 10| EnergyEstimate |  
        | Microsoft-Windows-DirectShow-KernelSupport| 3 | 10| Enter | Enter 
        | Microsoft-Windows-Kernel-EventTracing| 4 | 10| ETW_OPCODE_WRITE_BUFFER | Write Buffer 
        | Microsoft-Windows-USB-MAUSBHOST| 51 | 10| INFORMATION | Information 
        | Microsoft-Windows-WWAN-SVC-EVENTS| 12000 | 10| Initialize | Initialize 
        | Microsoft-Windows-SPB-HIDI2C| 1011 | 10| IoSpbReadDispatch |  
        | Microsoft-Windows-Application Server-Applications| 3551 | 10| NoBookmark | NoBookmark 
        | Microsoft-Windows-Win32k| 40 | 10| OldToNewRendering |  
        | Microsoft-Windows-MediaFoundation-Performance| 4015 | 10| op_mfperf_Input | Input 
        | Microsoft-Windows-NetworkBridge| 2001 | 10| OpcodeDebugTrace | DebugTrace 
        | Microsoft-Windows-PowerShell| 8198 | 10| Open | Open (async) 
        | Microsoft-Windows-PrintBRM| 40 | 10| PRINT_BRM_OPCODE_SUCCEEDED | Print BRM operation success 
        | Microsoft-Windows-Kernel-PnP| 500 | 10| QueryStart |  
        | Microsoft-Windows-WindowsUpdateClient| 35 | 10| selfupdate | SelfUpdate 
        | Microsoft-Windows-BranchCache| 10 | 10| ServiceStartup | The BranchCache service is starting up. 
        | Microsoft-Windows-PrintService| 302 | 10| SPOOLER_OPCODE_PENDING | Spooler Operation Started 
        | Microsoft-Windows-WebAuthN| 1023 | 10| Start | Start 
        | Microsoft-Windows-ServiceReportingApi| 1 | 10| SVCAPI_BASELINE_OPCODE_DEBUG | Debug message 
        | Microsoft-User Experience Virtualization-App Agent| 15002 | 10| TemplateConsole |  
        | Microsoft-Windows-UserModePowerService| 36 | 10| TooShort |  
        | Microsoft-Windows-Diagnosis-DPS| 1 | 10| WDI_DPS_OPCODE_INIT | The Diagnostic Policy Service started 
        | Microsoft-Windows-Kernel-WDI| 32 | 10| WDI_SEM_TASK_SCENARIO_OPCODE_START | Scenario start enables context providers to the WDI context logger. 
        | Microsoft-Windows-GPIO-ClassExtension| 1001 | 11| AcpiEventMethodComplete |  
        | Microsoft-Windows-AllJoyn| 4 | 11| AJOpCodeTrace | Trace 
        | Microsoft-Windows-ATAPort| 101 | 11| ATAPORT_OPCODE_DEV_ENUM_COMPLETE |  
        | Microsoft-Windows-BitLocker-DrivePreparationTool| 2 | 11| bdecfg:ShrinkDrive | Shrink 
        | Microsoft-Windows-RemoteDesktopServices-SessionServices| 1 | 11| ChangeSessionResolution | Change session resolution 
        | Microsoft-Windows-StorDiag| 1 | 11| ClassPnP_IO_End |  
        | Microsoft-Windows-WWAN-SVC-EVENTS| 12001 | 11| Cleanup | Cleanup 
        | Microsoft-Windows-PowerShell| 53508 | 11| Close | Close (Async) 
        | Microsoft-Windows-USB-USBXHCI| 39 | 11| COMPLETED_IN_TRUSTLET | Request from VTL0 driver completed in trustlet 
        | Microsoft-Windows-Energy-Estimation-Engine| 14 | 11| CpuPowerInfo |  
        | Microsoft-Windows-WindowsUpdateClient| 16 | 11| detect | Check for Updates 
        | Microsoft-Windows-DeviceSetupManager| 301 | 11| DeviceSetupComplete |  
        | Microsoft-Windows-Dhcp-Client| 50001 | 11| DHCP_OPCODE_MEDIA_CONNECT | MediaConnect 
        | Microsoft-Windows-DHCPv6-Client| 51001 | 11| DHCPV6_OPCODE_MEDIA_CONNECT | MediaConnect 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1107 | 11| Disconnect | This event is raised during the disconnection process 
        | Microsoft-Windows-WorkFolders| 8002 | 11| DownloadStart |  
        | Microsoft-Windows-USB-USBHUB3| 111 | 11| ERROR | Error 
        | Microsoft-Windows-Kernel-EventTracing| 5 | 11| ETW_OPCODE_FILE_SWITCH | File Switch 
        | Microsoft-Windows-DirectShow-KernelSupport| 6 | 11| Exit | Exit 
        | Microsoft-Windows-Fault-Tolerant-Heap| 1001 | 11| FTH_EVENT_OPCODE_LIFECYCLE_START | Events logged when the FTH (fault tolerant heap) service is started. 
        | Microsoft-Windows-Kernel-Boot| 61 | 11| GetEfiVariable |  
        | Microsoft-Windows-HttpService| 1 | 11| HTTP_OPCODE_RECEIVE_REQUEST | RecvReq 
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 38 | 11| Initialize | Initialize 
        | Microsoft-Windows-SPB-ClassExtension| 1011 | 11| IoDispatchToTarget |  
        | Microsoft-Windows-SPB-HIDI2C| 1012 | 11| IoSpbReadComplete |  
        | Microsoft-Windows-Win32k| 39 | 11| NewRendering |  
        | Microsoft-Windows-Application Server-Applications| 1140 | 11| NoInstance | NoInstance 
        | Microsoft-Windows-MediaFoundation-Performance| 4020 | 11| op_mfperf_Output | Output 
        | Microsoft-Windows-WinHttp| 811 | 11| Opcode.Fail | Fail 
        | Microsoft-Windows-WebIO| 109 | 11| Opcode.Queue | Queue 
        | Microsoft-Windows-Disk| 1 | 11| OpCodeDiskCacheInfo |  
        | Microsoft-Windows-StorPort| 1 | 11| OpCodeLUReset |  
        | Microsoft-Windows-AppxPackagingOM| 225 | 11| Parse | Parse Manifest 
        | Microsoft-Windows-UserModePowerService| 44 | 11| PassStart |  
        | Microsoft-Windows-PrintBRM| 11 | 11| PRINT_BRM_OPCODE_FAILED | Print BRM operation failure 
        | Microsoft-Windows-Kernel-PnP| 503 | 11| QueryStop |  
        | Microsoft-Windows-Resource-Exhaustion-Detector| 1005 | 11| RDR_DET_OPCODE_LIFECYCLE_START | Events logged when the resource exhaustion detector is started. 
        | Microsoft-Windows-Resource-Exhaustion-Resolver| 1005 | 11| RDR_RES_OPCODE_LIFECYCLE_START | Events logged when the resource exhaustion resolver is started. 
        | Microsoft-Windows-Bits-Client| 25 | 11| RejectPacket | denying or ignoring an incoming packet 
        | Microsoft-Windows-BranchCache| 11 | 11| RepublishContent | Republishing content - making content available to others in the branch office. 
        | Microsoft-Windows-Security-EnterpriseData-FileRevocationManager| 17 | 11| RevokeIdentity | Revoke Identity operation. 
        | Microsoft-Windows-PrintService| 312 | 11| SPOOLER_OPCODE_SUCCEEDED | Spooler Operation Succeeded 
        | Microsoft-Windows-Serial-ClassExtension-V2| 29 | 11| StateMachine | I/O StateMachine operation. 
        | Microsoft-Windows-HelloForBusiness| 7066 | 11| Stop | Stop 
        | Microsoft-Windows-VPN-Client| 10008 | 11| Success | Success 
        | Microsoft-Windows-NetworkProvider| 1000 | 11| UnsupportedRegistryValueType | Unsupported Registry Value Type 
        | Microsoft-Windows-Diagnosis-DPS| 5 | 11| WDI_DPS_OPCODE_MISCONFIGURATION | A diagnostic scenario was misconfigured 
        | Microsoft-Windows-Kernel-WDI| 33 | 11| WDI_SEM_TASK_SCENARIO_OPCODE_END | Scenario end disables context providers to the WDI context logger. 
        | Microsoft-Windows-AppHost| 500 | 11| WWAHOST_OPCODE_SUCCEEDED | AppHost Operation Succeeded 
        | Microsoft-Windows-Winsock-AFD| 1033 | 12| AFD_OPCODE_CONNECTED | Connected 
        | Microsoft-Windows-Application Server-Applications| 131 | 12| Allocate | Allocate 
        | Microsoft-Windows-Win32k| 41 | 12| AppRenderingUpdate |  
        | Microsoft-Windows-ATAPort| 102 | 12| ATAPORT_OPCODE_XFER_MODE_CHANGE |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1008 | 12| Authenticate | This event is raised during the authentication process 
        | Microsoft-Windows-BitLocker-DrivePreparationTool| 3 | 12| bdecfg:CreateDrive | Create 
        | Microsoft-Windows-StorDiag| 2 | 12| ClassPnP_Enqueue_IdleIO |  
        | Microsoft-Windows-GPIO-ClassExtension| 1002 | 12| ClearActiveInterruptsStart |  
        | Microsoft-Windows-PowerShell| 32785 | 12| Connect | connect 
        | Microsoft-Windows-Security-EnterpriseData-FileRevocationManager| 20 | 12| Delegation | Delegation operation. 
        | Microsoft-Windows-Dhcp-Client| 50002 | 12| DHCP_OPCODE_MEDIA_DISCONNECT | MediaDisconnect 
        | Microsoft-Windows-DHCPv6-Client| 51002 | 12| DHCPV6_OPCODE_MEDIA_DISCONNECT | MediaDisconnect 
        | Microsoft-Windows-WindowsUpdateClient| 31 | 12| download | Download 
        | Microsoft-Windows-Install-Agent| 2008 | 12| Error | Error 
        | Microsoft-Windows-Kernel-EventTracing| 10 | 12| ETW_OPCODE_START | Start 
        | Microsoft-Windows-VPN-Client| 10006 | 12| Failure | Failure 
        | Microsoft-Windows-Fault-Tolerant-Heap| 1002 | 12| FTH_EVENT_OPCODE_LIFECYCLE_STOP | Events logged when the FTH (fault tolerant heap) service is stopped. 
        | Microsoft-Windows-HttpService| 2 | 12| HTTP_OPCODE_PARSE | Parse 
        | Microsoft-Windows-HelloForBusiness| 8226 | 12| Informational | Informational 
        | Microsoft-Windows-NetworkProvider| 1001 | 12| InvalidUncPath | Invalid UNC Path 
        | Microsoft-Windows-SPB-HIDI2C| 1013 | 12| IoForwardToCompletionQueue |  
        | Microsoft-Windows-SPB-ClassExtension| 1012 | 12| IoForwardToControllerQueue |  
        | Microsoft-Windows-MediaFoundation-Performance| 4017 | 12| op_mfperf_Queued | Queued 
        | Microsoft-Windows-WebIO| 59995 | 12| Opcode.Cancel | Cancel 
        | Microsoft-Windows-StorPort| 2 | 12| OpCodeTargetReset |  
        | Microsoft-Windows-UserModePowerService| 45 | 12| PassStop |  
        | Microsoft-Windows-Serial-ClassExtension-V2| 19 | 12| Payload | I/O payload operation. 
        | Microsoft-Windows-Energy-Estimation-Engine| 15 | 12| ProcessInfo |  
        | Microsoft-Windows-Kernel-PnP| 501 | 12| ProcessingStart |  
        | Microsoft-Windows-BranchCache| 13 | 12| PublishContent | Publishing content on the server. 
        | Microsoft-Windows-Resource-Exhaustion-Detector| 1002 | 12| RDR_DET_OPCODE_LIFECYCLE_STOP | Events logged when the resource exhaustion detector is stopped. 
        | Microsoft-Windows-Resource-Exhaustion-Resolver| 1006 | 12| RDR_RES_OPCODE_LIFECYCLE_STOP | Events logged when the resource exhaustion resolver is stopped. 
        | Microsoft-Windows-WWAN-SVC-EVENTS| 12100 | 12| RegisterState | RegistrationState 
        | Microsoft-Windows-Kernel-Boot| 62 | 12| SetEfiVariable |  
        | Microsoft-Windows-PrintService| 115 | 12| SPOOLER_OPCODE_FAILED | Spooler Operation Failed 
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 8 | 12| Terminate | Terminate 
        | Microsoft-Windows-WorkFolders| 8003 | 12| UploadStart |  
        | Microsoft-Windows-AppxPackagingOM| 156 | 12| Verifying | Verifying 
        | Microsoft-Windows-Diagnosis-DPS| 100 | 12| WDI_DPS_OPCODE_PROBLEM_DETECTED | A diagnostic module detected a problem 
        | Microsoft-Windows-Kernel-WDI| 34 | 12| WDI_SEM_TASK_SCENARIO_OPCODE_TIMEOUT | When a scenario has remained in-flight beyond the maximum time window it is automatically terminated by the SEM. 
        | Microsoft-Windows-AppHost| 134 | 12| WWAHOST_OPCODE_FAILED | AppHost Operation Failed 
        | Microsoft-Windows-Winsock-AFD| 3006 | 13| AFD_OPCODE_DISCONNECTED | Disconnected 
        | Microsoft-Windows-Energy-Estimation-Engine| 16 | 13| AppPerfInfo |  
        | Microsoft-Windows-Win32k| 42 | 13| AppRenderingTightUpdate |  
        | Microsoft-Windows-ATAPort| 103 | 13| ATAPORT_OPCODE_IO_REQUEST_COMPLETE |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1013 | 13| Autoreconnect | This event is raised while trying to automatically reconnect to the server 
        | Microsoft-Windows-BitLocker-DrivePreparationTool| 4 | 13| bdecfg:PrepareDrive | Prepare 
        | Microsoft-Windows-StorDiag| 3 | 13| ClassPnP_Boost_IdleIO |  
        | Microsoft-Windows-GPIO-ClassExtension| 1003 | 13| ClearActiveInterruptsComplete |  
        | Microsoft-Windows-Dhcp-Client| 50003 | 13| DHCP_OPCODE_MEDIA_RECONNECT | MediaReconnect 
        | Microsoft-Windows-DHCPv6-Client| 1006 | 13| DHCPV6_OPCODE_RA_CHANGED | RAChanged 
        | Microsoft-Windows-PowerShell| 32804 | 13| Disconnect | Disconnect 
        | Microsoft-Windows-BranchCache| 14 | 13| DownloadContent | Downloading content. 
        | Microsoft-Windows-HttpService| 3 | 13| HTTP_OPCODE_DELIVER | Deliver 
        | Microsoft-Windows-WindowsUpdateClient| 43 | 13| install | Installation 
        | Microsoft-Windows-Kernel-Boot| 63 | 13| InvalidTxtSinitRange |  
        | Microsoft-Windows-SPB-ClassExtension| 1013 | 13| IoDispatchToController |  
        | Microsoft-Windows-UserModePowerService| 41 | 13| MissingStart |  
        | Microsoft-Windows-MediaFoundation-Performance| 4018 | 13| op_mfperf_Dropped | Dropped 
        | Microsoft-Windows-WebIO| 59994 | 13| Opcode.Get | Get 
        | Microsoft-Windows-StorPort| 501 | 13| OpCodeBusReset |  
        | Microsoft-Windows-WWAN-SVC-EVENTS| 12102 | 13| PacketServiceState | PacketServiceState 
        | Microsoft-Windows-Kernel-PnP| 502 | 13| ProcessingStop |  
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 72 | 13| RCMProtocolImpl | RCMProtocolImpl 
        | Microsoft-Windows-Resource-Exhaustion-Detector| 1007 | 13| RDR_DET_OPCODE_LIFECYCLE_ALLOC | Events logged after a memory allocation. 
        | Microsoft-Windows-Resource-Exhaustion-Resolver| 1007 | 13| RDR_RES_OPCODE_LIFECYCLE_ALLOC | Events logged after a memory allocation. 
        | Microsoft-Windows-WorkFolders| 8005 | 13| ReconciliationStart |  
        | Microsoft-Windows-PrintService| 232 | 13| SPOOLER_OPCODE_WARNING | Spooler Warning 
        | Microsoft-Windows-Application Server-Applications| 132 | 13| Tune | Tune 
        | Microsoft-Windows-NetworkProvider| 1002 | 13| UnsupportedUncPath | Unsupported UNC Path 
        | Windows-ApplicationModel-Store-SDK| 3003 | 13| Warning | Warning 
        | Microsoft-Windows-Diagnosis-DPS| 105 | 13| WDI_DPS_OPCODE_TROUBLESHOOT_START | A scenario instance was dispatched for troubleshooting 
        | Microsoft-Windows-Kernel-WDI| 36 | 13| WDI_SEM_TASK_SCENARIO_OPCODE_START_FAILED | A scenario start attempt failed in the SEM. 
        | Microsoft-Windows-Winsock-AFD| 1032 | 14| AFD_OPCODE_ABORTED | Aborted 
        | Microsoft-Windows-ATAPort| 104 | 14| ATAPORT_OPCODE_IO_REQUEST_TIMEOUT |  
        | Microsoft-Windows-Application Server-Applications| 715 | 14| ClientChannelOpenStart | ClientChannelOpenStart 
        | Microsoft-Windows-GPIO-ClassExtension| 1004 | 14| DebounceTimerStart |  
        | Microsoft-Windows-Dhcp-Client| 60018 | 14| DHCP_OPCODE_PERFTRACK_MEDIA_CONNECT | PerfTrackMediaConnect 
        | Microsoft-Windows-DHCPv6-Client| 60002 | 14| DHCPV6_OPCODE_PERFTRACK_MEDIA_CONNECT | PerfTrackMediaConnect 
        | Microsoft-Windows-Energy-Estimation-Engine| 17 | 14| EnergyDelta |  
        | Microsoft-Windows-Kernel-EventTracing| 11 | 14| ETW_OPCODE_STOP | Stop 
        | Microsoft-Windows-BranchCache| 20 | 14| HostedCacheOffer | Offering content to hosted cache. 
        | Microsoft-Windows-HttpService| 4 | 14| HTTP_OPCODE_RECEIVE_RESPONSE | RecvResp 
        | Microsoft-Windows-Install-Agent| 2006 | 14| Info | Info 
        | Microsoft-Windows-NetworkProvider| 1007 | 14| InvalidSyntax | Invalid Syntax 
        | Microsoft-Windows-Kernel-Boot| 64 | 14| InvalidTxtHeapRange |  
        | Microsoft-Windows-SPB-ClassExtension| 1014 | 14| IoPresentToDriver |  
        | Microsoft-Windows-UserModePowerService| 47 | 14| MissingStop |  
        | Microsoft-Windows-MediaFoundation-Performance| 4046 | 14| op_mfperf_Start | Start 
        | Microsoft-Windows-WebIO| 15 | 14| Opcode.Set | Set 
        | Microsoft-Windows-StorPort| 4 | 14| OpCodeResetDetected |  
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 105 | 14| ProtocolExchange | ProtocolExchange 
        | Microsoft-Windows-WorkFolders| 8006 | 14| ReconciliationStop |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1007 | 14| ResolveName | This event is raised during resolving the server name 
        | Microsoft-Windows-PrintService| 222 | 14| SPOOLER_OPCODE_TRACE | Spooler Trace 
        | Microsoft-Windows-WWAN-SVC-EVENTS| 12101 | 14| UiccPresence | UiccPresence 
        | Microsoft-Windows-WindowsUpdateClient| 24 | 14| uninstall | Uninstallation 
        | Microsoft-Windows-Diagnosis-DPS| 110 | 14| WDI_DPS_OPCODE_TROUBLESHOOT_END_NO_RESOLUTION | A diagnostic module completed troubleshooting without setting a resolution 
        | Microsoft-Windows-Kernel-WDI| 37 | 14| WDI_SEM_TASK_SCENARIO_OPCODE_END_FAILED | A scenario end attempt failed in the SEM. 
        | Microsoft-Windows-AppHost| 514 | 14| WWAHOST_OPCODE_INFORMATION | AppHost Information 
        | Microsoft-Windows-Winsock-AFD| 4001 | 15| AFD_OPCODE_CLOSED | Closed 
        | Microsoft-Windows-ATAPort| 105 | 15| ATAPORT_OPCODE_IO_REQUEST_TRANSPORT_ERROR |  
        | Microsoft-Windows-BranchCache| 12 | 15| CachePublishContent | Publishing content on the server. 
        | Microsoft-Windows-Application Server-Applications| 716 | 15| ClientChannelOpenStop | ClientChannelOpenStop 
        | Microsoft-Windows-WWAN-SVC-EVENTS| 12253 | 15| ConnectionProfile | ConnectionProfile 
        | Microsoft-Windows-PowerShell| 4104 | 15| Create | On create calls 
        | Microsoft-Windows-GPIO-ClassExtension| 1005 | 15| DebounceTimerComplete |  
        | Microsoft-Windows-Dhcp-Client| 60019 | 15| DHCP_OPCODE_PERFTRACK_MEDIA_CONNECT_END | PerfTrackMediaConnectEnd 
        | Microsoft-Windows-DHCPv6-Client| 60003 | 15| DHCPV6_OPCODE_PERFTRACK_MEDIA_CONNECT_END | PerfTrackMediaConnectEnd 
        | Microsoft-Windows-Store| 8010 | 15| EnqueueEvent | Enqueue Event 
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 142 | 15| EstablishConnection | EstablishConnection 
        | Microsoft-Windows-Kernel-EventTracing| 13 | 15| ETW_OPCODE_FLUSH | Flush 
        | Microsoft-Windows-HttpService| 5 | 15| HTTP_OPCODE_RECEIVE_RESPONSE_LAST | RecvRespLast 
        | Microsoft-Windows-SPB-ClassExtension| 1015 | 15| IoComplete |  
        | Microsoft-Windows-WorkFolders| 8007 | 15| KnowledgeUploadStart |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1017 | 15| License | This event is raised while trying to get a valid license 
        | Microsoft-Windows-Kernel-Boot| 65 | 15| MleLoadFailure |  
        | Microsoft-Windows-Energy-Estimation-Engine| 19 | 15| MonitorPowerState |  
        | Microsoft-Windows-Audio| 26 | 15| op_EVT_GLITCH_CM_RENDER | Capture Monitor Render Glitch 
        | Microsoft-Windows-MediaFoundation-Performance| 4047 | 15| op_mfperf_Stop | Stop 
        | Microsoft-Windows-WebIO| 727 | 15| Opcode.Reallocate | Reallocate 
        | Microsoft-Windows-StorPort| 5 | 15| OpCodeLinkDown |  
        | Microsoft-Windows-WindowsUpdateClient| 21 | 15| reboot | Reboot 
        | Microsoft-User Experience Virtualization-App Agent| 8330 | 15| UevGenerator | UE-V Generator 
        | Microsoft-Windows-NetworkProvider| 1004 | 15| UnsupportedPropertyName | Unsupported Property Name 
        | Windows-ApplicationModel-Store-SDK| 2001 | 15| Verbose | Verbose 
        | Microsoft-Windows-Diagnosis-DPS| 115 | 15| WDI_DPS_OPCODE_TROUBLESHOOT_END_WITH_IMMEDIATE_RESOLUTION | A diagnostic module completed troubleshooting and set an immediate resolution 
        | Microsoft-Windows-Kernel-WDI| 35 | 15| WDI_SEM_TASK_SCENARIO_OPCODE_INFLIGHT_MAX | The SEM received a request to start a new scenario, but the maximum number of scenarios were already in-flight. 
        | Microsoft-Windows-AppHost| 10000 | 15| WWAHOST_OPCODE_APPLICATION_ERROR | AppHost Application Error 
        | Microsoft-Windows-Winsock-AFD| 1002 | 16| AFD_OPCODE_FREED | Freed 
        | Microsoft-User Experience Virtualization-App Agent| 5003 | 16| AppAgent | App Agent 
        | Microsoft-Windows-ATAPort| 106 | 16| ATAPORT_OPCODE_DEVICE_MISSING |  
        | Microsoft-Windows-WindowsUpdateClient| 27 | 16| AUStateChange | State Change 
        | Microsoft-Windows-WWAN-SVC-EVENTS| 12202 | 16| AutoConnect | AutoConnect 
        | Microsoft-Windows-BranchCache| 25 | 16| CacheLoadPersistContent | Loading local cache. 
        | Microsoft-Windows-Application Server-Applications| 201 | 16| ClientMessageInspectorAfterReceiveInvoked | ClientMessageInspectorAfterReceiveInvoked 
        | Microsoft-Windows-PowerShell| 8193 | 16| Constructor | to be used when an object is constructed 
        | Microsoft-Windows-GPIO-ClassExtension| 1006 | 16| DeferredInterruptActivitiesStart |  
        | Microsoft-Windows-Dhcp-Client| 50006 | 16| DHCP_OPCODE_INIT_REQUEST_ACK | InitRequestAck 
        | Microsoft-Windows-DHCPv6-Client| 51043 | 16| DHCPV6_OPCODE_INTERFACE_ADDED | InterfaceAdded 
        | Microsoft-Windows-Store| 8011 | 16| DispatchEvent | Dispatch Event 
        | Microsoft-Windows-WorkFolders| 8008 | 16| DownloadTransferStart |  
        | Microsoft-Windows-Kernel-EventTracing| 8 | 16| ETW_OPCODE_REGISTER | Register 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1010 | 16| Gateway | This event is raised in the gateway transport 
        | Microsoft-Windows-HttpService| 6 | 16| HTTP_OPCODE_RECEIVE_BODY | RecvBody 
        | Microsoft-Windows-USB-USBHUB3| 4 | 16| INFORMATION | Information 
        | Microsoft-Windows-Kernel-Boot| 66 | 16| MissingRsdpTable |  
        | Microsoft-Windows-FMS| 40000 | 16| NameResOp | NameResolution 
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 137 | 16| NetworkDetect | NetworkDetect 
        | Microsoft-Windows-Audio| 27 | 16| op_EVT_GLITCH_CM_CAPTURE | Capture Monitor Capture Glitch 
        | Microsoft-Windows-MediaFoundation-Performance| 4048 | 16| op_mfperf_Pause | Pause 
        | Microsoft-Windows-WebIO| 125 | 16| Opcode.Reset | Reset 
        | Microsoft-Windows-StorPort| 6 | 16| OpCodeLinkUp |  
        | Microsoft-Windows-Energy-Estimation-Engine| 20 | 16| PolicyBrightness |  
        | Microsoft-Windows-PrintService| 99 | 16| SPOOLER_OPCODE_UNEXPECTED_SHUTDOWN | Unexpected process termination 
        | Microsoft-Windows-NetworkProvider| 1005 | 16| UnsupportedPropertyValue | Unsupported Property Value 
        | Microsoft-Windows-Diagnosis-DPS| 120 | 16| WDI_DPS_OPCODE_TROUBLESHOOT_END_WITH_QUEUED_RESOLUTION | A diagnostic module finished troubleshooting and set an queued resolution 
        | Microsoft-Windows-Kernel-WDI| 42 | 16| WDI_SEM_TASK_INIT_OPCODE_MISCONFIG | There is an invalid configuration parameter in the SEM registry namespace. 
        | Microsoft-Windows-AppHost| 10001 | 16| WWAHOST_OPCODE_APPLICATION_WARNING | AppHost Application Warning 
        | Microsoft-Windows-Energy-Estimation-Engine| 21 | 17| ActualBrightness |  
        | Microsoft-Windows-Winsock-AFD| 4005 | 17| AFD_OPCODE_MODIFIED | Modified 
        | Microsoft-Windows-WindowsUpdateClient| 33 | 17| AgentStateChange | State Change 
        | Microsoft-Windows-ATAPort| 107 | 17| ATAPORT_OPCODE_CHANNEL_RESET_INIT |  
        | Microsoft-Windows-BranchCache| 27 | 17| CacheSavePersistContent | Saving local cache. 
        | Microsoft-Windows-WorkFolders| 8009 | 17| ChangeBatchApplyStart |  
        | Microsoft-Windows-Application Server-Applications| 202 | 17| ClientMessageInspectorBeforeSendInvoked | ClientMessageInspectorBeforeSendInvoked 
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 103 | 17| CloseConnection | CloseConnection 
        | Microsoft-Windows-WWAN-SVC-EVENTS| 12232 | 17| ConnectionPolicy | ConnectionPolicy 
        | Microsoft-Windows-GPIO-ClassExtension| 1007 | 17| DeferredInterruptActivitiesComplete |  
        | Microsoft-Windows-Dhcp-Client| 50007 | 17| DHCP_OPCODE_INIT_DORA | InitDORA 
        | Microsoft-Windows-DHCPv6-Client| 51005 | 17| DHCPV6_OPCODE_INIT_SARR | InitSARR 
        | Microsoft-Windows-Kernel-EventTracing| 9 | 17| ETW_OPCODE_UNREGISTER | Unregister 
        | Microsoft-Windows-FMS| 40001 | 17| GetFontNameTableStartOp | GetFontNameTable Start 
        | Microsoft-Windows-HttpService| 7 | 17| HTTP_OPCODE_RECEIVE_BODY_LAST | RecvBodyLast 
        | Microsoft-Windows-SPB-ClassExtension| 1018 | 17| IoSpbDirection |  
        | Microsoft-Windows-Kernel-Boot| 67 | 17| NoSinitAcm |  
        | Microsoft-Windows-Audio| 28 | 17| op_EVT_GLITCH_APO_FORMAT_CONVERT | APO Glitch: Format Converter INF detected 
        | Microsoft-Windows-StorPort| 7 | 17| OpCodeRequestTimerCall |  
        | Microsoft-Windows-Store| 8012 | 17| StateChange | Change State 
        | Microsoft-User Experience Virtualization-App Agent| 18 | 17| TrayApp |  
        | Microsoft-Windows-Win32k| 43 | 17| ValidateWindow |  
        | Microsoft-Windows-Diagnosis-DPS| 125 | 17| WDI_DPS_OPCODE_RESOLUTION_START | A scenario instance was dispatched for resolution 
        | Microsoft-Windows-Kernel-WDI| 38 | 17| WDI_SEM_TASK_INIT_OPCODE_SCENARIO_MAX | The SEM is configured with more scenarios than the maximum allowed count. 
        | Microsoft-Windows-AppHost| 10004 | 17| WWAHOST_OPCODE_APPLICATION_INFORMATION | AppHost Application Information 
        | Microsoft-Windows-PrintService| 828 | 17| XPS_PRINT_API_OPCODE_FAILED | XPS Print API failure 
        | Microsoft-Windows-ATAPort| 108 | 18| ATAPORT_OPCODE_CHANNEL_RESET_COMPLETE |  
        | Microsoft-Windows-Application Server-Applications| 204 | 18| ClientParameterInspectorStart | ClientParameterInspectorStart 
        | Microsoft-Windows-Kernel-Boot| 70 | 18| ComputePmrRangesFailure |  
        | Microsoft-Windows-Dhcp-Client| 50009 | 18| DHCP_OPCODE_DISCOVER_SENT | DiscoverSent 
        | Microsoft-Windows-DHCPv6-Client| 51004 | 18| DHCPV6_OPCODE_INIT_CONFIRM_REPLY | InitConfirmReply 
        | Microsoft-Windows-GPIO-ClassExtension| 1008 | 18| DisableInterruptStart |  
        | Microsoft-Windows-Kernel-EventTracing| 14 | 18| ETW_OPCODE_ENABLE | Enable 
        | Microsoft-Windows-FMS| 40002 | 18| GetFontNameTableStopOp | GetFontNameTable Stop 
        | Microsoft-Windows-HttpService| 9 | 18| HTTP_OPCODE_FAST_RESPONSE_LAST | FastRespLast 
        | Microsoft-Windows-Win32k| 44 | 18| InvalidateWindow |  
        | Microsoft-Windows-WorkFolders| 8010 | 18| KnowledgeDownloadStart |  
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 129 | 18| NetworkBinding | NetworkBinding 
        | Microsoft-Windows-WWAN-SVC-EVENTS| 11103 | 18| OIDHandling | OID_Handling 
        | Microsoft-Windows-Audio| 29 | 18| op_EVT_GLITCH_CP_CLIENT_INPUT_NO_MESSAGES | Engine Glitch: CP Client Input Endpoint - No Messages in queue 
        | Microsoft-Windows-StorPort| 8 | 18| OpCodePortPause |  
        | Microsoft-Windows-WindowsUpdateClient| 42 | 18| other | Other 
        | Microsoft-Windows-Energy-Estimation-Engine| 22 | 18| ResidualEnergy |  
        | Microsoft-Windows-Store| 8013 | 18| StartProcessing | Start pumping events 
        | Microsoft-User Experience Virtualization-App Agent| 1014 | 18| TemplateService | Template Service 
        | Microsoft-Windows-USB-USBHUB3| 185 | 18| WARNING | Warning 
        | Microsoft-Windows-Diagnosis-DPS| 126 | 18| WDI_DPS_OPCODE_RESOLUTION_QUEUED | A diagnostic module queued itself for later invocation 
        | Microsoft-Windows-Kernel-WDI| 39 | 18| WDI_SEM_TASK_INIT_OPCODE_SCENARIO_CONTEXT_PROVIDER_MAX | The SEM is configured with a scenario with too many context providers. 
        | Microsoft-Windows-ATAPort| 109 | 19| ATAPORT_OPCODE_DEVICE_RESET_INIT |  
        | Microsoft-Windows-Energy-Estimation-Engine| 24 | 19| BatteryState |  
        | Microsoft-Windows-WorkFolders| 8011 | 19| ChangeBatchGenStart |  
        | Microsoft-Windows-Application Server-Applications| 203 | 19| ClientParameterInspectorStop | ClientParameterInspectorStop 
        | Microsoft-Windows-Dhcp-Client| 50010 | 19| DHCP_OPCODE_OFFER_RECEIVED | OfferReceived 
        | Microsoft-Windows-DHCPv6-Client| 51006 | 19| DHCPV6_OPCODE_SOLICIT_SENT | SolicitSent 
        | Microsoft-Windows-GPIO-ClassExtension| 1009 | 19| DisableInterruptComplete |  
        | Microsoft-Windows-Kernel-EventTracing| 15 | 19| ETW_OPCODE_DISABLE | Disable 
        | Microsoft-Windows-PowerShell| 28683 | 19| Exception | To be used when an exception is raised 
        | Microsoft-Windows-FMS| 40003 | 19| GetNameRecordStartOp | Get Name Record Start 
        | Microsoft-Windows-HttpService| 8 | 19| HTTP_OPCODE_FAST_RESPONSE | FastResp 
        | Microsoft-Windows-Kernel-Boot| 68 | 19| InvalidTxtHeapBiosDataSize |  
        | Microsoft-Windows-SPB-ClassExtension| 1019 | 19| IoLockWatchdogTimeout |  
        | Microsoft-Windows-WWAN-SVC-EVENTS| 12103 | 19| IWLANAvailabilityState | IWLANAvailabilityState 
        | Microsoft-Windows-Audio| 30 | 19| op_EVT_GLITCH_CP_CLIENT_INPUT_SIZE_MISMATCH | Engine Glitch: CP Client Input Endpoint - Queue item does not match requested size 
        | Microsoft-Windows-StorPort| 9 | 19| OpCodePortResume |  
        | Microsoft-Windows-Win32k| 74 | 19| PostGestureInputMessage |  
        | Microsoft-Windows-WindowsUpdateClient| 214 | 19| Revert | Revert 
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 149 | 19| Runtime | Runtime 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 225 | 19| StateTransition | This event is raised during a state transition. 
        | Microsoft-Windows-Store| 8014 | 19| StopProcessing | Stop pumping events 
        | Microsoft-Windows-Diagnosis-DPS| 130 | 19| WDI_DPS_OPCODE_RESOLUTION_END | A diagnostic module completed resolution 
        | Microsoft-Windows-Kernel-WDI| 40 | 19| WDI_SEM_TASK_INIT_OPCODE_SCENARIO_END_EVENT_MAX | The SEM is configured with a scenario that has too many end events. 
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 257 | 20| AdvancedRemoteAppEnabled | AdvancedRemoteAppEnabled 
        | Microsoft-Windows-ATAPort| 110 | 20| ATAPORT_OPCODE_DEVICE_RESET_COMPLETE |  
        | Microsoft-Windows-Dhcp-Client| 50011 | 20| DHCP_OPCODE_OFFER_DISCARDED | OfferDiscarded 
        | Microsoft-Windows-DHCPv6-Client| 51007 | 20| DHCPV6_OPCODE_ADVERTISE_RECEIVED | AdvertiseReceived 
        | Microsoft-Windows-SPB-ClassExtension| 1020 | 20| DIrpPreprocess |  
        | Microsoft-Windows-GPIO-ClassExtension| 1010 | 20| EnableInterruptStart |  
        | Microsoft-Windows-Kernel-EventTracing| 17 | 20| ETW_OPCODE_CONFIGURE | Configure 
        | Microsoft-Windows-FMS| 40004 | 20| GetNameRecordStopOp | Get Name Record Stop 
        | Microsoft-Windows-HttpService| 11 | 20| HTTP_OPCODE_CACHED_AND_SEND | CachedAndSend 
        | Microsoft-Windows-Energy-Estimation-Engine| 25 | 20| MapProcessToApp |  
        | Microsoft-Windows-PowerShell| 45118 | 20| Method | To be used when operation is just executing a method 
        | Microsoft-Windows-Kernel-Boot| 69 | 20| MleHeaderTooOld |  
        | Microsoft-Windows-Audio| 31 | 20| op_EVT_GLITCH_CP_CLIENT_OUTPUT_SERVER_OVERREAD | Engine Glitch: CP Client Output Endpoint - Server Overread 
        | Microsoft-Windows-Diagnostics-Networking| 3000 | 20| op_NDFFailInFramework | The failure occurred in the Framework code. 
        | Microsoft-Windows-StorPort| 10 | 20| OpCodePortPauseDevice |  
        | Microsoft-Windows-International-RegionalOptionsControlPanel| 15009 | 20| Operation | RLOUI operations 
        | Microsoft-Windows-Application Server-Applications| 217 | 20| OperationPrepared | OperationPrepared 
        | Microsoft-Windows-Win32k| 75 | 20| PostGestureMessage |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1201 | 20| RadcCancelDuringExit | This event is raised when the client has not been shutdown cleanly. 
        | Microsoft-Windows-WorkFolders| 8012 | 20| UploadTransferStart |  
        | Microsoft-Windows-Diagnosis-DPS| 135 | 20| WDI_DPS_OPCODE_HOST_CREATE_FAILURE | The Diagnostic Policy Service was not able to instantiate a diagnostic module host 
        | Microsoft-Windows-Kernel-WDI| 41 | 20| WDI_SEM_TASK_INIT_OPCODE_PROVIDER_MAX | The number of providers specified across all scenarios is above the maximum allowed amount. 
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 258 | 21| AdvancedRemoteAppNotEnabled | AdvancedRemoteAppNotEnabled 
        | Microsoft-Windows-Energy-Estimation-Engine| 26 | 21| AppForegroundTime |  
        | Microsoft-Windows-ATAPort| 111 | 21| ATAPORT_OPCODE_CHANNEL_START_INIT |  
        | Microsoft-Windows-Application Server-Applications| 1023 | 21| CompleteBookmark | CompleteBookmark 
        | Microsoft-Windows-Dhcp-Client| 50012 | 21| DHCP_OPCODE_REQUEST_SENT | RequestSent 
        | Microsoft-Windows-DHCPv6-Client| 51008 | 21| DHCPV6_OPCODE_ADVERTISE_DISCARDED | AdvertiseDiscarded 
        | Microsoft-Windows-GPIO-ClassExtension| 1011 | 21| EnableInterruptComplete |  
        | Microsoft-Windows-NlaSvc| 4313 | 21| Failed |  
        | Microsoft-Windows-FMS| 40005 | 21| GetNameStringsStartOp | Get Name Strings Start 
        | Microsoft-Windows-HttpService| 12 | 21| HTTP_OPCODE_FAST_SEND | FastSend 
        | Microsoft-Windows-SPB-ClassExtension| 1021 | 21| IoSpbPayloadStart |  
        | Microsoft-Windows-ParentalControls| 1 | 21| modify | Modify 
        | Microsoft-Windows-Audio| 32 | 21| op_EVT_GLITCH_CP_CLIENT_OUTPUT_READ_POINTER_OVERWRITE | Engine Glitch: CP Client Output Endpoint - Read Pointer Overwrite 
        | Microsoft-Windows-Diagnostics-Networking| 3100 | 21| op_NDFFailInHelper | The failure occurred in the Helper class code. 
        | Microsoft-Windows-StorPort| 11 | 21| OpCodePortResumeDevice |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1202 | 21| RadcUserSignOut | This event is raised when the user tries to sign out from the OOB client. 
        | Microsoft-Windows-Resource-Exhaustion-Resolver| 1015 | 21| RDR_RES_OPCODE_RESOLUTION_START | Events logged when diagnosis is started. 
        | Microsoft-Windows-PowerShell| 32790 | 21| Send | Send (Async) 
        | Microsoft-Windows-Win32k| 117 | 21| TranslationUpdate |  
        | Microsoft-Windows-Diagnosis-DPS| 175 | 21| WDI_DPS_OPCODE_SCENARIO_FAILED | This event is raised when a scenario fails 
        | Microsoft-User Experience Virtualization-App Agent| 702 | 22| AgentService | Agent Service 
        | Microsoft-Windows-ParentalControls| 5 | 22| apprun | Launch 
        | Microsoft-Windows-ATAPort| 112 | 22| ATAPORT_OPCODE_CHANNEL_START_COMPLETE |  
        | Microsoft-Windows-Application Server-Applications| 1019 | 22| CompleteCancelActivity | CompleteCancelActivity 
        | Microsoft-Windows-Dhcp-Client| 50013 | 22| DHCP_OPCODE_ACK_RECEIVED | AckReceived 
        | Microsoft-Windows-DHCPv6-Client| 51009 | 22| DHCPV6_OPCODE_REQUEST_SENT | RequestSent 
        | Microsoft-Windows-Energy-Estimation-Engine| 32 | 22| EnergyNotification |  
        | Microsoft-Windows-FMS| 40006 | 22| GetNameStringsStopOp | Get Name Strings Stop 
        | Microsoft-Windows-HttpService| 13 | 22| HTTP_OPCODE_ZERO_SEND | ZeroSend 
        | Microsoft-Windows-GPIO-ClassExtension| 1012 | 22| InterruptInvokeDeviceIsrStart |  
        | Microsoft-Windows-SPB-ClassExtension| 1022 | 22| IoSpbPayloadTdStart |  
        | Microsoft-Windows-Audio| 33 | 22| op_EVT_GLITCH_CP_SERVER_INPUT_STARVATION | Engine Glitch: CP Server Input Endpoint - Starvation 
        | Microsoft-Windows-StorPort| 12 | 22| OpCodeBusChangeDetected |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1203 | 22| RadcWorkspaceRefresh | This event is raised when the user manually tries to do feed refresh. 
        | Microsoft-Windows-Resource-Exhaustion-Detector| 1003 | 22| RDR_DET_OPCODE_DETECTION_RESULT | Events logged when a problem is detected. 
        | Microsoft-Windows-PowerShell| 32769 | 22| Receive | Receive (Async) 
        | Microsoft-Windows-RemoteDesktopServices-RdpCoreTS| 291 | 22| UDPReverseConnect | UDPReverseConnect 
        | Microsoft-Windows-Diagnosis-DPS| 185 | 22| WDI_DPS_OPCODE_DM_BROKEN | A diagnostic module was moved to a broken state 
        | Microsoft-User Experience Virtualization-App Agent| 1503 | 23| ApplySettingsLocationTemplateCatalog | Apply Settings Location Template Catalog 
        | Microsoft-Windows-ATAPort| 113 | 23| ATAPORT_OPCODE_GET_TELEMETRY_INIT |  
        | Microsoft-Windows-Application Server-Applications| 1016 | 23| CompleteCompletion | CompleteCompletion 
        | Microsoft-Windows-Dhcp-Client| 50014 | 23| DHCP_OPCODE_ACK_DISCARDED | AckDiscarded 
        | Microsoft-Windows-DHCPv6-Client| 51010 | 23| DHCPV6_OPCODE_REPLY_FOR_REQUEST_RECEIVED | ReplyForRequestReceived 
        | Microsoft-Windows-FMS| 40007 | 23| GetFontDataStartOp | Get Font Data Start 
        | Microsoft-Windows-HttpService| 15 | 23| HTTP_OPCODE_SEND_ERROR | SndError 
        | Microsoft-Windows-GPIO-ClassExtension| 1013 | 23| InterruptInvokeDeviceIsrComplete |  
        | Microsoft-Windows-SPB-ClassExtension| 1023 | 23| IoSpbPayloadTdBuffer |  
        | Microsoft-Windows-Audio| 34 | 23| op_EVT_GLITCH_CP_SERVER_OUTPUT_QUEUE_FULL_PACKET_DROP | Engine Glitch: CP Server Output Endpoint - Queue Full Packet Drop 
        | Microsoft-Windows-StorPort| 13 | 23| OpCodeMiniportIORequestServiceTime |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1204 | 23| RadcAdalDifferentUserError | This event is raised when the user tries to login in ADAL page using different user name. 
        | Microsoft-Windows-PowerShell| 28673 | 23| Rehydration | Rehydration 
        | Microsoft-Windows-Energy-Estimation-Engine| 34 | 23| StandbyActivationTime |  
        | Microsoft-Windows-ParentalControls| 13 | 23| system | System 
        | Microsoft-Windows-Win32k| 119 | 23| TranslationUpdateRectClip |  
        | Microsoft-Windows-Diagnosis-DPS| 140 | 23| WDI_DPS_OPCODE_DEBUG | Debug event 
        | Microsoft-Windows-ATAPort| 114 | 24| ATAPORT_OPCODE_GET_TELEMETRY_COMPLETE |  
        | Microsoft-Windows-Application Server-Applications| 1013 | 24| CompleteExecuteActivity | CompleteExecuteActivity 
        | Microsoft-Windows-Dhcp-Client| 50015 | 24| DHCP_OPCODE_NACK_RECEIVED | NackReceived 
        | Microsoft-Windows-DHCPv6-Client| 51011 | 24| DHCPV6_OPCODE_INVALID_REPLY_FOR_REQUEST_RECEIVED | InvalidReplyForRequestReceived 
        | Microsoft-Windows-Kernel-EventTracing| 18 | 24| ETW_OPCODE_USER_MODE_STACK_TRACE | User Mode Stack Trace 
        | Microsoft-Windows-FMS| 40008 | 24| GetFontDataStopOp | Get Font Data Stop 
        | Microsoft-Windows-HttpService| 14 | 24| HTTP_OPCODE_COMPLETE_SEND_ERROR | LastSndError 
        | Microsoft-Windows-GPIO-ClassExtension| 1014 | 24| InterruptPinState |  
        | Microsoft-Windows-SPB-ClassExtension| 1024 | 24| IoSpbPayloadTdStop |  
        | Microsoft-Windows-Audio| 35 | 24| op_EVT_GLITCH_CP_SERVER_OUTPUT_READ_POINTER_OVERWRITE | Engine Glitch: CP Server Output Endpoint - Read Pointer Overwrite 
        | Microsoft-Windows-StorPort| 25 | 24| OpCodeStateChangeDetected |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1205 | 24| RadcWorkspaceEventSuccess | This event is raised when a workspace event like subscribe/update succeeded. 
        | Microsoft-Windows-Resource-Exhaustion-Resolver| 1016 | 24| RDR_RES_OPCODE_RESOLUTION_RESULT | Events logged after performing the resolution actions 
        | Microsoft-Windows-PowerShell| 28675 | 24| SerializationSettings | Serialization settings 
        | Microsoft-Windows-Energy-Estimation-Engine| 35 | 24| StandbyDripsTime |  
        | Microsoft-Windows-Win32k| 120 | 24| UpdateDxAccumFromGDI |  
        | Microsoft-Windows-Diagnosis-DPS| 145 | 24| WDI_DPS_OPCODE_BOOT_PERF_START | This event is raised at the ServiceMain for the service 
        | Microsoft-Windows-ParentalControls| 19 | 24| web | Web 
        | Microsoft-Windows-Application Server-Applications| 1031 | 25| CompleteFault | CompleteFault 
        | Microsoft-User Experience Virtualization-App Agent| 10001 | 25| CscTool | CSC Tool 
        | Microsoft-Windows-Dhcp-Client| 50016 | 25| DHCP_OPCODE_UNKNOWN_MESSAGE_DISCARDED | UnknownMessageDiscarded 
        | Microsoft-Windows-DHCPv6-Client| 51012 | 25| DHCPV6_OPCODE_RENEW_SENT | RenewSent 
        | Microsoft-Windows-Kernel-EventTracing| 28 | 25| ETW_OPCODE_SET_TRAITS | Set Provider Traits 
        | Microsoft-Windows-FMS| 40009 | 25| GdiGetFontRealizationInfoStartOp | GdiGetFontRealizationInfo Start 
        | Microsoft-Windows-HttpService| 16 | 25| HTTP_OPCODE_SERVED_FROM_CACHE | SrvdFrmCache 
        | Microsoft-Windows-SPB-ClassExtension| 1025 | 25| IoSpbPayloadStop |  
        | Microsoft-Windows-GPIO-ClassExtension| 1017 | 25| MaskInterruptsStart |  
        | Microsoft-Windows-Audio| 36 | 25| op_EVT_GLITCH_KSENDPOINT_IOMGR_NO_OUTSTANDING_PACKETS | KS Endpoint Glitch: IOMGR No Outstanding Packets 
        | Microsoft-Windows-StorPort| 26 | 25| OpCodeTargetedReenumeration |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1206 | 25| RadcWorkspaceEventFailure | This event is raised when a workspace event like subscribe/update failed! 
        | Microsoft-Windows-PowerShell| 32869 | 25| ShuttingDown | Shutting down 
        | Microsoft-Windows-Energy-Estimation-Engine| 36 | 25| UnknownEnergy |  
        | Microsoft-Windows-Win32k| 121 | 25| UpdateDxAccumFromDX |  
        | Microsoft-Windows-Diagnosis-DPS| 150 | 25| WDI_DPS_OPCODE_BOOT_PERF_END | This event is raised when the DPS signals its status as RUNNING to the SCM 
        | Microsoft-Windows-Application Server-Applications| 1034 | 26| CompleteRuntime | CompleteRuntime 
        | Microsoft-Windows-Dhcp-Client| 50017 | 26| DHCP_OPCODE_DECLINE_SENT | DeclineSent 
        | Microsoft-Windows-DHCPv6-Client| 51013 | 26| DHCPV6_OPCODE_REPLY_FOR_RENEW_RECEIVED | ReplyForRenewReceived 
        | Microsoft-Windows-Kernel-EventTracing| 29 | 26| ETW_OPCODE_GROUP_JOIN | Join Provider Group 
        | Microsoft-Windows-FMS| 40010 | 26| GdiGetFontRealizationInfoStopOp | GdiGetFontRealizationInfo Stop 
        | Microsoft-Windows-Win32k| 122 | 26| GetDxAccum |  
        | Microsoft-Windows-HttpService| 17 | 26| HTTP_OPCODE_CACHE_NOT_MODIFIED | CachedNotModified 
        | Microsoft-Windows-GPIO-ClassExtension| 1018 | 26| MaskInterruptsComplete |  
        | Microsoft-Windows-Audio| 37 | 26| op_EVT_GLITCH_KSENDPOINT_IOMGR_MAX_IOCTL_TIME | KS Endpoint Glitch: IOMGR Ioctl Time Limit Exceeded 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1208 | 26| RadcDiscoverySuccess | This event is raised when feed discovery succeeds 
        | Microsoft-User Experience Virtualization-App Agent| 14 | 26| SyncController | Synchronization Controller 
        | Microsoft-Windows-Diagnosis-DPS| 155 | 26| WDI_DPS_OPCODE_SHUTDOWN_PERF_START | This event is raised when the service receives a shutdown/stop notification from the SCM 
        | Microsoft-User Experience Virtualization-App Agent| 14000 | 27| AppMonitor | Application Monitor 
        | Microsoft-Windows-Application Server-Applications| 1028 | 27| CompleteTransactionContext | CompleteTransactionContext 
        | Microsoft-Windows-Dhcp-Client| 50018 | 27| DHCP_OPCODE_INFORM_SENT | InformSent 
        | Microsoft-Windows-DHCPv6-Client| 51014 | 27| DHCPV6_OPCODE_INVALID_REPLY_FOR_RENEW_RECEIVED | InvalidReplyForRenewReceived 
        | Microsoft-Windows-FMS| 40011 | 27| FmsErrorOp | FmsErrorMessage 
        | Microsoft-Windows-HttpService| 18 | 27| HTTP_OPCODE_RESERVATION | ResvUrl 
        | Microsoft-Windows-Win32k| 100 | 27| InjectTouchEvent |  
        | Microsoft-Windows-Audio| 38 | 27| op_EVT_GLITCH_KSENDPOINT_BASE_OUTPUT_UNEXPECTED_BUFFER_COMPLETED | KS Endpoint Glitch: BASE Output Unexpected Buffer Completed 
        | Microsoft-Windows-GPIO-ClassExtension| 1019 | 27| QueryActiveInterruptsStart |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1209 | 27| RadcDiscoveryFailure | This event is raised when feed discovery failed! 
        | Microsoft-Windows-Diagnosis-DPS| 160 | 27| WDI_DPS_OPCODE_SHUTDOWN_PERF_END | This event is raised when the service is successfully stopped 
        | Microsoft-Windows-Dhcp-Client| 50019 | 28| DHCP_OPCODE_RELEASE_SENT | ReleaseSent 
        | Microsoft-Windows-DHCPv6-Client| 51015 | 28| DHCPV6_OPCODE_REBIND_SENT | RebindSent 
        | Microsoft-Windows-Application Server-Applications| 3503 | 28| DuplicateQuery | DuplicateQuery 
        | Microsoft-Windows-HttpService| 21 | 28| HTTP_OPCODE_CONNECT | ConnConnect 
        | Microsoft-Windows-Audio| 39 | 28| op_EVT_GLITCH_KSENDPOINT_BASE_INPUT_LAST_BUFFER_NULL_BAD_LOCKED_DATA | KS Endpoint Glitch: BASE Input Null Last Buffer with LockedData != LoopedBuffer 
        | Microsoft-Windows-GPIO-ClassExtension| 1020 | 28| QueryActiveInterruptsComplete |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1210 | 28| RadcCacheCorruption | This event is raised when the feed cache on the client local machine is missing icons or Rdp files due to cache corruption! 
        | Microsoft-Windows-Diagnosis-DPS| 180 | 28| WDI_DPS_OPCODE_GROUPPOLICY_REFRESH | This event is raised when DPS refreshes group policy 
        | Microsoft-Windows-Dhcp-Client| 50020 | 29| DHCP_OPCODE_BROADCASTBIT_TOGGLED | BroadcastbitToggled 
        | Microsoft-Windows-DHCPv6-Client| 51016 | 29| DHCPV6_OPCODE_REPLY_FOR_REBIND_RECEIVED | ReplyForRebindReceived 
        | Microsoft-Windows-Application Server-Applications| 4802 | 29| ExceptionSuppressed | ExceptionSuppressed 
        | Microsoft-Windows-HttpService| 23 | 29| HTTP_OPCODE_CLOSE | ConnClose 
        | Microsoft-Windows-Audio| 40 | 29| op_EVT_GLITCH_KSENDPOINT_BASE_INPUT_BUFFER_INDEX | KS Endpoint Glitch: BASE Input Buffer Index Mismatch 
        | Microsoft-Windows-GPIO-ClassExtension| 1021 | 29| QueryEnabledInterruptsStart |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1211 | 29| RadcConsentStatusUpdateSuccess | This event is raised when user has successfully updated the consent status on server side 
        | Microsoft-Windows-International| 1005 | 30| DataTable | NLS data table operations 
        | Microsoft-Windows-Dhcp-Client| 50021 | 30| DHCP_OPCODE_ERROR_EXTRACTING_OPTIONS | ErrorExtractingOptions 
        | Microsoft-Windows-DHCPv6-Client| 51017 | 30| DHCPV6_OPCODE_INVALID_REPLY_FOR_REBIND_RECEIVED | InvalidReplyForRebindReceived 
        | Microsoft-Windows-Application Server-Applications| 4801 | 30| FailedToClose | FailedToClose 
        | Microsoft-Windows-HttpService| 24 | 30| HTTP_OPCODE_CLEANUP | ConnCleanup 
        | Microsoft-Windows-MUI| 2006 | 30| Initialize | Start 
        | Microsoft-Windows-Audio| 41 | 30| op_EVT_GLITCH_KSENDPOINT_BASE_END_GLITCH | KS Endpoint Glitch: BASE End Glitch 
        | Microsoft-Windows-GPIO-ClassExtension| 1022 | 30| QueryEnabledInterruptsComplete |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1212 | 30| RadcConsentStatusUpdateFailure | This event is raised when user is unable to update the consent status on server! 
        | Microsoft-Windows-Dhcp-Client| 50023 | 31| DHCP_OPCODE_OFFER_RECIEVE_TIMEOUT | OfferReceiveTimeout 
        | Microsoft-Windows-DHCPv6-Client| 51022 | 31| DHCPV6_OPCODE_CONFIRM_SENT | ConfirmSent 
        | Microsoft-Windows-HttpService| 28 | 31| HTTP_OPCODE_SET_URL_GROUP | ChgUrlGrpProp 
        | Microsoft-Windows-LanguagePackSetup| 1009 | 31| Initialize | Language Pack Setup initialization operation 
        | Microsoft-Windows-International| 1001 | 31| Initialize | NLS initialization 
        | Microsoft-Windows-MUI| 3002 | 31| InvokeCallback | Invoke callback function 
        | Microsoft-Windows-NlaSvc| 4407 | 31| MediaConnect |  
        | Microsoft-Windows-Audio| 42 | 31| op_EVT_GLITCH_KSENDPOINT_RTCAP_STREAM_POS_AHEAD_OF_HW_POS | KS Endpoint Glitch: RTCAP StreamPos Ahead of HW Pos 
        | Microsoft-Windows-Resource-Exhaustion-Resolver| 1004 | 31| RDR_RES_OPCODE_UI_START | Events logged before UI is launched. 
        | Microsoft-Windows-Application Server-Applications| 4803 | 31| ReceivedMulticastSuppression | ReceivedMulticastSuppression 
        | Microsoft-Windows-GPIO-ClassExtension| 1023 | 31| ReconfigureInterruptStart |  
        | Microsoft-Windows-Application Server-Applications| 4817 | 32| CreationFailed | CreationFailed 
        | Microsoft-Windows-Dhcp-Client| 50024 | 32| DHCP_OPCODE_ACK_RECEIVE_TIMEOUT | AckReceiveTimeout 
        | Microsoft-Windows-DHCPv6-Client| 51023 | 32| DHCPV6_OPCODE_REPLY_FOR_CONFIRM_RECEIVED | ReplyForConfirmReceived 
        | Microsoft-Windows-MUI| 2008 | 32| DisableCache | Disable live cache 
        | Microsoft-Windows-HttpService| 29 | 32| HTTP_OPCODE_SET_SERVER_SESSION | ChgSrvSesProp 
        | Microsoft-Windows-NlaSvc| 4102 | 32| MediaDisconnect |  
        | Microsoft-Windows-DriverFrameworks-UserMode| 20032 | 32| NestingStart |  
        | Microsoft-Windows-Audio| 43 | 32| op_EVT_GLITCH_KSENDPOINT_RTCAP_STREAM_POS_TOO_FAR_BEHIND | KS Endpoint Glitch: RTCAP StreamPos Too Far Behind 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1213 | 32| RadcViewInvites | This event is raised when the user manually clicks the view invitations button. 
        | Microsoft-Windows-Resource-Exhaustion-Resolver| 1008 | 32| RDR_RES_OPCODE_UI_DISPLAY | Events logged after UI is launched or after an attempt to launch the UI is made. 
        | Microsoft-Windows-GPIO-ClassExtension| 1024 | 32| ReconfigureInterruptComplete |  
        | Microsoft-Windows-Diagnostics-Performance| 103 | 33| Boot_Degradation | Boot Degradation 
        | Microsoft-Windows-Dhcp-Client| 50025 | 33| DHCP_OPCODE_CANCEL_RENEWAL | CancelRenewal 
        | Microsoft-Windows-DHCPv6-Client| 51024 | 33| DHCPV6_OPCODE_INVALID_REPLY_FOR_CONFIRM_RECEIVED | InvalidReplyForConfirmReceived 
        | Microsoft-Windows-Application Server-Applications| 4816 | 33| FindInitiated | FindInitiated 
        | Microsoft-Windows-HttpService| 30 | 33| HTTP_OPCODE_SET_REQUEST_QUEUE | ChgReqQueueProp 
        | Microsoft-Windows-Kernel-Processor-Power| 49 | 33| Makeup |  
        | Microsoft-Windows-DriverFrameworks-UserMode| 20033 | 33| NestingStop |  
        | Microsoft-Windows-Audio| 44 | 33| op_EVT_GLITCH_KSENDPOINT_RTREN_WRITE_POS_EXCEEDS_TOTAL_POS | KS Endpoint Glitch: RTREN WritePos Exceeds TotalPos 
        | Microsoft-Windows-DateTimeControlPanel| 30002 | 33| Operation | Date/Time Control Panel Applet operations 
        | Microsoft-Windows-LanguagePackSetup| 4016 | 33| Operation | Language Pack Setup standard operation 
        | Microsoft-Windows-International| 1503 | 33| Operation | NLS operations 
        | Microsoft-Windows-TZUtil| 1004 | 33| Operation | TZUtil operations 
        | Microsoft-Windows-Kernel-Power| 5 | 33| PhaseStart |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1214 | 33| RadcUserTimeZone | This event is raised when the user starts a new cycle of feed discovery. We log the hashed UPN and timezone information here 
        | Microsoft-Windows-Resource-Exhaustion-Detector| 2004 | 33| RDR_DET_OPCODE_DIAGNOSIS_RESULT | Contains the results of the diagnosis. 
        | Microsoft-Windows-NlaSvc| 4103 | 33| RouteChange |  
        | Microsoft-Windows-GPIO-ClassExtension| 1025 | 33| UnmaskInterruptStart |  
        | Microsoft-Windows-MUI| 2011 | 33| UpdateManifest | Update resource cache manifest 
        | Microsoft-Windows-NlaSvc| 4104 | 34| AddressChange |  
        | Microsoft-User Experience Virtualization-App Agent| 17002 | 34| AppManagementConfiguration |  
        | Microsoft-Windows-Diagnostics-Performance| 100 | 34| Boot_Info | Boot Information 
        | Microsoft-Windows-MUI| 3007 | 34| BuildCache | Build resource cache 
        | Microsoft-Windows-Dhcp-Client| 50044 | 34| DHCP_OPCODE_INFORM_ACK_RECEIVED | InformAckReceived 
        | Microsoft-Windows-DHCPv6-Client| 51019 | 34| DHCPV6_OPCODE_DECLINE_SENT | DeclineSent 
        | Microsoft-Windows-Kernel-Processor-Power| 71 | 34| FailedStart |  
        | Microsoft-Windows-HttpService| 31 | 34| HTTP_OPCODE_ADD_URL | AddUrl 
        | Microsoft-Windows-Audio| 45 | 34| op_EVT_GLITCH_KSENDPOINT_STCAP_CAPTURE_AHEAD | KS Endpoint Glitch: STCAP Capture Ahead 
        | Microsoft-Windows-Application Server-Applications| 4818 | 34| OpenFailed | OpenFailed 
        | Microsoft-Windows-Kernel-Power| 23 | 34| PhaseStop |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1215 | 34| RadcRefreshTime | This event is raised when all the feeds of the user have been subscribed or updated completely. We log the overall time it took to download all feeds in parallel. 
        | Microsoft-Windows-GPIO-ClassExtension| 1026 | 34| UnmaskInterruptComplete |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1106 | 35| CloseEvent | This event is raised when there is a close operation which will tear down the connection. 
        | Microsoft-Windows-Dhcp-Client| 50004 | 35| DHCP_OPCODE_DHCP_ENABLED | DhcpEnabled 
        | Microsoft-Windows-DHCPv6-Client| 51020 | 35| DHCPV6_OPCODE_REPLY_FOR_DECLINE_RECEIVED | ReplyForDeclineReceived 
        | Microsoft-Windows-MUI| 3010 | 35| Entry | Start 
        | Microsoft-Windows-HttpService| 32 | 35| HTTP_OPCODE_REMOVE_URL | RemUrl 
        | Microsoft-Windows-Audio| 46 | 35| op_EVT_GLITCH_KSENDPOINT_STCAP_CAPTURE_BEHIND | KS Endpoint Glitch: STCAP Capture Behind 
        | Microsoft-Windows-Application Server-Applications| 4819 | 35| OpenSucceeded | OpenSucceeded 
        | Microsoft-Windows-NlaSvc| 4105 | 35| QuarantineStateChange |  
        | Microsoft-Windows-GPIO-ClassExtension| 1027 | 35| SpuriousInterruptDetected |  
        | Microsoft-Windows-Diagnostics-Performance| 308 | 35| Standby_Degradation | Standby Degradation 
        | Microsoft-Windows-LanguagePackSetup| 1006 | 35| ValidateParameters | Validate unattended parameters 
        | Microsoft-Windows-Kernel-Power| 9 | 35| Veto |  
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1401 | 36| ClientPipelineProtocolRevision | This event is raised when protocol caps are received from the server. We log the version selected, and the client mode and AVC capability. 
        | Microsoft-Windows-Dhcp-Client| 50005 | 36| DHCP_OPCODE_DHCP_DISABLED | DhcpDisabled 
        | Microsoft-Windows-NlaSvc| 4106 | 36| DhcpNotification |  
        | Microsoft-Windows-DHCPv6-Client| 51021 | 36| DHCPV6_OPCODE_INVALID_REPLY_FOR_DECLINE_RECEIVED | InvalidReplyForDeclineReceived 
        | Microsoft-Windows-Application Server-Applications| 4813 | 36| Duplicate | Duplicate 
        | Microsoft-Windows-MUI| 3009 | 36| Exit | End 
        | Microsoft-Windows-HttpService| 33 | 36| HTTP_OPCODE_REMOVE_ALL_URLS | RemAllUrls 
        | Microsoft-Windows-Audio| 47 | 36| op_EVT_GLITCH_KSENDPOINT_STCAP_DEVICE_STARVED | KS Endpoint Glitch: STCAP Device Starved 
        | Microsoft-Windows-Kernel-Power| 186 | 36| Pended |  
        | Microsoft-Windows-Diagnostics-Performance| 300 | 36| Standby_Info | Standby Information 
        | Microsoft-Windows-LanguagePackSetup| 1012 | 36| ValidateUserPermission | Validate user's permission 
        | Microsoft-Windows-LanguagePackSetup| 2002 | 37| CallNotifyUILanguageChange | Notify the system that a language has been installed or removed 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1402 | 37| ClientPipelineFrameHWMemory | This event is raised when protocol caps are received from the server. We log that hardware resources are being used. 
        | Microsoft-Windows-Dhcp-Client| 50008 | 37| DHCP_OPCODE_STATIC_TO_DHCP | StaticToDhcp 
        | Microsoft-Windows-DHCPv6-Client| 51018 | 37| DHCPV6_OPCODE_RELEASE_SENT | ReleaseSent 
        | Microsoft-Windows-HttpService| 25 | 37| HTTP_OPCODE_CACHE_ENTRY_ADDED | AddedCacheEntry 
        | Microsoft-Windows-Application Server-Applications| 4805 | 37| InvalidContent | InvalidContent 
        | Microsoft-Windows-Audio| 48 | 37| op_EVT_GLITCH_KSENDPOINT_STREN_DEVICE_STARVED | KS Endpoint Glitch: STREN Device Starved 
        | Microsoft-Windows-Diagnostics-Performance| 400 | 37| Shell_Info | Shell Information 
        | Microsoft-Windows-LanguagePackSetup| 1060 | 38| ChangeUserUILanguage | Change the User UI language setting to selected language 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1403 | 38| ClientPipelineFrameSWMemory | This event is raised when protocol caps are received from the server. We log that hardware resources are not being used. 
        | Microsoft-Windows-Dhcp-Client| 50022 | 38| DHCP_OPCODE_FALLBACK_CONFIG_SET | FallbackConfigSet 
        | Microsoft-Windows-DHCPv6-Client| 51025 | 38| DHCPV6_OPCODE_INFOREQUEST_SENT | InfoRequestSent 
        | Microsoft-Windows-HttpService| 26 | 38| HTTP_OPCODE_CACHE_ENTRY_ADD_FAILED | AddCacheEntryFailed 
        | Microsoft-Windows-Application Server-Applications| 4806 | 38| InvalidRelatesToOrOperationCompleted | InvalidRelatesToOrOperationCompleted 
        | Microsoft-Windows-Audio| 49 | 38| op_EVT_GLITCH_KSENDPOINT_STREN_EXCL_PULL_INVALID_BUFFER_COUNT | KS Endpoint Glitch: STREN EXCL PULL Invalid Buffer Count 
        | Microsoft-Windows-Diagnostics-Performance| 403 | 38| Shell_Degradation | Shell Degradation 
        | Microsoft-Windows-Dhcp-Client| 50055 | 39| DHCP_OPCODE_GATEWAY_REACHABLE | GatewayReachable 
        | Microsoft-Windows-DHCPv6-Client| 51026 | 39| DHCPV6_OPCODE_REPLY_FOR_INFOREQUEST_RECEIVED | ReplyForInfoRequestReceived 
        | Microsoft-Windows-HttpService| 27 | 39| HTTP_OPCODE_CACHE_ENTRY_FLUSHED | FlushedCache 
        | Microsoft-Windows-Application Server-Applications| 4807 | 39| InvalidReplyTo | InvalidReplyTo 
        | Microsoft-Windows-Audio| 58 | 39| op_EVT_MMDEVAPI_TRIGGER_DEFAULT_DEVICE_CHANGED | MMDevAPI: Default device changed triggered 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1216 | 39| RadcDetailedAdalError | This event is raised when there is error in acquiring ADAL token. 
        | Microsoft-Windows-Diagnostics-Performance| 500 | 39| VidMem_Degradation | Video Memory Degradation 
        | Microsoft-Windows-LanguagePackSetup| 2003 | 40| ChangeSystemUILanguage | Change the System UI language setting to selected language 
        | Microsoft-Windows-Dhcp-Client| 50056 | 40| DHCP_OPCODE_GATEWAY_UNREACHABLE | GatewayUnreachable 
        | Microsoft-Windows-DHCPv6-Client| 51027 | 40| DHCPV6_OPCODE_INVALID_REPLY_FOR_INFOREQUEST_RECEIVED | InvalidReplyForInfoRequestReceived 
        | Microsoft-Windows-HttpService| 34 | 40| HTTP_OPCODE_SSL_CONNECT | SslConnEvent 
        | Microsoft-Windows-Application Server-Applications| 4808 | 40| NoContent | NoContent 
        | Microsoft-Windows-Audio| 61 | 40| op_EVT_MMDEVAPI_ON_MEDIA_NOTIFICATION_DeviceStateChanged | MMDevAPI: DeviceStateChanged callback 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1217 | 40| RadcAdalTokenCollected | This event is raised when ADAL authentication token is successfully created. 
        | Microsoft-Windows-Diagnostics-Performance| 200 | 40| Shutdown_Info | Shutdown Information 
        | Microsoft-Windows-Dhcp-Client| 50028 | 41| DHCP_OPCODE_ADDRESS_PLUMBED | AddressPlumbed 
        | Microsoft-Windows-HttpService| 35 | 41| HTTP_OPCODE_SSL_HANDSHAKE_INITIATE | SslInitiateHandshake 
        | Microsoft-Windows-Application Server-Applications| 4809 | 41| NullMessageId | NullMessageId 
        | Microsoft-Windows-Audio| 62 | 41| op_EVT_MMDEVAPI_ON_MEDIA_NOTIFICATION_DeviceAdded | MMDevAPI: DeviceAdded callback 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1218 | 41| RadcAdalCancelled | This event is raised when ADAL authentication is cancelled. 
        | Microsoft-Windows-Resource-Exhaustion-Resolver| 1014 | 41| RDR_RES_OPCODE_LEAK_DIAGNOSIS_START | Events logged after an attempt to launch the leak diagnoser is made. 
        | Microsoft-Windows-Diagnostics-Performance| 202 | 41| Shutdown_Degradation | Shutdown Degradation 
        | Microsoft-Windows-Dhcp-Client| 50029 | 42| DHCP_OPCODE_ADDRESS_UNPLUMBED | AddressUnplumbed 
        | Microsoft-Windows-DHCPv6-Client| 51029 | 42| DHCPV6_OPCODE_ERROR_CREATING_PACKET | ErrorCreatingPacket 
        | Microsoft-Windows-HttpService| 36 | 42| HTTP_OPCODE_SSL_HANDSHAKE_COMPLETE | SslHandshakeComplete 
        | Microsoft-Windows-Application Server-Applications| 4810 | 42| NullMessageSequence | NullMessageSequence 
        | Microsoft-Windows-Audio| 63 | 42| op_EVT_MMDEVAPI_ON_MEDIA_NOTIFICATION_DeviceRemoved | MMDevAPI: DeviceRemoved callback 
        | Microsoft-Windows-Diagnostics-Performance| 501 | 42| VidMem_Responsiveness | Video Memory Responsiveness 
        | Microsoft-Windows-Dhcp-Client| 50030 | 43| DHCP_OPCODE_PLUMBING_ERROR | PlumbingError 
        | Microsoft-Windows-DHCPv6-Client| 51030 | 43| DHCPV6_OPCODE_ERROR_EXTRACTING_OPTIONS | ErrorExtractingOptions 
        | Microsoft-Windows-HttpService| 37 | 43| HTTP_OPCODE_SSL_RECEIVE_CLIENT_CERT_INITIATE | SslInititateSslRcvClientCert 
        | Microsoft-Windows-Application Server-Applications| 4811 | 43| NullRelatesTo | NullRelatesTo 
        | Microsoft-Windows-Audio| 64 | 43| op_EVT_MMDEVAPI_ON_MEDIA_NOTIFICATION_DefaultDeviceChanged | MMDevAPI: DefaultDeviceChanged callback 
        | Microsoft-Windows-LanguagePackSetup| 1009 | 43| ValidatePath | Validate specified path 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1404 | 44| ClientPipelineError | This event is raised if a pipeline error is encountered during execution. We log the faulting component, function, and error code. 
        | Microsoft-Windows-Dhcp-Client| 1005 | 44| DHCP_OPCODE_IP_CONFLICT | IPConflict 
        | Microsoft-Windows-DHCPv6-Client| 51036 | 44| DHCPV6_OPCODE_ERROR_IN_PARSING | ErrorInParsing 
        | Microsoft-Windows-HttpService| 38 | 44| HTTP_OPCODE_SSL_RECEIVE_CLIENT_CERT_COMPLETE | SslRcvClientCertFailed 
        | Microsoft-Windows-Application Server-Applications| 4812 | 44| NullReplyTo | NullReplyTo 
        | Microsoft-Windows-Audio| 101 | 44| op_EVT_MIDIRT_ON_SUSPEND | MidiRT: Application Suspension Handler 
        | Microsoft-Windows-Dhcp-Client| 50032 | 45| DHCP_OPCODE_LEASE_EXPIRED | LeaseExpired 
        | Microsoft-Windows-DHCPv6-Client| 51037 | 45| DHCPV6_OPCODE_INFORMATION_REFRESH_TIME_OPTION_RECEIVED | InformationRefreshTimeOptionReceived 
        | Microsoft-Windows-HttpService| 39 | 45| HTTP_OPCODE_SSL_RECEIVE_RAW_DATA | SslRcvdRawData 
        | Microsoft-Windows-Audio| 102 | 45| op_EVT_MIDIRT_ON_RESUME | MidiRT: Application Resume Handler 
        | Microsoft-Windows-Application Server-Applications| 4804 | 45| ReceivedAfterOperationCompleted | ReceivedAfterOperationCompleted 
        | Microsoft-Windows-LanguagePackSetup| 1013 | 45| ValidateLangPackForInstall | Validate that language pack can be installed 
        | Microsoft-Windows-Dhcp-Client| 50033 | 46| DHCP_OPCODE_INTERFACE_ADDED | InterfaceAdded 
        | Microsoft-Windows-DHCPv6-Client| 51038 | 46| DHCPV6_OPCODE_INFORMATION_REFRESH_TIME_EXPIRED | InformationRefreshTimeExpired 
        | Microsoft-Windows-HttpService| 40 | 46| HTTP_OPCODE_SSL_DELIVER_STREAM_DATA | SslDlvrdStreamData 
        | Microsoft-Windows-Audio| 103 | 46| op_EVT_MIDIRT_ON_ENTER_CS | MidiRT: Application Entering CS Handler 
        | Microsoft-Windows-Application Server-Applications| 4820 | 46| Reset | Reset 
        | Microsoft-Windows-LanguagePackSetup| 1017 | 46| VerifyDiskSpace | Verify if the machine has sufficient disk space for the installation 
        | Microsoft-Windows-LanguagePackSetup| 2009 | 47| CallCBSInstallLangPack | Pass control to CBS to install the language pack 
        | Microsoft-Windows-Dhcp-Client| 50034 | 47| DHCP_OPCODE_ERROR_INITIALIZE_INTERFACE | ErrorInitializeInterface 
        | Microsoft-Windows-DHCPv6-Client| 60000 | 47| DHCPV6_OPCODE_PERFTRACK_SARR | PerfTrackSARR 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1034 | 47| GenericClientEvent | This is a generic event that may be raised by the client. 
        | Microsoft-Windows-HttpService| 41 | 47| HTTP_OPCODE_SSL_ACCEPT_STREAM_DATA | SslAcceptStreamData 
        | Microsoft-Windows-Audio| 104 | 47| op_EVT_MIDIRT_ON_EXIT_CS | MidiRT: Application Resuming from CS Handler 
        | Microsoft-Windows-Application Server-Applications| 4821 | 47| SetToNull | SetToNull 
        | Microsoft-Windows-Application Server-Applications| 711 | 48| BeforeAuthorization | BeforeAuthorization 
        | Microsoft-Windows-Dhcp-Client| 50035 | 48| DHCP_OPCODE_ROUTE_UPDATED | RouteUpdated 
        | Microsoft-Windows-DHCPv6-Client| 60001 | 48| DHCPV6_OPCODE_PERFTRACK_INFOREQUEST | PerfTrackInfoRequest 
        | Microsoft-Windows-TerminalServices-ClientActiveXCore| 1033 | 48| GenericClientError | This is a generic error that may be signaled by the client. 
        | Microsoft-Windows-Audio| 105 | 48| op_EVT_MIDIRT_ON_DEVICE_REMOVE | MidiRT: Device Removal Handler 
        | Microsoft-Windows-LanguagePackSetup| 1040 | 48| ValidateLangPackForRemoval | Validate that language pack can be removed 
        | Microsoft-Windows-LanguagePackSetup| 1043 | 49| CallCBSRemoveLangPack | Pass control to CBS to remove the language pack 
        | Microsoft-Windows-Dhcp-Client| 50058 | 49| DHCP_OPCODE_SUCCESSFUL_LEASE | SuccessfulLease 
        | Microsoft-Windows-DHCPv6-Client| 51031 | 49| DHCPV6_OPCODE_STATEFUL_TO_STATELESS | StatefulToStateless 
        | Microsoft-Windows-Application Server-Applications| 709 | 49| DispatchStart | DispatchStart 
        | Microsoft-Windows-HttpService| 19 | 49| HTTP_OPCODE_IP_LISTEN_LIST_ENTRY_READ | ReadIpListEntry 
        | Microsoft-Windows-Audio| 106 | 49| op_EVT_MIDIRT_DEL_MidiDeviceIoControl | MidiRT: Cleanup and release device handle 
        | Microsoft-Windows-Dhcp-Client| 50059 | 50| DHCP_OPCODE_ROUTE_ADDED | RouteAdded 
        | Microsoft-Windows-DHCPv6-Client| 51032 | 50| DHCPV6_OPCODE_STATELESS_TO_STATEFUL | StatelessToStateful 
        | Microsoft-Windows-Application Server-Applications| 712 | 50| DispatchStop | DispatchStop 
        | Microsoft-Windows-HttpService| 20 | 50| HTTP_OPCODE_SSL_CREDENTIAL_CREATED | CreatedSslCred 
        | Microsoft-Windows-LanguagePackSetup| 1011 | 50| InitWizard | Initialize the LpkSetup wizard 
        | Microsoft-Windows-Audio| 107 | 50| op_EVT_MIDIRT_DeviceHandleClosed | MidiRT: Close handle to MIDI Device 
        | Microsoft-Windows-EnhancedStorage-EhStorTcgDrv| 12 | 50| Opcode.General | General 
        | Microsoft-Windows-NlaSvc| 4251 | 51| DataIndication |  
        | Microsoft-Windows-Dhcp-Client| 50060 | 51| DHCP_OPCODE_ROUTE_DELETED | RouteDeleted 
        | Microsoft-Windows-DHCPv6-Client| 51033 | 51| DHCPV6_OPCODE_NONDHCP_TO_STATEFUL | NonDhcpToStateful 
        | Microsoft-Windows-Application Server-Applications| 208 | 51| DispathMessageInspectorAfterReceiveInvoked | DispathMessageInspectorAfterReceiveInvoked 
        | Microsoft-Windows-HttpService| 10 | 51| HTTP_OPCODE_SEND_COMPLETE | SendComplete 
        | Microsoft-Windows-Audio| 110 | 51| op_EVT_MIDIRT_CreateMidiPortDeviceAccessInstance | MidiRT: Create new MidiPortDeviceIoControl 
        | Microsoft-Windows-Dhcp-Client| 50062 | 52| DHCP_OPCODE_START_GATEWAY_REACHABILITY_TEST | StartGatewayReachabilityTest 
        | Microsoft-Windows-DHCPv6-Client| 51034 | 52| DHCPV6_OPCODE_NONDHCP_TO_STATELESS | NonDhcpToStateless 
        | Microsoft-Windows-Application Server-Applications| 209 | 52| DispathMessageInspectorBeforeSendInvoked | DispathMessageInspectorBeforeSendInvoked 
        | Microsoft-Windows-HttpService| 43 | 52| HTTP_OPCODE_AUTH_SSPI | SspiCall 
        | Microsoft-Windows-Audio| 129 | 52| op_AudioResourceManager_StreamSettings_Derived | Derived stream settings for stream 
        | Microsoft-Windows-Dhcp-Client| 50063 | 53| DHCP_OPCODE_NLA_NOTIFIED | NLANotified 
        | Microsoft-Windows-DHCPv6-Client| 51035 | 53| DHCPV6_OPCODE_STATIC_MODE | StaticMode 
        | Microsoft-Windows-HttpService| 44 | 53| HTTP_OPCODE_AUTH_CACHE_ENTRY_ADDED | AuthCacheEntryAdded 
        | Microsoft-Windows-Audio| 130 | 53| op_AudioResourceManager_Stream_Created | Created StreamGroup and stream 
        | Microsoft-Windows-Application Server-Applications| 205 | 53| OperationInvokerStart | OperationInvokerStart 
        | Microsoft-Windows-Dhcp-Client| 50064 | 54| DHCP_OPCODE_CACHE_SCAVENGER_RUN | CacheScavengerRun 
        | Microsoft-Windows-DHCPv6-Client| 51039 | 54| DHCPV6_OPCODE_ADDRESS_PLUMBED | AddressPlumbed 
        | Microsoft-Windows-HttpService| 45 | 54| HTTP_OPCODE_AUTH_CACHE_ENTRY_FREED | AuthCacheEntryFreed 
        | Microsoft-Windows-Audio| 131 | 54| op_AudioResourceManager_SaDevice_Created | Created SaDevice 
        | Microsoft-Windows-Application Server-Applications| 214 | 54| OperationInvokerStop | OperationInvokerStop 
        | Microsoft-Windows-Dhcp-Client| 50065 | 55| DHCP_OPCODE_NETWORK_HINT_MATCH_FOUND | NetworkHintMatchFound 
        | Microsoft-Windows-DHCPv6-Client| 51040 | 55| DHCPV6_OPCODE_ADDRESS_UNPLUMBED | AddressUnplumbed 
        | Microsoft-Windows-HttpService| 22 | 55| HTTP_OPCODE_CONNECT_ID | ConnIdAssgn 
        | Microsoft-Windows-Audio| 132 | 55| op_AudioResourceManager_SaDevice_Connected | Connected StreamGroup to SaDevice 
        | Microsoft-Windows-Application Server-Applications| 212 | 55| ParameterInspectorStart | ParameterInspectorStart 
        | Microsoft-Windows-Dhcp-Client| 50066 | 56| DHCP_OPCODE_MATCHED_ADDRESS_PLUMBED | MatchedAddressPlumbed 
        | Microsoft-Windows-DHCPv6-Client| 1005 | 56| DHCPV6_OPCODE_IP_CONFLICT | IPConflict 
        | Microsoft-Windows-HttpService| 46 | 56| HTTP_OPCODE_QOS_FLOW_SET | QosFlowSetReset 
        | Microsoft-Windows-Audio| 65 | 56| op_EVT_MMDEVAPI_DEVICE_STATE_CHANGED | MMDevAPI: Audio device state changed 
        | Microsoft-Windows-Application Server-Applications| 211 | 56| ParameterInspectorStop | ParameterInspectorStop 
        | Microsoft-Windows-Dhcp-Client| 50067 | 57| DHCP_OPCODE_NETWORK_HINT_RECIEVED | NetworkHintReceived 
        | Microsoft-Windows-HttpService| 47 | 57| HTTP_OPCODE_LOGGING_CONFIG_FAILED | LoggingConfigFailed 
        | Microsoft-Windows-EnhancedStorage-EhStorTcgDrv| 10 | 57| Opcode.TcgLib | TcgLib 
        | Microsoft-Windows-Application Server-Applications| 3392 | 57| TransactionScopeCreate | TransactionScopeCreate 
        | Microsoft-Windows-Dhcp-Client| 60000 | 58| DHCP_OPCODE_PERFTRACK_ACK_CONFIRM | PerfTrackAckConfirm 
        | Microsoft-Windows-DHCPv6-Client| 1008 | 58| DHCPV6_OPCODE_INIT_NETWORK_INTERFACE_FAILED | InitNetworkInterfaceFailed 
        | Microsoft-Windows-Application Server-Applications| 4814 | 58| Disabled | Disabled 
        | Microsoft-Windows-HttpService| 48 | 58| HTTP_OPCODE_LOGGING_CONFIG | LoggingConfig 
        | Microsoft-Windows-Dhcp-Client| 60001 | 59| DHCP_OPCODE_PERFTRACK_ACK_DORA | PerfTrackAckDORA 
        | Microsoft-Windows-DHCPv6-Client| 51045 | 59| DHCPV6_OPCODE_ERROR_PLUMBING_PARAMETERS | ErrorPlumbingParameters 
        | Microsoft-Windows-Application Server-Applications| 4815 | 59| Enabled | Enabled 
        | Microsoft-Windows-HttpService| 49 | 59| HTTP_OPCODE_LOGGING_CREATE_FAILURE | LogFileCreateFailed 
        | Microsoft-Windows-Dhcp-Client| 60002 | 60| DHCP_OPCODE_PERFTRACK_GATEWAY_REACHABLE | PerfTrackGatewayReachable 
        | Microsoft-Windows-DHCPv6-Client| 51048 | 60| DHCPV6_OPCODE_ERROR_OPENING_SOCKET | ErrorOpeningSocket 
        | Microsoft-Windows-Application Server-Applications| 1141 | 60| Empty | Empty 
        | Microsoft-Windows-HttpService| 50 | 60| HTTP_OPCODE_LOGGING_CREATE | LogFileCreate 
        | Microsoft-Windows-Dhcp-Client| 60003 | 61| DHCP_OPCODE_PERFTRACK_STATIC | PerfTrackStatic 
        | Microsoft-Windows-DHCPv6-Client| 51049 | 61| DHCPV6_OPCODE_ERROR_CLOSING_SOCKET | ErrorClosingSocket 
        | Microsoft-Windows-HttpService| 51 | 61| HTTP_OPCODE_LOGGING_WRITE | LogFileWrite 
        | Microsoft-Windows-Application Server-Applications| 1143 | 61| NextNull | NextNull 
        | Microsoft-Windows-NlaSvc| 5001 | 61| Stabilized |  
        | Microsoft-Windows-Dhcp-Client| 60014 | 62| DHCP_OPCODE_PERFTRACK_FALLBACK_ADDRESS_SET | PerfTrackFallbackAddressSet 
        | Microsoft-Windows-DHCPv6-Client| 51046 | 62| DHCPV6_OPCODE_SERVICE_START | ServiceStart 
        | Microsoft-Windows-HttpService| 95 | 62| HTTP_OPCODE_PARSE_FAILURE | ParseRequestFailed 
        | Microsoft-Windows-Application Server-Applications| 1146 | 62| SwitchCase | SwitchCase 
        | Microsoft-Windows-Dhcp-Client| 60005 | 63| DHCP_OPCODE_PERFTRACK_TOGGLE_REQUEST_ACK | PerfTrackToggleRequestAck 
        | Microsoft-Windows-DHCPv6-Client| 51047 | 63| DHCPV6_OPCODE_SERVICE_STOP | ServiceStop 
        | Microsoft-Windows-HttpService| 53 | 63| HTTP_OPCODE_TIMEOUT | ConnTimedOut 
        | Microsoft-Windows-Application Server-Applications| 1148 | 63| SwitchCaseNotFound | SwitchCaseNotFound 
        | Microsoft-Windows-Dhcp-Client| 60016 | 64| DHCP_OPCODE_PERFTRACK_TOGGLE_DORA_ACK | PerfTrackToggleDORAAck 
        | Microsoft-Windows-Application Server-Applications| 1147 | 64| SwitchDefault | SwitchDefault 
        | Microsoft-Windows-Dhcp-Client| 60017 | 65| DHCP_OPCODE_PERFTRACK_TOGGLE_INIT_DORA | PerfTrackToggleInitDORA 
        | Microsoft-Windows-DHCPv6-Client| 51050 | 65| DHCPV6_OPCODE_DNS_REGISTRATION_DONE | DnsRegistrationDone 
        | Microsoft-Windows-Dhcp-Client| 50039 | 66| DHCP_OPCODE_ERROR_OPENING_SOCKET | ErrorOpeningSocket 
        | Microsoft-Windows-DHCPv6-Client| 51051 | 66| DHCPV6_OPCODE_DNS_DEREGISTRATION_DONE | dnsDeregistrationDone 
        | Microsoft-Windows-HttpService| 56 | 66| HTTP_OPCODE_SSL_ACH_FAILURE | SslEndpointCreationFailed 
        | Microsoft-Windows-Dhcp-Client| 50040 | 67| DHCP_OPCODE_ERROR_CLOSING_SOCKET | ErrorClosingSocket 
        | Microsoft-Windows-DHCPv6-Client| 51044 | 67| DHCPV6_OPCODE_ERROR_INITIALIZING_INTERFACE | ErrorInitializingInterface 
        | Microsoft-Windows-HttpService| 57 | 67| HTTP_OPCODE_SSL_DISCONNECT | SslDisconnEvent 
        | Microsoft-Windows-Dhcp-Client| 50036 | 68| DHCP_OPCODE_SERVICE_START | ServiceStart 
        | Microsoft-Windows-DHCPv6-Client| 50057 | 68| DHCPV6_OPCODE_NETWORK_ERROR | NetworkError 
        | Microsoft-Windows-HttpService| 58 | 68| HTTP_OPCODE_SSL_DISCONNECT_REQUEST | SslDisconnReq 
        | Microsoft-Windows-Application Server-Applications| 3501 | 69| Contract | Contract 
        | Microsoft-Windows-Dhcp-Client| 50037 | 69| DHCP_OPCODE_SERVICE_STOP | ServiceStop 
        | Microsoft-Windows-DHCPv6-Client| 51058 | 69| DHCPV6_OPCODE_STATEFUL_TO_STATEFUL | StatefulToStateful 
        | Microsoft-Windows-HttpService| 59 | 69| HTTP_OPCODE_SSL_UNSEAL_MESSAGE | SslUnsealMsg 
        | Microsoft-Windows-Dhcp-Client| 50038 | 70| DHCP_OPCODE_ERROR_INIT_SERVICE | ErrorInitService 
        | Microsoft-Windows-DHCPv6-Client| 51059 | 70| DHCPV6_OPCODE_INVALID_MESSAGE_DISCARDED | InvalidMessageDiscarded 
        | Microsoft-Windows-HttpService| 60 | 70| HTTP_OPCODE_SSL_QUERY_CONN_INFO_FAILURE | SslQueryConnInfoFailed 
        | Microsoft-Windows-Application Server-Applications| 3502 | 70| Operation | Operation 
        | Microsoft-Windows-Dhcp-Client| 50041 | 71| DHCP_OPCODE_DOMAIN_CHANGE_NOTIFICATION | DomainChangeNotification 
        | Microsoft-Windows-DHCPv6-Client| 51061 | 71| DHCPV6_OPCODE_ADDRESS_ALREADY_EXISTS | AddressAlreadyExists 
        | Microsoft-Windows-Application Server-Applications| 1132 | 71| DoesNotUseAsyncPattern | DoesNotUseAsyncPattern 
        | Microsoft-Windows-HttpService| 61 | 71| HTTP_OPCODE_SSL_ENDPOINT_CONFIG_NOT_FOUND | SslEndpointConfigNotFound 
        | Microsoft-Windows-Dhcp-Client| 50042 | 72| DHCP_OPCODE_DNS_REGISTRATION_DONE | DnsRegistrationDone 
        | Microsoft-Windows-DHCPv6-Client| 1000 | 72| DHCPV6_OPCODE_LOST_IP_ADDRESS | LostIpAddress 
        | Microsoft-Windows-HttpService| 62 | 72| HTTP_OPCODE_SSL_ASC_RESULT | SslAsc 
        | Microsoft-Windows-Application Server-Applications| 1125 | 72| IsNotStatic | IsNotStatic 
        | Microsoft-Windows-Dhcp-Client| 50043 | 73| DHCP_OPCODE_DNS_DEREGISTRATION_DONE | DnsDeregistrationDone 
        | Microsoft-Windows-DHCPv6-Client| 51060 | 73| DHCPV6_OPCODE_SET_CLASS_ID | SetClassID 
        | Microsoft-Windows-HttpService| 63 | 73| HTTP_OPCODE_SSL_SEAL_MESSAGE | SslSealMsg 
        | Microsoft-Windows-Application Server-Applications| 1124 | 73| IsStatic | IsStatic 
        | Microsoft-Windows-Dhcp-Client| 1000 | 74| DHCP_OPCODE_LOST_IP_ADDRESS | LostIpAddress 
        | Microsoft-Windows-DHCPv6-Client| 51062 | 74| DHCPV6_OPCODE_FAILED_TO_OBTAIN_LEASE | FailedToObtainLease 
        | Microsoft-Windows-HttpService| 64 | 74| HTTP_OPCODE_REQUEST_REJECTED | RequestRejected 
        | Microsoft-Windows-Application Server-Applications| 1126 | 74| ThrewException | ThrewException 
        | Microsoft-Windows-Dhcp-Client| 1001 | 75| DHCP_OPCODE_IP_ADDRESS_NOT_ASSIGNED | IpAddressNotAssigned 
        | Microsoft-Windows-DHCPv6-Client| 1003 | 75| DHCPV6_OPCODE_LEASE_RENEWAL_FAILED | LeaseRenewalFailed 
        | Microsoft-Windows-HttpService| 65 | 75| HTTP_OPCODE_REQUEST_CANCELLED | RequestCancelled 
        | Microsoft-Windows-Application Server-Applications| 1131 | 75| UseAsyncPattern | UseAsyncPattern 
        | Microsoft-Windows-Dhcp-Client| 1002 | 76| DHCP_OPCODE_IP_LEASE_DENIED | IpLeaseDenied 
        | Microsoft-Windows-DHCPv6-Client| 1004 | 76| DHCPV6_OPCODE_ERROR_SERVICE_STOP | ErrorServiceStop 
        | Microsoft-Windows-HttpService| 66 | 76| HTTP_OPCODE_HOTADD_PROC_FAILURE | HotAddProcFailed 
        | Microsoft-Windows-Application Server-Applications| 2023 | 76| Missed | Missed 
        | Microsoft-Windows-Dhcp-Client| 1003 | 77| DHCP_OPCODE_IP_LEASE_RENEWAL_FAILED | IpLeaseRenewalFailed 
        | Microsoft-Windows-DHCPv6-Client| 51063 | 77| DHCPV6_OPCODE_FIREWALL_PORT_EXEMPTED | FirewallPortExempted 
        | Microsoft-Windows-Application Server-Applications| 3383 | 77| Faulted | Faulted 
        | Microsoft-Windows-HttpService| 67 | 77| HTTP_OPCODE_HOTADD_PROC_SUCCESS | HotAddProcSucceeded 
        | Microsoft-Windows-Dhcp-Client| 1004 | 78| DHCP_OPCODE_ERROR_SERVICE_STOP | ErrorServiceStop 
        | Microsoft-Windows-DHCPv6-Client| 51064 | 78| DHCPV6_OPCODE_FIREWALL_PORT_CLOSED | FirewallPortClosed 
        | Microsoft-Windows-HttpService| 68 | 78| HTTP_OPCODE_INIT_USER_RESPONSE_FLOW | UserResponseFlowInit 
        | Microsoft-Windows-Application Server-Applications| 3382 | 78| Reconnect | Reconnect 
        | Microsoft-Windows-Dhcp-Client| 1006 | 79| DHCP_OPCODE_AUTOCONFIGURATION_FAILED | AutoconfigurationFailed 
        | Microsoft-Windows-DHCPv6-Client| 51065 | 79| DHCPV6_OPCODE_INTERFACE_MODE_CHANGING | ModeChanging 
        | Microsoft-Windows-HttpService| 69 | 79| HTTP_OPCODE_INIT_CACHED_RESPONSE_FLOW | CachedResponseFlowInit 
        | Microsoft-Windows-Application Server-Applications| 3381 | 79| SequenceAck | SequenceAck 
        | Microsoft-Windows-Application Server-Applications| 3830 | 80| AbortingChannel | AbortingChannel 
        | Microsoft-Windows-Dhcp-Client| 1007 | 80| DHCP_OPCODE_AUTOCONFIGURATION_SUCCESS | AutoconfigurationSuccess 
        | Microsoft-Windows-DHCPv6-Client| 51066 | 80| DHCPV6_OPCODE_AGGRESSIVE_RETRY_ON | AggressiveRetryOn 
        | Microsoft-Windows-HttpService| 70 | 80| HTTP_OPCODE_INIT_FLOW_FAILED | FlowInitFailed 
        | Microsoft-Windows-Application Server-Applications| 3821 | 81| CloseFailed | CloseFailed 
        | Microsoft-Windows-Dhcp-Client| 1008 | 81| DHCP_OPCODE_INIT_NETWORK_INTERFACE_FAILED | InitNetworkInterfaceFailed 
        | Microsoft-Windows-DHCPv6-Client| 51069 | 81| DHCPV6_OPCODE_DONT_START_SOLICIT_IN_CS | DontStartSolicitInCSSinceV4Plumbed 
        | Microsoft-Windows-HttpService| 71 | 81| HTTP_OPCODE_SET_CONNECTION_FLOW | SetConnectionFlow 
        | Microsoft-Windows-Application Server-Applications| 3810 | 82| ConfigurationApplied | ConfigurationApplied 
        | Microsoft-Windows-Dhcp-Client| 1018 | 82| DHCP_OPCODE_DHCPV6_INIT_FAILED | Dhcpv6InitFailed 
        | Microsoft-Windows-DHCPv6-Client| 51070 | 82| DHCPV6_OPCODE_START_SOLICIT_IN_CS_NO_V4 | StartSolicitInCSSinceV4Unplumbed 
        | Microsoft-Windows-HttpService| 72 | 82| HTTP_OPCODE_REQUEST_ON_CONFIG_FLOW | RequestAssociatedToConfigurationFlow 
        | Microsoft-Windows-Dhcp-Client| 50053 | 83| DHCP_OPCODE_NETWORK_ERROR | NetworkError 
        | Microsoft-Windows-DHCPv6-Client| 51067 | 83| DHCPV6_OPCODE_ABANDON_SOLICIT_IN_CS_DHCP | AbandonSolicitInCSSinceDhcp 
        | Microsoft-Windows-Application Server-Applications| 3818 | 83| DuplexCallbackException | DuplexCallbackException 
        | Microsoft-Windows-HttpService| 73 | 83| HTTP_OPCODE_CONNECTION_FLOW_FAILURE | ConnectionFlowFailed 
        | Microsoft-Windows-Dhcp-Client| 50061 | 84| DHCP_OPCODE_RECEIVED_OFFER_FOR_DIAGNOSTICS | OfferReceivedForDiagnostics 
        | Microsoft-Windows-DHCPv6-Client| 51077 | 84| DHCPV6_OPCODE_START_SOLICIT_IN_CS_COMPULSORY | StartSolicitInCSAtCompulsoryTime 
        | Microsoft-Windows-Application Server-Applications| 3831 | 84| HandledException | HandledException 
        | Microsoft-Windows-HttpService| 74 | 84| HTTP_OPCODE_RESPONSE_RANGE_PROCESSING_OK | ResponseRangeProcessingOK 
        | Microsoft-Windows-Dhcp-Client| 50068 | 85| DHCP_OPCODE_ADDRESS_ALREADY_EXISTS | AddressAlreadyExists 
        | Microsoft-Windows-DHCPv6-Client| 50071 | 85| DHCPV6_OPCODE_NIC_REFERENCE_ACQUIRE | AcquireNICReference 
        | Microsoft-Windows-HttpService| 75 | 85| HTTP_OPCODE_BEGIN_BUILDING_SLICES | BeginBuildingSlices 
        | Microsoft-Windows-Application Server-Applications| 3827 | 85| TransmitFailed | TransmitFailed 
        | Microsoft-Windows-Application Server-Applications| 3801 | 86| ChannelFaulted | ChannelFaulted 
        | Microsoft-Windows-Dhcp-Client| 60020 | 86| DHCP_OPCODE_PERFTRACK_MEDIA_RECONNECT | PerfTrackMediaReconnect 
        | Microsoft-Windows-DHCPv6-Client| 50072 | 86| DHCPV6_OPCODE_NIC_REFERENCE_RELEASE | ReleaseNICReference 
        | Microsoft-Windows-HttpService| 76 | 86| HTTP_OPCODE_SEND_SLICE_CACHE_CONTENT | SendSliceCacheContent 
        | Microsoft-Windows-Application Server-Applications| 3800 | 87| Closing | Closing 
        | Microsoft-Windows-Dhcp-Client| 50069 | 87| DHCP_OPCODE_BROADCASTBIT_CACHED | BroadcastbitCached 
        | Microsoft-Windows-DHCPv6-Client| 51073 | 87| DHCPV6_OPCODE_FIREWALL_PORT_EXEMPTION_TRIGGERED | FirewallPortExemptionTriggered 
        | Microsoft-Windows-HttpService| 77 | 87| HTTP_OPCODE_CACHED_SLICES_MATCH_RANGES | CachedSlicesMatchContent 
        | Microsoft-Windows-Application Server-Applications| 3804 | 88| CreatingForEndpoint | CreatingForEndpoint 
        | Microsoft-Windows-Dhcp-Client| 50070 | 88| DHCP_OPCODE_NETWORK_HINT_NOT_RECIEVED | NetworkHintNotReceived 
        | Microsoft-Windows-DHCPv6-Client| 51074 | 88| DHCPV6_OPCODE_FIREWALL_PORT_CLOSE_TRIGGERED | FirewallPortCloseTriggered 
        | Microsoft-Windows-HttpService| 78 | 88| HTTP_OPCODE_MERGE_SLICES_TO_CACHE | MergeSlicesToCache 
        | Microsoft-Windows-Application Server-Applications| 3802 | 89| CompletingOneWay | CompletingOneWay 
        | Microsoft-Windows-Dhcp-Client| 50071 | 89| DHCP_OPCODE_NETWORK_HINT_MATCH_NOT_FOUND | NetworkHintMatchNotFound 
        | Microsoft-Windows-DHCPv6-Client| 51075 | 89| DHCPV6_OPCODE_CS_ENTRY_NOTIFICATION | NotifyCSEntry 
        | Microsoft-Windows-HttpService| 79 | 89| HTTP_OPCODE_FLAT_CACHE_RANGE_SEND | FlatCacheRangeSend 
        | Microsoft-Windows-Application Server-Applications| 3807 | 90| CompletingTwoWay | CompletingTwoWay 
        | Microsoft-Windows-Dhcp-Client| 50072 | 90| DHCP_OPCODE_DIAGNOSTICS_INITIATED | DiagnosticsInitiated 
        | Microsoft-Windows-DHCPv6-Client| 51076 | 90| DHCPV6_OPCODE_CS_EXIT_NOTIFICATION | NotifyCSExit 
        | Microsoft-Windows-HttpService| 80 | 90| HTTP_OPCODE_CHANNEL_BIND_ASC_PARAMETERS | ChannelBindAscParams 
        | Microsoft-Windows-Dhcp-Client| 50073 | 91| DHCP_OPCODE_DIAGNOSTICS_FAILED | DiagnosticsFailed 
        | Microsoft-Windows-DHCPv6-Client| 51068 | 91| DHCPV6_OPCODE_ABANDON_SOLICIT_IN_CS_STATIC | AbandonSolicitInCSSinceStatic 
        | Microsoft-Windows-HttpService| 81 | 91| HTTP_OPCODE_SERVICE_BIND_CHECK_COMPLETE | ServiceBindCheckComplete 
        | Microsoft-Windows-Application Server-Applications| 3819 | 91| MovedToBackup | MovedToBackup 
        | Microsoft-Windows-Dhcp-Client| 50074 | 92| DHCP_OPCODE_FIREWALL_PORT_EXEMPTED | FirewallPortExempted 
        | Microsoft-Windows-DHCPv6-Client| 51078 | 92| DHCPV6_OPCODE_ENABLE_DHCPV6 | EnableDhcpV6 
        | Microsoft-Windows-HttpService| 82 | 92| HTTP_OPCODE_CHANNEL_BIND_CONFIG_CAPTURE | ChannelBindConfigCapture 
        | Microsoft-Windows-Application Server-Applications| 3803 | 92| ProcessingFailure | ProcessingFailure 
        | Microsoft-Windows-Dhcp-Client| 50075 | 93| DHCP_OPCODE_FIREWALL_PORT_CLOSED | FirewallPortClosed 
        | Microsoft-Windows-DHCPv6-Client| 51079 | 93| DHCPV6_OPCODE_DISABLE_DHCPV6 | DisableDhcpV6 
        | Microsoft-Windows-HttpService| 83 | 93| HTTP_OPCODE_CHANNEL_BIND_RESPONSE_CONFIG | ChannelBindPerResponseConfig 
        | Microsoft-Windows-Application Server-Applications| 3815 | 93| ProcessingMessage | ProcessingMessage 
        | Microsoft-Windows-Dhcp-Client| 60021 | 94| DHCP_OPCODE_PERFTRACK_DISCOVER_NETWORK_LATENCY | PerfTrackDiscoverNetworkLatency 
        | Microsoft-Windows-DHCPv6-Client| 51080 | 94| DHCPV6_OPCODE_NO_PROC_SINCE_DHCPV6_DISABLED | NoProcessingSinceDhcpV6Disabled 
        | Microsoft-Windows-HttpService| 84 | 94| HTTP_OPCODE_POLICY_FLOW | UsePolicyBasedQoSFlow 
        | Microsoft-Windows-Application Server-Applications| 3809 | 94| RoutedToEndpoints | RoutedToEndpoints 
        | Microsoft-Windows-Dhcp-Client| 60023 | 95| DHCP_OPCODE_PERFTRACK_REQUEST_NETWORK_LATENCY | PerfTrackRequestNetworkLatency 
        | Microsoft-Windows-DHCPv6-Client| 51081 | 95| DHCPV6_OPCODE_ABANDON_SOLICIT_IN_CS_V6_STATIC | AbandonSolicitInCSSinceV6Static 
        | Microsoft-Windows-HttpService| 85 | 95| HTTP_OPCODE_THREADPOOL_EXTENSION | ThreadPoolExtension 
        | Microsoft-Windows-Application Server-Applications| 3823 | 95| SendingFaultResponse | SendingFaultResponse 
        | Microsoft-Windows-Dhcp-Client| 60022 | 96| DHCP_OPCODE_PERFTRACK_DISCOVER_TIMEOUT | PerfTrackDiscoverTimeout 
        | Microsoft-Windows-DHCPv6-Client| 51082 | 96| DHCPV6_OPCODE_ABANDON_SOLICIT_IN_CS_V6_STATELESS | AbandonSolicitInCSSinceV6Stateless 
        | Microsoft-Windows-HttpService| 86 | 96| HTTP_OPCODE_THREAD_READY | ThreadReady 
        | Microsoft-Windows-Application Server-Applications| 3822 | 96| SendingResponse | SendingResponse 
        | Microsoft-Windows-Dhcp-Client| 60024 | 97| DHCP_OPCODE_PERFTRACK_REQUEST_NO_RESPONSE | PerfTrackRequestNoResponse 
        | Microsoft-Windows-DHCPv6-Client| 51083 | 97| DHCPV6_OPCODE_ABANDON_SOLICIT_NON_MULTICAST | AbandonSolicitSinceNonMulticast 
        | Microsoft-Windows-HttpService| 87 | 97| HTTP_OPCODE_THREADPOOL_TRIM | ThreadPoolTrim 
        | Microsoft-Windows-Application Server-Applications| 3832 | 97| TransmitSucceeded | TransmitSucceeded 
        | Microsoft-Windows-Dhcp-Client| 60025 | 98| DHCP_OPCODE_PERFTRACK_FALLBACK_AFTER_DISCOVER | PerfTrackFallbackAfterDiscover 
        | Microsoft-Windows-DHCPv6-Client| 1009 | 98| DHCPV6_OPCODE_DUID_VALIDATION_FAILED | DHCPv6DUIDValidationFailed 
        | Microsoft-Windows-HttpService| 88 | 98| HTTP_OPCODE_THREAD_GONE | ThreadGone 
        | Microsoft-Windows-Application Server-Applications| 3816 | 98| TransmittingMessage | TransmittingMessage 
        | Microsoft-Windows-Application Server-Applications| 3825 | 99| Abandoning | Abandoning 
        | Microsoft-Windows-Dhcp-Client| 50076 | 99| DHCP_OPCODE_MATCHED_ADDRESS_NOT_PLUMBED | MatchedAddressNotPlumbed 
        | Microsoft-Windows-DHCPv6-Client| 1010 | 99| DHCPV6_OPCODE_NETWORK_HINT_MATCH_FOUND | DHCPv6NetworkHintMatch 
        | Microsoft-Windows-HttpService| 89 | 99| HTTP_OPCODE_SNI_PARSED | SniParsed 
        | Microsoft-Windows-Application Server-Applications| 3824 | 100| Completing | Completing 
        | Microsoft-Windows-Dhcp-Client| 50077 | 100| DHCP_OPCODE_AGGRESSIVE_RETRY_ON | AggressiveRetryOn 
        | Microsoft-Windows-DHCPv6-Client| 1011 | 100| DHCPV6_OPCODE_NETWORK_HINT_STATEFULL_CONFIG | DHCPv6NetworkHintStatefullConfig 
        | Microsoft-Windows-StorPort| 204 | 100| Dispatch | Dispatching of request. 
        | Microsoft-Windows-CodeIntegrity| 3010 | 100| Failed |  
        | Microsoft-Windows-HttpService| 90 | 100| HTTP_OPCODE_OPAQUE | InitiateOpaqueMode 
        | Microsoft-Windows-OverlayFilter| 24835 | 100| IntegrityFileOpen |  
        | Microsoft-Windows-VerifyHardwareSecurity| 3002 | 100| securebootEnabledFailedCheck |  
        | Microsoft-Windows-BrokerInfrastructure| 4 | 100| TaskThrottledCpu |  
        | Microsoft-Windows-Application Server-Applications| 3817 | 101| CommittingTransaction | CommittingTransaction 
        | Microsoft-Windows-Disk| 211 | 101| Completion | Completion of request. 
        | Microsoft-Windows-Dhcp-Client| 50097 | 101| DHCP_OPCODE_ABANDON_V4_DISCOVER_IN_CS_STATIC | AbandonDiscovInCSSinceStatic 
        | Microsoft-Windows-DHCPv6-Client| 1012 | 101| DHCPV6_OPCODE_NETWORK_HINT_STATELESS_CONFIG | DHCPv6NetworkHintStatelessConfig 
        | Microsoft-Windows-HttpService| 91 | 101| HTTP_OPCODE_SSL_AUTO_ENDPOINT_CREATED | EndpointAutoGenerated 
        | Microsoft-Windows-OverlayFilter| 24833 | 101| IntegrityBlockVerificationFailure |  
        | Microsoft-Windows-VerifyHardwareSecurity| 3003 | 101| securebootEnabledFailedToCheck |  
        | Microsoft-Windows-TaskScheduler| 101 | 101| StartFailed | Launch Failure 
        | Microsoft-Windows-BrokerInfrastructure| 5 | 101| TaskThrottledNet |  
        | Microsoft-Windows-CodeIntegrity| 3025 | 101| UnsignedDriverLoaded |  
        | Microsoft-Windows-VerifyHardwareSecurity| 3004 | 102| certsFailedCheck |  
        | Microsoft-Windows-Application Server-Applications| 3820 | 102| Creating | Creating 
        | Microsoft-Windows-Dhcp-Client| 50098 | 102| DHCP_OPCODE_DONT_START_DISCOVER_IN_CS | DontStartDiscovInCSSinceV6Plumbed 
        | Microsoft-Windows-DHCPv6-Client| 1013 | 102| DHCPV6_OPCODE_NETWORK_HINT_CONFIG_EXPIRED | DHCPv6NetworkHintConfigExpired 
        | Microsoft-Windows-TaskScheduler| 202 | 102| ExecutionFailed | Run Failure 
        | Microsoft-Windows-HttpService| 92 | 102| HTTP_OPCODE_SSL_AUTO_ENDPOINT_DELETED | AutoGeneratedEndpointDeleted 
        | Microsoft-Windows-OverlayFilter| 24834 | 102| IntegrityInvalidBlock |  
        | Microsoft-Windows-CodeIntegrity| 3002 | 102| PageHashNotFound |  
        | Microsoft-Windows-BrokerInfrastructure| 6 | 102| TaskForcedCompletion |  
        | Microsoft-Windows-VerifyHardwareSecurity| 3005 | 103| certsFailedToCheck |  
        | Microsoft-Windows-OverlayFilter| 24838 | 103| CompleteHashFile |  
        | Microsoft-Windows-Dhcp-Client| 50099 | 103| DHCP_OPCODE_START_DISCOVER_IN_CS_NO_V6 | StartDiscovInCSSinceV6Unplumbed 
        | Microsoft-Windows-DHCPv6-Client| 51084 | 103| DHCPV6_OPCODE_NOTE_FLAG_VALUES | NoteFlagValues 
        | Microsoft-Windows-TaskScheduler| 111 | 103| ExecutionTerminated | Termination 
        | Microsoft-Windows-HttpService| 93 | 103| HTTP_OPCODE_SSL_ENDPOINT_CONFIG_FOUND | SslEndpointConfigFound 
        | Microsoft-Windows-CodeIntegrity| 3003 | 103| PageHashNotFound_DbgAttached |  
        | Microsoft-Windows-BrokerInfrastructure| 13 | 103| TaskLatched |  
        | Microsoft-Windows-Application Server-Applications| 3826 | 103| UsingExisting | UsingExisting 
        | Microsoft-Windows-Application Server-Applications| 1037 | 104| Complete | Complete 
        | Microsoft-Windows-OverlayFilter| 24839 | 104| DeleteHashFile |  
        | Microsoft-Windows-Dhcp-Client| 50100 | 104| DHCP_OPCODE_START_DISCOVER_IN_CS_COMPULSORY | StartDiscovInCSAtCompulsoryTime 
        | Microsoft-Windows-DHCPv6-Client| 51057 | 104| DHCPV6_OPCODE_SERVICE_STOP_COMPLETED | ServiceStopWithRefCount 
        | Microsoft-Windows-TaskScheduler| 998 | 104| Failed | Failure 
        | Microsoft-Windows-CodeIntegrity| 3004 | 104| FileHashNotFound |  
        | Microsoft-Windows-HttpService| 94 | 104| HTTP_OPCODE_SSL_ENDPOINT_CONFIG_REJECTED | SslEndpointConfigRejected 
        | Microsoft-Windows-Disk| 209 | 104| Retry | Retry handling. 
        | Microsoft-Windows-VerifyHardwareSecurity| 3006 | 104| securebootPolicyFailedCheck |  
        | Microsoft-Windows-BrokerInfrastructure| 14 | 104| TaskUnlatched |  
        | Microsoft-Windows-Application Server-Applications| 1036 | 105| CompletionRequested | CompletionRequested 
        | Microsoft-Windows-Dhcp-Client| 50096 | 105| DHCP_OPCODE_ABANDON_V4_DISCOVER_IN_CS_STATELESS | AbandonDiscovInCSSinceStateless 
        | Microsoft-Windows-CodeIntegrity| 3005 | 105| FileHashNotFound_DbgAttached |  
        | Microsoft-Windows-OverlayFilter| 24840 | 105| ResumeHashFile |  
        | Microsoft-Windows-VerifyHardwareSecurity| 3007 | 105| securebootPolicyFailedToCheck |  
        | Microsoft-Windows-BrokerInfrastructure| 15 | 105| TaskDropped |  
        | Microsoft-Windows-Dhcp-Client| 50083 | 106| DHCP_OPCODE_NIC_REFERENCE_ACQUIRE | AcquireNICReference 
        | Microsoft-Windows-OverlayFilter| 24841 | 106| PauseHashFile |  
        | Microsoft-Windows-StorPort| 220 | 106| Queue | Event Queue related operation. 
        | Microsoft-Windows-ATAPort| 220 | 106| Queue | Queue-related operation. 
        | Microsoft-Windows-VerifyHardwareSecurity| 3001 | 106| reportCheck |  
        | Microsoft-Windows-CodeIntegrity| 3021 | 106| RevokedDriverLoaded |  
        | Microsoft-Windows-Application Server-Applications| 1035 | 106| Set | Set 
        | Microsoft-Windows-BrokerInfrastructure| 16 | 106| TaskBufferedPolicy |  
        | Microsoft-Windows-Dhcp-Client| 50084 | 107| DHCP_OPCODE_NIC_REFERENCE_RELEASE | ReleaseNICReference 
        | Microsoft-Windows-OverlayFilter| 24843 | 107| GenerateHashFileError |  
        | Microsoft-Windows-VerifyHardwareSecurity| 3008 | 107| HostLockdownCheck |  
        | Microsoft-Windows-CodeIntegrity| 3022 | 107| RevokedDriverLoadedInDebugger |  
        | Microsoft-Windows-Application Server-Applications| 1021 | 107| ScheduleBookmark | ScheduleBookmark 
        | Microsoft-Windows-BrokerInfrastructure| 17 | 107| TaskBufferedPackageState |  
        | Microsoft-Windows-OverlayFilter| 24844 | 108| DeleteHashFileError |  
        | Microsoft-Windows-Dhcp-Client| 50085 | 108| DHCP_OPCODE_DAD_REGISTERED | RegisterConflictDetectionNotification 
        | Microsoft-Windows-CodeIntegrity| 3023 | 108| RevokedDriverNotLoaded |  
        | Microsoft-Windows-Application Server-Applications| 1017 | 108| ScheduleCancelActivity | ScheduleCancelActivity 
        | Microsoft-Windows-BrokerInfrastructure| 18 | 108| TaskUnbuffered |  
        | Microsoft-Windows-Dhcp-Client| 50086 | 109| DHCP_OPCODE_DAD_COMPLETED | ConflictDetectionComplete 
        | Microsoft-Windows-OverlayFilter| 24845 | 109| FileReadError |  
        | Microsoft-Windows-Application Server-Applications| 1014 | 109| ScheduleCompletion | ScheduleCompletion 
        | Microsoft-Windows-BrokerInfrastructure| 19 | 109| TaskCanceled |  
        | Microsoft-Windows-CodeIntegrity| 3024 | 109| UpdateCatalogCacheFailed |  
        | Microsoft-Windows-Dhcp-Client| 50087 | 110| DHCP_OPCODE_DAD_TENTATIVE | ConflictDetectionTentative 
        | Microsoft-Windows-OverlayFilter| 24846 | 110| FileWriteError |  
        | Microsoft-Windows-Application Server-Applications| 1011 | 110| ScheduleExecuteActivity | ScheduleExecuteActivity 
        | Microsoft-Windows-BrokerInfrastructure| 20 | 110| TaskUnregistered |  
        | Microsoft-Windows-BrokerInfrastructure| 200 | 111| Acquire |  
        | Microsoft-Windows-OverlayFilter| 24842 | 111| ActionError |  
        | Microsoft-Windows-Dhcp-Client| 50088 | 111| DHCP_OPCODE_PARAM_CHANGE_REGISTER | ParamChangeRegister 
        | Microsoft-Windows-CodeIntegrity| 3081 | 111| PolicyFailure |  
        | Microsoft-Windows-Application Server-Applications| 1029 | 111| ScheduleFault | ScheduleFault 
        | Microsoft-Windows-OverlayFilter| 24849 | 112| ActionGenerateHashes |  
        | Microsoft-Windows-Dhcp-Client| 50089 | 112| DHCP_OPCODE_PARAM_CHANGE_UNREGISTER | ParamChangeUnregister 
        | Microsoft-Windows-BrokerInfrastructure| 201 | 112| Release |  
        | Microsoft-Windows-Application Server-Applications| 1032 | 112| ScheduleRuntime | ScheduleRuntime 
        | Microsoft-Windows-CodeIntegrity| 3037 | 112| UnsignedImageLoaded |  
        | Microsoft-Windows-OverlayFilter| 24850 | 113| ActionDeleteHashes |  
        | Microsoft-Windows-Dhcp-Client| 50090 | 113| DHCP_OPCODE_PARAM_CHANGE_NOTIFICATION | ParamChangeNotification 
        | Microsoft-Windows-CodeIntegrity| 3032 | 113| RevokedImageLoaded |  
        | Microsoft-Windows-Application Server-Applications| 1026 | 113| ScheduleTransactionContext | ScheduleTransactionContext 
        | Microsoft-Windows-BrokerInfrastructure| 21 | 113| TaskActivationFailed |  
        | Microsoft-Windows-Application Server-Applications| 3385 | 114| Accept | Accept 
        | Microsoft-Windows-Dhcp-Client| 50091 | 114| DHCP_OPCODE_PARAM_REQUEST | ParamRequest 
        | Microsoft-Windows-BrokerInfrastructure| 25 | 114| PackageWatchdog |  
        | Microsoft-Windows-CodeIntegrity| 3035 | 114| RevokedImageLoadedInDebugger |  
        | Microsoft-Windows-Dhcp-Client| 50092 | 115| DHCP_OPCODE_PARAM_REQUEST_UNBLOCKED | ParamRequestUnblocked 
        | Microsoft-Windows-Application Server-Applications| 3384 | 115| Initiate | Initiate 
        | Microsoft-Windows-CodeIntegrity| 3036 | 115| RevokedImageNotLoaded |  
        | Microsoft-Windows-BrokerInfrastructure| 26 | 115| WatchdogIteration |  
        | Microsoft-Windows-Dhcp-Client| 50093 | 116| DHCP_OPCODE_PARAM_REQUEST_COMPLETE | ParamRequestComplete 
        | Microsoft-Windows-CodeIntegrity| 3065 | 116| SdlRequirement |  
        | Microsoft-Windows-BrokerInfrastructure| 27 | 116| TaskWatchdog |  
        | Microsoft-Windows-Dhcp-Client| 50094 | 117| DHCP_OPCODE_FIREWALL_PORT_EXEMPTION_TRIGGERED | FirewallPortExemptionTriggered 
        | Microsoft-Windows-BrokerInfrastructure| 28 | 117| SessionStateTransition |  
        | Microsoft-Windows-Application Server-Applications| 1022 | 117| StartBookmark | StartBookmark 
        | Microsoft-Windows-Dhcp-Client| 50095 | 118| DHCP_OPCODE_FIREWALL_PORT_CLOSE_TRIGGERED | FirewallPortCloseTriggered 
        | Microsoft-Windows-CodeIntegrity| 3080 | 118| SiPolicyFailureIgnored |  
        | Microsoft-Windows-Application Server-Applications| 1018 | 118| StartCancelActivity | StartCancelActivity 
        | Microsoft-Windows-BrokerInfrastructure| 300 | 118| WorkItemBlockingDisconnectedStandby |  
        | Microsoft-Windows-Dhcp-Client| 50101 | 119| DHCP_OPCODE_CS_ENTRY_NOTIFICATION | NotifyCSEntry 
        | Microsoft-Windows-CodeIntegrity| 3069 | 119| LoadWeakCryptoRegistryValueFailed |  
        | Microsoft-Windows-Application Server-Applications| 1015 | 119| StartCompletion | StartCompletion 
        | Microsoft-Windows-Dhcp-Client| 50102 | 120| DHCP_OPCODE_CS_EXIT_NOTIFICATION | NotifyCSExit 
        | Microsoft-Windows-CodeIntegrity| 3070 | 120| LoadWeakCryptoRegistryPolicyFailed |  
        | Microsoft-Windows-Application Server-Applications| 1012 | 120| StartExecuteActivity | StartExecuteActivity 
        | Microsoft-Windows-Dhcp-Client| 50081 | 121| DHCP_OPCODE_ABANDON_V4_DISCOVER_IN_CS_DHCP | AbandonDiscovInCSSinceDhcp 
        | Microsoft-Windows-CodeIntegrity| 3071 | 121| LoadWeakCryptoPoliciesFailed |  
        | Microsoft-Windows-Application Server-Applications| 1030 | 121| StartFault | StartFault 
        | Microsoft-Windows-Dhcp-Client| 60026 | 122| DHCP_OPCODE_PROCESS_DHCP_REQUEST_FOREVER | ProcessDHCPRequestForever Entered 
        | Microsoft-Windows-CodeIntegrity| 3072 | 122| HvciUnalignedSection |  
        | Microsoft-Windows-Application Server-Applications| 1033 | 122| StartRuntime | StartRuntime 
        | Microsoft-Windows-Dhcp-Client| 60027 | 123| DHCP_OPCODE_PROCESS_DHCP_REQUEST_FOREVER_WAIT_TIMEOUT | ProcessDHCPRequestForever Timed out 
        | Microsoft-Windows-CodeIntegrity| 3073 | 123| HvciWritableExecutableSection |  
        | Microsoft-Windows-Application Server-Applications| 1027 | 123| StartTransactionContext | StartTransactionContext 
        | Microsoft-Windows-Dhcp-Client| 60032 | 124| DHCP_OPCODE_PROCESS_DHCP_REQUEST_FOREVER_FAILED | ProcessDHCPRequestForever Failed 
        | Microsoft-Windows-CodeIntegrity| 3074 | 124| HvciPageVerificationFailure |  
        | Microsoft-Windows-Application Server-Applications| 3508 | 124| NotFound | NotFound 
        | Microsoft-Windows-Dhcp-Client| 60029 | 125| DHCP_OPCODE_DELETE_RENEW_TIMER_FAILED | DeleteRenewTimer Failed 
        | Microsoft-Windows-Application Server-Applications| 39456 | 125| Dropped | Dropped 
        | Microsoft-Windows-CodeIntegrity| 3075 | 125| PolicyPerformance |  
        | Microsoft-Windows-Dhcp-Client| 60031 | 126| DHCP_OPCODE_CREATE_RENEW_TIMER_FAILED | CreateRenewTimer Failed 
        | Microsoft-Windows-Application Server-Applications| 39457 | 126| Raised | Raised 
        | Microsoft-Windows-CodeIntegrity| 3082 | 126| WhqlFailure |  
        | Microsoft-Windows-Dhcp-Client| 60030 | 127| DHCP_OPCODE_RESET_RENEWAL_SIGNAL_HANDLE_FAILED | ResetRenewalSignalHandle Failed 
        | Microsoft-Windows-Application Server-Applications| 39458 | 127| Truncated | Truncated 
        | Microsoft-Windows-CodeIntegrity| 3085 | 127| WhqlSettings |  
        | Microsoft-Windows-Application Server-Applications| 710 | 128| BeforeAuthentication | BeforeAuthentication 
        | Microsoft-Windows-Dhcp-Client| 60028 | 128| DHCP_OPCODE_CREATE_RENEWAL_SIGNAL_HANDLE_FAILED | CreateRenewalSignalHandle Failed 
        | Microsoft-Windows-CodeIntegrity| 3087 | 128| HvciAuditFailure |  
        | Microsoft-Windows-Dhcp-Client| 50105 | 129| DHCP_OPCODE_SERVICE_SHUTDOWN | ServiceShutdown 
        | Microsoft-Windows-Application Server-Applications| 2577 | 129| DuringCancelation | DuringCancelation 
        | Microsoft-Windows-CodeIntegrity| 3090 | 129| SmartlockerVerbose |  
        | Microsoft-Windows-Application Server-Applications| 2578 | 130| FromCatchOrFinally | FromCatchOrFinally 
        | Microsoft-Windows-CodeIntegrity| 3089 | 130| SignatureInformation |  
        | Microsoft-Windows-Application Server-Applications| 2576 | 131| FromTry | FromTry 
        | Microsoft-Windows-CodeIntegrity| 3098 | 131| RefreshPolicyOp |  
        | Microsoft-Windows-Application Server-Applications| 4026 | 132| Connected | Connected 
        | Microsoft-Windows-Application Server-Applications| 4027 | 133| Disconnect | Disconnect 
        | Microsoft-Windows-Application Server-Applications| 1001 | 134| Completed | Completed 
        | Microsoft-Windows-Application Server-Applications| 1005 | 135| Idled | Idled 
        | Microsoft-Windows-Application Server-Applications| 1004 | 136| InstanceAborted | InstanceAborted 
        | Microsoft-Windows-Application Server-Applications| 1003 | 137| InstanceCanceled | InstanceCanceled 
        | Microsoft-Windows-Application Server-Applications| 1041 | 138| PersistableIdle | PersistableIdle 
        | Microsoft-Windows-Application Server-Applications| 1007 | 139| Persisted | Persisted 
        | Microsoft-Windows-Application Server-Applications| 1002 | 140| Terminated | Terminated 
        | Microsoft-Windows-Application Server-Applications| 1006 | 141| UnhandledException | UnhandledException 
        | Microsoft-Windows-Application Server-Applications| 1008 | 142| Unloaded | Unloaded 
        | Microsoft-Windows-Application Server-Applications| 102 | 144| AbortedRecord | AbortedRecord 
        | Microsoft-Windows-Application Server-Applications| 115 | 145| AbortedWithId | AbortedWithId 
        | Microsoft-Windows-Application Server-Applications| 112 | 146| SuspendedRecord | SuspendedRecord 
        | Microsoft-Windows-Application Server-Applications| 116 | 147| SuspendedWithId | SuspendedWithId 
        | Microsoft-Windows-Application Server-Applications| 113 | 148| TerminatedRecord | TerminatedRecord 
        | Microsoft-Windows-Application Server-Applications| 117 | 149| TerminatedWithId | TerminatedWithId 
        | Microsoft-Windows-Application Server-Applications| 101 | 150| UnhandledExceptionRecord | UnhandledExceptionRecord 
        | Microsoft-Windows-Application Server-Applications| 118 | 151| UnhandledExceptionWithId | UnhandledExceptionWithId 
        | Microsoft-Windows-Application Server-Applications| 119 | 152| UpdatedRecord | UpdatedRecord 
        | Microsoft-Windows-WLAN-AutoConfig| 8000 | 189| WLAN_OPCODE_ACM_CONNECTION_START | Start 
        | Microsoft-Windows-WLAN-AutoConfig| 8001 | 190| WLAN_OPCODE_ACM_CONNECTION_SUCCEED | Success 
        | Microsoft-Windows-WLAN-AutoConfig| 8002 | 191| WLAN_OPCODE_ACM_CONNECTION_FAIL | Failure 
        | Microsoft-Windows-WLAN-AutoConfig| 8003 | 192| WLAN_OPCODE_ACM_DISCONNECTED | Disconnect 
        | Microsoft-Windows-WLAN-AutoConfig| 11000 | 193| WLAN_OPCODE_MSM_ASSOCIATION_START | Start 
        | Microsoft-Windows-WLAN-AutoConfig| 11001 | 194| WLAN_OPCODE_MSM_ASSOCIATION_SUCCESS | Success 
        | Microsoft-Windows-WLAN-AutoConfig| 11002 | 195| WLAN_OPCODE_MSM_ASSOCIATION_FAILURE | Failure 
        | Microsoft-Windows-WLAN-AutoConfig| 11003 | 196| WLAN_OPCODE_MSM_SECURITY_START | Start 
        | Microsoft-Windows-WLAN-AutoConfig| 11004 | 197| WLAN_OPCODE_MSM_SECURITY_STOP | Stop 
        | Microsoft-Windows-WLAN-AutoConfig| 11005 | 198| WLAN_OPCODE_MSM_SECURITY_SUCCESS | Success 
        | Microsoft-Windows-WLAN-AutoConfig| 11006 | 199| WLAN_OPCODE_MSM_SECURITY_FAILURE | Failure 
        | Microsoft-Windows-ATAPort| 0 | 200| ATAPORT_OPCODE_LPM_POWERSTATE_PARTIAL |  
        | Microsoft-Windows-VHDMP| 1001 | 200| VHD_START_IO | Starting an IO. 
        | Microsoft-Windows-WLAN-AutoConfig| 11010 | 200| WLAN_OPCODE_MSM_SECURITY_START_SP1 | Start 
        | Microsoft-Windows-ATAPort| 1 | 201| ATAPORT_OPCODE_LPM_POWERSTATE_SLUMBER |  
        | Microsoft-Windows-Winlogon| 807 | 201| NotificationPended |  
        | Microsoft-Windows-Diagnostics-Performance| 2001 | 201| StepUp |  
        | Microsoft-Windows-VHDMP| 1002 | 201| VHD_COMPLETE_IO | Completing an IO. 
        | Microsoft-Windows-WLAN-AutoConfig| 11008 | 201| WLAN_OPCODE_IHV_SECURITY_SUCCESS | Success 
        | Microsoft-Windows-Winlogon| 808 | 202| NotificationFailed |  
        | Microsoft-Windows-Diagnostics-Performance| 2002 | 202| StepDown |  
        | Microsoft-Windows-WLAN-AutoConfig| 11009 | 202| WLAN_OPCODE_IHV_SECURITY_FAILURE | Failure 
        | Microsoft-Windows-Diagnostics-Performance| 2003 | 203| GradualUp |  
        | Microsoft-Windows-WLAN-AutoConfig| 12011 | 203| WLAN_OPCODE_ONEX_SECURITY_START | Start 
        | Microsoft-Windows-Diagnostics-Performance| 2004 | 204| GradualDown |  
        | Microsoft-Windows-WLAN-AutoConfig| 12012 | 204| WLAN_OPCODE_ONEX_SECURITY_SUCCESS | Success 
        | Microsoft-Windows-WLAN-AutoConfig| 12013 | 205| WLAN_OPCODE_ONEX_SECURITY_FAILURE | Failure 
        | Microsoft-Windows-WLAN-AutoConfig| 12014 | 206| WLAN_OPCODE_ONEX_SECURITY_RESTART | Restart 
        | Microsoft-Windows-Diagnostics-Performance| 8009 | 210| Failed |  
        | Microsoft-Windows-WLAN-AutoConfig| 14058 | 210| ut:ActivityContext |  
        | Microsoft-Windows-Application Server-Applications| 1449 | 240| win:Receive | Receive 
      
      

