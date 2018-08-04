#Check if SQLite exists
try{write-host "sqlite3.exe version => "-f Yellow -nonewline; sqlite3.exe -version }
catch {
    write-host "It seems that you do not have sqlite3.exe in the system path"
    write-host "Please read below`n" -f Yellow
    write-host "Install SQLite On Windows:`n
        Go to SQLite download page, and download precompiled binaries from Windows section.
        Instructions: http://www.sqlitetutorial.net/download-install-sqlite/
        Create a folder C:\sqlite and unzip above two zipped files in this folder which will give you sqlite3.def, sqlite3.dll and sqlite3.exe files.
        Add C:\sqlite to the system PATH (https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/)" -f White

    exit}

# Show an Open File Dialog 
Function Get-FileName($initialDirectory)
{  
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |Out-Null
		$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
		$OpenFileDialog.Title = 'Select wpndatabase.db database to access'
		$OpenFileDialog.initialDirectory = $initialDirectory
		$OpenFileDialog.Filter = "wpndatabase.db (*.db)|wpndatabase.db"
		$OpenFileDialog.ShowDialog() | Out-Null
		$OpenFileDialog.ShowReadOnly = $true
		$OpenFileDialog.filename
		$OpenFileDialog.ShowHelp = $false
} #end function Get-FileName 

$dBPath =  $env:LOCALAPPDATA+"\Microsoft\Windows\Notifications\"
$File = Get-FileName -initialDirectory $dBPath


# Run SQLite query of the Selected dB
# The Query (between " " below)
# can also be copy/pasted and run on 'DB Browser for SQLite' 

