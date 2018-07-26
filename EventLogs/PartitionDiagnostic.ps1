#Requires -RunAsAdministrator

#References: 
#
# Critical - Value: 1. Indicates logs for a critical alert.
# Error	- Value: 2. Indicates logs for an error.
# Information - Value: 4. Indicates logs for an informational message.
# Undefined	- Value: 0. Indicates logs at all levels.
# Verbose - Value: 5. Indicates logs at all levels.
# Warning - Value: 3. Indicates logs for a warning.
#
# https://df-stream.com/2018/05/partition-diagnostic-event-log-and-usb-device-tracking-p1/
# https://df-stream.com/2018/07/partition-diagnostic-event-log-and-usb-device-tracking-p2/
#

# Show an Open File Dialog and return the file selected by the user
Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.SelectedPath = "C:\Windows\System32\WinEvt\logs\"
	$foldername.Description = "Select the location of Microsoft-Windows-Partition%4Diagnostic.evtx log (\System32\WinEvt\logs\)"
	$foldername.ShowNewFolderButton = $false
	
    if($foldername.ShowDialog() -eq "OK")
		{
        $folder += $foldername.SelectedPath
		 }
	        else  
        {
            Write-Host "(PartitionDiagnostic.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}

$F = Get-Folder +"\"
$Folder = $F +"\"
$DesktopPath = ($Env:WinDir+"\System32\winevt\Logs\")
$g=0

$sw4 = [Diagnostics.Stopwatch]::StartNew()
Try {  
	$log4 = (Get-WinEvent -FilterHashtable @{path = $Folder + "Microsoft-Windows-Partition%4Diagnostic.evtx"; ProviderName= "Microsoft-Windows-Partition" ; ID=1006} -ErrorAction Stop)
    Write-Host "(PartitionDiagnostic.ps1):" -f Yellow -nonewline; write-host " Selected Event Log: ($PFile)" -f White
    }
	catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog4 = $log4.toXml()
$Procount = $xmllog4.Count
Write-Host "Microsoft-Windows-Partition/Diagnostic entries found: $Procount" -f White

$Events4 = foreach ($pd in $xmllog4) {$g++
			
			#Progress Bar
			write-progress -id 1 -activity "Collecting Security entries with EventID=1006 - $g of $($xmllog4.Count)"  -PercentComplete (($g / $xmllog4.Count) * 100)		
			
			# Format output fields
            $Pversion = if ($pd.Event.System.Version -eq 0){"Win10"}
                        else {$pd.Event.System.Version}
            
          
            $PLevel = if ($pd.Event.System.Level -eq 0 ){"Undefined"}
                        elseif($pd.Event.System.Level -eq 1){"Critical"}
                        elseif($pd.Event.System.Level -eq 2){"Error"}
                        elseif($pd.Event.System.Level -eq 3){"Warning"}
                        elseif($pd.Event.System.Level -eq 4){"Information"}
                        elseif($pd.Event.System.Level -eq 5){"Verbose"}


            $PDate = (Get-Date ($pd.Event.System.TimeCreated.SystemTime) -f o)
			
			 [PSCustomObject]@{
 			 'EventID' =           $pd.Event.System.EventID
             'Time Created' =      $PDate  
			 'RecordID' =          $pd.Event.System.EventRecordID
             'Version' =           $Pversion
             'Level' =             $PLevel
             'Task' =              $pd.Event.System.Task
             'Opcode' =            $pd.Event.System.Opcode
			 'PID' =               ([Convert]::ToInt64(($pd.Event.System.Execution.ProcessID),16))
			 'ThreadID' =          $pd.Event.System.Execution.ThreadID
             'Computer' =          $pd.Event.System.Computer 
             'SID' =               $pd.Event.System.Security.UserID 
             'Version_' =          $pd.Event.EventData.Data[0].'#text'
             'DiskNumber' =        $pd.Event.EventData.Data[1].'#text'
             'Flags' =             $pd.Event.EventData.Data[2].'#text'
             'Characteristics' =   $pd.Event.EventData.Data[3].'#text'
             'IsSystemCritical' =  $pd.Event.EventData.Data[4].'#text'
             'PagingCount' =       $pd.Event.EventData.Data[5].'#text'
             'HibernationCount' =  $pd.Event.EventData.Data[6].'#text' 
             'DumpCount' =         $pd.Event.EventData.Data[0].'#text'
             'BytesPerSector' =    $pd.Event.EventData.Data[7].'#text' 
             'Capacity' =          $pd.Event.EventData.Data[8].'#text'
             'BusType' =           $pd.Event.EventData.Data[9].'#text'
             'Manufacturer' =      $pd.Event.EventData.Data[10].'#text'
             'Model' =             $pd.Event.EventData.Data[11].'#text' 
             'Revision' =          $pd.Event.EventData.Data[12].'#text' 
             'SerialNumber' =      $pd.Event.EventData.Data[13].'#text'
             'Location' =          $pd.Event.EventData.Data[14].'#text'
             'ParentId' =          $pd.Event.EventData.Data[15].'#text' 
             'IoctlSupport' =      $pd.Event.EventData.Data[16].'#text'
             'IdFlags' =           $pd.Event.EventData.Data[17].'#text'
             'DiskId' =            $pd.Event.EventData.Data[18].'#text'
             'AdapterIdv' =        $pd.Event.EventData.Data[19].'#text'
             'RegistryId' =        $pd.Event.EventData.Data[20].'#text'
             'PoolId' =            $pd.Event.EventData.Data[21].'#text' 
             'FirmwareSupportsUpgrade' = $pd.Event.EventData.Data[22].'#text'
             'FirmwareSlotCount' = $pd.Event.EventData.Data[23].'#text'
             'StorageIdCount' =    $pd.Event.EventData.Data[24].'#text'
             'StorageIdCodeSet' =  $pd.Event.EventData.Data[25].'#text'
             'StorageIdType' =     $pd.Event.EventData.Data[26].'#text'
             'StorageIdAssociation' = $pd.Event.EventData.Data[27].'#text'
             'StorageIdBytes' =    $pd.Event.EventData.Data[28].'#text' 
             'StorageId' =         $pd.Event.EventData.Data[29].'#text' 
             'WriteCacheType' =    $pd.Event.EventData.Data[30].'#text'
             'WriteCacheEnabled' = $pd.Event.EventData.Data[31].'#text'
             'WriteCacheChangeable'  = $pd.Event.EventData.Data[32].'#text'
             'WriteThroughSupported' = $pd.Event.EventData.Data[33].'#text'
             'FlushCacheSupported' =   $pd.Event.EventData.Data[34].'#text'
             'IsPowerProtected' = $pd.Event.EventData.Data[35].'#text' 
             'NVCacheEnabled' =   $pd.Event.EventData.Data[36].'#text' 
             'BytesPerLogicalSector' = $pd.Event.EventData.Data[37].'#text'
             'BytesPerPhysicalSector'= $pd.Event.EventData.Data[38].'#text'
             'BytesOffsetForSectorAlignment' = $pd.Event.EventData.Data[39].'#text' 
             'IncursSeekPenalty' = $pd.Event.EventData.Data[40].'#text' 
             'IsTrimSupported' =   $pd.Event.EventData.Data[41].'#text' 
             'IsThinProvisioned' = $pd.Event.EventData.Data[42].'#text' 
             'OptimalUnmapGranularity' =       $pd.Event.EventData.Data[43].'#text' 
             'UnmapAlignment' =   $pd.Event.EventData.Data[44].'#text'
             'NumberOfLogicalCopies' =         $pd.Event.EventData.Data[45].'#text' 
             'NumberOfPhysicalCopies' =        $pd.Event.EventData.Data[46].'#text' 
             'FaultTolerance' =   $pd.Event.EventData.Data[47].'#text'
             'NumberOfColumns' =  $pd.Event.EventData.Data[48].'#text' 
             'InterleaveBytes' =  $pd.Event.EventData.Data[49].'#text' 
             'HybridSupported' =  $pd.Event.EventData.Data[50].'#text' 
             'HybridCacheBytes' = $pd.Event.EventData.Data[51].'#text'
             'AdapterMaximumTransferBytes' =   $pd.Event.EventData.Data[52].'#text' 
             'AdapterMaximumTransferPages' =   $pd.Event.EventData.Data[53].'#text'
             'AdapterAlignmentMask' = $pd.Event.EventData.Data[54].'#text'
             'AdapterSerialNumber' =  $pd.Event.EventData.Data[55].'#text'
             'PortDriver' =       $pd.Event.EventData.Data[56].'#text'
             'UserRemovalPolicy'= $pd.Event.EventData.Data[57].'#text' 
             'PartitionStyle' =   $pd.Event.EventData.Data[58].'#text'
             'PartitionCount' =   $pd.Event.EventData.Data[59].'#text'
             'PartitionTableBytes' = $pd.Event.EventData.Data[60].'#text'
             'PartitionTable' =  $pd.Event.EventData.Data[61].'#text'
             'MbrBytes' =        $pd.Event.EventData.Data[62].'#text'
             'Mbr' =             $pd.Event.EventData.Data[63].'#text'
             'Vbr0Bytes' =       $pd.Event.EventData.Data[64].'#text'
             'Vbr0' =            $pd.Event.EventData.Data[65].'#text'
             'Vbr1Bytes' =       $pd.Event.EventData.Data[66].'#text'
             'Vbr1' =            $pd.Event.EventData.Data[67].'#text'
             'Vbr2Bytes' =       $pd.Event.EventData.Data[68].'#text'
             'Vbr2' =            $pd.Event.EventData.Data[69].'#text'
             'Vbr3Size' =        $pd.Event.EventData.Data[70].'#text'
             'Vbr3' =            $pd.Event.EventData.Data[71].'#text'
             'Channel' =         $pd.Event.System.Channel
             'Correlation' =     $pd.Event.System.Correlation
             'Keywords' =        $pd.Event.System.Keywords
			}

	}

function Result{
$Events4
}

#Format of the txt filename and path:
$filenameFormat = $env:userprofile + "\desktop\PartDiag" + (Get-Date -Format "dd-MM-yyyy_hh-mm") + ".csv"
Write-host "Selected Rows will be saved as: " -f Yellow -nonewline; Write-Host $filenameFormat -f White

$sw4.stop()
$t4=$sw4.Elapsed
Result |Out-GridView -PassThru -Title "$Procount - 'Microsoft-Windows-Partition/Diagnostic' Events (ID 1006) - Processing Time $t4"|Export-Csv -Path $filenameFormat
write-host "Elapsed Time $t4" -f yellow


[gc]::Collect()