Try{(Get-Item $File).FullName}
Catch{Write-Host "(Notifications.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White; exit}
$elapsedTime = [system.diagnostics.stopwatch]::StartNew()    
$swn = [Diagnostics.Stopwatch]::StartNew()

# SQlite Query
$dbn = $File
$sql = 
"
select
    Notification.Id as 'ID',
    Notification.HandlerId as 'Handler_Id',
    NotificationHandler.PrimaryId as 'Application',
    NotificationHandler.HandlerType as 'HandlerType',
    Notification.Type as 'Type',
    Notification.PayloadType as 'PayloadType',
    Notification.Tag as 'Tag',
    datetime((Notification.ArrivalTime - 116444736000000000)/10000000, 'unixepoch') as 'ArrivalTime',
    case when Notification.ExpiryTime = 0 then 'Expired' else datetime((Notification.ExpiryTime - 116444736000000000)/10000000, 'unixepoch') end as 'ExpiryTime',
    NotificationHandler.CreatedTime as 'Handler_Created',
    NotificationHandler.ModifiedTime as 'Handler_Modified',
    NotificationHandler.WNSId as 'WNSId',
    NotificationHandler.WNFEventName as 'WNFEventName',
    WNSPushChannel.ChannelId as 'Channel_ID',
    WNSPushChannel.Uri as 'Uri',
    datetime((WNSPushChannel.CreatedTime - 116444736000000000)/10000000, 'unixepoch') as 'WNS_CreatedTime',
    datetime((WNSPushChannel.ExpiryTime - 116444736000000000)/10000000, 'unixepoch') as 'WNS_ExpiryTime',
    hex(Notification.ActivityId) as 'ActivityId',
    replace(replace(replace(replace(Notification.Payload, x'0A',''),x'09',''),x'20'||x'20',''),x'0D','') as 'payload'
    from Notification
Join NotificationHandler on NotificationHandler.RecordId = Notification.HandlerId
Left Join WNSPushChannel on WNSPushChannel.HandlerId = NotificationHandler.RecordId
order by ID desc
"

1..1000 | %{write-progress -id 1 -activity "Running SQLite query" -status "$([string]::Format("Time Elapsed: {0:d2}:{1:d2}:{2:d2}", $elapsedTime.Elapsed.hours, $elapsedTime.Elapsed.minutes, $elapsedTime.Elapsed.seconds))" -percentcomplete ($_/100);}

#Run SQLite3.exe with the above query
$dbnresults = @(sqlite3.exe -readonly -separator '**' $dbn $sql |
ConvertFrom-String -Delimiter '\u002A\u002A' -PropertyNames Id, Handler_Id, Application, HandlerType, Type, PayloadType, Tag, ArrivalTime, ExpiryTime, Handler_Created, Handler_Modified,WNSId,WNFEventName,Channel_ID,Uri,WNS_CreatedTime,WNS_ExpiryTime,ActivityId,Payload)

$dbncount=$dbnresults.count
$elapsedTime.stop()
#write-progress -id 1 -activity "Running SQLite query" -status "$dbncount Entries - Query Finished" 
$rn=0


#Create Output adding XML Blob information
$output = foreach ($item in $dbnresults ){$rn++
                    Write-Progress -id 2 -Activity "Creating Output" -Status "$rn of $($dbnresults.count))" -PercentComplete (([double]$rn / $dbnresults.count)*100) 
                    
                    
                    try {$xmlitem = [xml]($item.payload)} catch {}   
                     
                    
                    if ($item.Type -eq 'tile' -and $xmlitem.tile -ne $null){

                        if($xmlitem.tile.visual.version -in (1..10)){$version =  $xmlitem.tile.visual.version} else {$version = ""}

                        if($xmlitem.tile.visual.binding.displayName -ne $null) {$displayName = $xmlitem.tile.visual.binding.displayName} else {$displayName = ""}

                         
                        if($xmlitem.tile.visual.binding[0].text.'#text' -ne $null)  {$text1 = $xmlitem.tile.visual.binding[0].text.'#text' } 
                            elseif($xmlitem.tile.visual.binding[0].text.'#cdata-section' -ne $null) {$text1 = $xmlitem.tile.visual.binding[0].text.'#cdata-section'}else {$text1 = ""}  
                        if($xmlitem.tile.visual.binding[1].text.'#text' -ne $null)  {$text2 = $xmlitem.tile.visual.binding[1].text.'#text'}
                            elseif($xmlitem.tile.visual.binding[1].text.'#cdata-section' -ne $null) {$text2 = $xmlitem.tile.visual.binding[1].text.'#cdata-section'}else {$text2 = ""}
                        if($xmlitem.tile.visual.binding[2].text.'#text' -ne $null)  {$text3 = $xmlitem.tile.visual.binding[2].text.'#text'} 
                            elseif($xmlitem.tile.visual.binding[2].text.'#cdata-section' -ne $null) {$text3 = $xmlitem.tile.visual.binding[2].text.'#cdata-section'}else {$text3 = ""}

                        if($xmlitem.tile.visual.binding[3].tex.'#text' -ne $null)   {$text4 = $xmlitem.tile.visual.binding[3].text.'#text'}  
                        elseif($xmlitem.tile.visual.binding[3].text.'#cdata-section' -ne $null) {$text4 = $xmlitem.tile.visual.binding[3].text.'#cdata-section'}else {$text4 = ""}

                        
                        if($xmlitem.tile.visual.'hint-lockDetailedStatus1' -ne $null) {$hintlockDetailedStatus1 = $xmlitem.tile.visual.'hint-lockDetailedStatus1'} else {$hintlockDetailedStatus1 = ""}
                        if($xmlitem.tile.visual.'hint-lockDetailedStatus2' -ne $null) {$hintlockDetailedStatus2 = $xmlitem.tile.visual.'hint-lockDetailedStatus2'} else {$hintlockDetailedStatus2 = ""}
                        if($xmlitem.tile.visual.'hint-lockDetailedStatus3' -ne $null) {$hintlockDetailedStatus3 = $xmlitem.tile.visual.'hint-lockDetailedStatus3'} else {$hintlockDetailedStatus3 = ""}

                            if($xmlitem.tile.visual.binding[0].image.src -ne $null) {$image1 = $xmlitem.tile.visual.binding[0].image.src} 
                        elseif($xmlitem.tile.visual.binding[1].image.src -ne $null) {$image1 = $xmlitem.tile.visual.binding[1].image.src} else {$image1 = ""}

                        if($xmlitem.tile.visual.binding[2].image.src -ne $null) {$image2 = $xmlitem.tile.visual.binding[2].image.src} else {$image2 = ""}

                            if($xmlitem.tile.visual.binding[0].image.alt -ne $null) {$alt1 = $xmlitem.tile.visual.binding[0].image.alt} 
                        elseif($xmlitem.tile.visual.binding[1].image.alt -ne $null) {$alt1 = $xmlitem.tile.visual.binding[1].image.alt} else {$alt1 = ""}
                            if($xmlitem.tile.visual.binding[2].image.alt -ne $null) {$alt2 = $xmlitem.tile.visual.binding[2].image.alt} else {$alt2 = ""}
                        } else {} 
                                                                 
                    if ($item.Type -eq 'badge' -and $xmlitem.badge -ne $null){
                        if($xmlitem.badge.value -ne $null) {$text1 = "Value = " + $xmlitem.badge.value} else {$text1 = $null}
                        if($xmlitem.badge.version -ne $null) {$version = $xmlitem.badge.version} else {$version = $null}
                        } 
                    else {} 
                    if ($item.Type -eq 'toast' -and $xmlitem.toast -ne $null){
                        if($xmlitem.toast.visual.binding.text -ne $null) {$text1 = $xmlitem.toast.visual.binding.text}else {$text1 = $null}  
                        if($xmlitem.toast.visual.binding.image.src -ne $null) {$image1 = $xmlitem.toast.visual.binding.image.src} else {$image1 = $null}
                        $text2 = $null
                        $text3 = $null
                        $text4 = $null
                        $image2 = $null
                        $hint1 = $null
                        $hint2 = $null
                        $hint3 = $null
                    }else {$null}
                                                                                           
                    
                    [PSCustomObject]@{
                                ID = $item.ID 
                                Handler_Id = $item.Handler_Id
                                Application = $item.Application
                                HandlerType = $item.HandlerType
                                Version = $Version
                                Type = $item.Type
                                Text1 = $text1
                                Text2 = $text2
                                Text3 = $text3
                                Text4 = $text4
                                Hint1 = $hintlockDetailedStatus1
                                Hint2 = $hintlockDetailedStatus2
                                Hint3 = $hintlockDetailedStatus3
                                AltText1 = $alt1
                                Image_Medium = $image1 
                                AltText2 = $alt2
                                Image_Large = $image2 
                                DisplayName = $displayName
                                PayloadType = $item.PayloadType
                                Tag = $item.Tag 
                                ArrivalTime = $item.ArrivalTime
                                ExpiryTime = $item.ExpiryTime
                                Handler_Created = $item.Handler_Created
                                Handler_Modified = $item.Handler_Modified
                                WNSId = $item.WNSId
                                WNFEventName = $item.WNFEventName
                                Channel_ID = $item.Channel_ID
                                Uri = $item.Uri
                                WNS_CreatedTime = $item.WNS_CreatedTime
                                WNS_ExpiryTime = $item.WNS_ExpiryTime
                                ActivityId = $item.ActivityId
                                Payload = $item.payload
                                 }
                           }                          


#Stop Timer2
$swn.stop()           
$Tn = $swn.Elapsed  

#Format of the txt filename and path:
$filenameFormat = $env:userprofile + "\desktop\Notifications_" + (Get-Date -Format "dd-MM-yyyy_hh-mm") + ".csv"
Write-host "Selected Rows will be saved as: " -f Yellow -nonewline; Write-Host $filenameFormat -f White

#Output results to screen table (and save selected rows to csv)          
$output|Out-GridView -PassThru -Title "There are ($dbncount) Notifications in : '$File' - QueryTime $Tn"|Export-Csv -Path $filenameFormat
[gc]::Collect() 
