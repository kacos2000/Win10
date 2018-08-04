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
    Notification.HandlerId as 'HandlerId',
    NotificationHandler.HandlerType as 'HandlerType',
    Notification.Type as 'Type',
    NotificationHandler.PrimaryId as 'Application',
    Notification.Tag as 'Tag',
    datetime((Notification.ArrivalTime - 116444736000000000)/10000000, 'unixepoch') as 'ArrivalTime',
    case when Notification.ExpiryTime = 0 then 'Expired' else datetime((Notification.ExpiryTime - 116444736000000000)/10000000, 'unixepoch') end as 'ExpiryTime',
    NotificationHandler.CreatedTime as 'HandlerCreated',
    NotificationHandler.ModifiedTime as 'HandlerModified',
    NotificationHandler.WNSId as 'WNSId',
    NotificationHandler.WNFEventName as 'WNFEventName',
    WNSPushChannel.ChannelId as 'ChannelID',
    WNSPushChannel.Uri as 'Uri',
    datetime((WNSPushChannel.CreatedTime - 116444736000000000)/10000000, 'unixepoch') as 'WNSCreatedTime',
    datetime((WNSPushChannel.ExpiryTime - 116444736000000000)/10000000, 'unixepoch') as 'WNSExpiryTime',
    hex(Notification.ActivityId) as 'ActivityId',
    Notification.PayloadType as 'PayloadType',
    replace(replace(replace(replace(Notification.Payload, x'0A',''),x'09',''),x'20'||x'20',''),x'0D','') as 'payload'
    from Notification
Join NotificationHandler on NotificationHandler.RecordId = Notification.HandlerId
Left Join WNSPushChannel on WNSPushChannel.HandlerId = NotificationHandler.RecordId
order by id desc
"

1..1000 | %{write-progress -id 1 -activity "Running SQLite query" -status "$([string]::Format("Time Elapsed: {0:d2}:{1:d2}:{2:d2}", $elapsedTime.Elapsed.hours, $elapsedTime.Elapsed.minutes, $elapsedTime.Elapsed.seconds))" -percentcomplete ($_/100);}

#Run SQLite3.exe with the above query
$dbnresults = @(sqlite3.exe -readonly -separator '**' $dbn $sql |
ConvertFrom-String -Delimiter '\u002A\u002A' -PropertyNames Id, HandlerId, HandlerType, Type, Application, Tag, ArrivalTime, ExpiryTime, HandlerCreated, HandlerModified, WNSId, WNFEventName, ChannelID,Uri, WNSCreatedTime, WNSExpiryTime, ActivityId, PayloadType, Payload)

$dbncount=$dbnresults.count
$elapsedTime.stop()
#write-progress -id 1 -activity "Running SQLite query" -status "$dbncount Entries - Query Finished" 
$rn=0


#Create Output adding XML Blob information
$output = foreach ($item in $dbnresults ){$rn++
                    Write-Progress -id 2 -Activity "Creating Output" -Status "$rn of $($dbnresults.count))" -PercentComplete (([double]$rn / $dbnresults.count)*100) 
                    
                    $ID=$HandlerId=$HandlerType=$Type=$Application=$BadgeValue=$BadgeVersion=$TileVersion=$Text1=$Text2=$Text3=$Text4=$Text5=$Text6=$ToastLaunch=$ToastActivationType=$ToastScenario=$toasttext1=$toasttext2=$ToastText3=$ToastText4=$ToastText5=$ToastText6=$ToastImage=$SubText1=$SubText2=$SubText3=$TImeStamp=$AudioSrc=$Hint1=$Hint2=$Hint3=$Arg=$Content=$AltText1=$ImgHint1=$Image1=$AltText2=$ImgHint2=$Image2=$DisplayName=$Tag=$ArrivalTime=$ExpiryTime=$HandlerCreated=$HandlerModified=$WNSId=$WNFEventName =$ChannelID =$Uri =$WNSCreatedTime =$WNSExpiryTime=$ActivityId=$PayloadType=$Payload = $null                   
                    
                    #Remove-variable xmlitem
                    try {$xmlitem = [xml]($item.payload)} catch {}   
                     
                    
                   
                   if ($item.Type -eq 'toast' -and $xmlitem.toast -ne $false) { 
                     
                        if($xmlitem.toast.launch.count -eq 1 -and $xmlitem.toast.launch -ne $false) {$ToastLaunch = $xmlitem.toast.launch} 
                            else {$ToastLaunch = $null| Out-Null}
                        if($xmlitem.toast.activationType.count -eq 1 -and $xmlitem.toast.activationType -ne $false) {$ToastActivationType = $xmlitem.toast.activationType} 
                            else {$ToastActivationType = $null| Out-Null}
                        if($xmlitem.toast.scenario.count -eq 1 -and $xmlitem.toast.scenario -ne $false) {$ToastScenario = $xmlitem.toast.scenario} 
                            else {$ToastScenario = $null| Out-Null}
                        if($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[0].'#text'-ne $false) {$toasttext1 = $xmlitem.toast.visual.binding.text[0].'#text'}
                            else {$toasttext1 = $null| Out-Null}
                        if($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[1].'#text'-ne $false) {$toasttext2 = $xmlitem.toast.visual.binding.text[1].'#text'} 
                            else {$toasttext2 = $null| Out-Null}
                        if($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[2].'#text'-ne $false) {$toasttext3 = $xmlitem.toast.visual.binding.text[2].'#text'} 
                            else {$toasttext3 = $null| Out-Null}
                        if($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[3].'#text'-ne $false) {$toasttext4 = $xmlitem.toast.visual.binding.text[3].'#text'} 
                            else {$toasttext4 = $null| Out-Null}
                        if($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[4].'#text'-ne $false) {$toasttext5 = $xmlitem.toast.visual.binding.text[4].'#text'} 
                            else {$toasttext5 = $null| Out-Null}
                        if($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[5].'#text'-ne $false) {$toasttext6 = $xmlitem.toast.visual.binding.text[5].'#text'} 
                            else {$toasttext6 = $null| Out-Null}
                        if($xmlitem.toast.visual.binding.image.src.count -ge 1 -and $xmlitem.toast.visual.binding.image.src -ne $false) {$ToastImage = $xmlitem.toast.visual.binding.image.src} 
                            else {$ToastImage = $null| Out-Null}
                        if($xmlitem.toast.action.activationtype.count -ge 1 -and $xmlitem.toast.action.activationtype -ne $false) {$Act_type = $xmlitem.toast.action.activationtype} 
                            else {$Act_type = $null| Out-Null}
                        if($xmlitem.toast.action.arguments.count -ge 1 -and $xmlitem.toast.action.arguments -ne $false) {$arg = $xmlitem.toast.action.arguments} 
                            else {$arg = $null| Out-Null}
                        if($xmlitem.toast.action.Content.count -ge 1 -and $xmlitem.toast.action.Content -ne $false) {$Content = $xmlitem.toast.action.Content} 
                            else {$Content = $null| Out-Null}
                        if($xmlitem.toast.audio.src.count -ge 1 -and $xmlitem.toast.audio.src -ne $false) {$Audio = $xmlitem.toast.audio.src} 
                            else {$Audio = $null| Out-Null}
                        if($xmlitem.toast.DisplayTimestampt.count -ge 1 -and $xmlitem.toast.DisplayTimestamp -ne $false) {$Timestampt = $xmlitem.toast.DisplayTimestamp} 
                            else {$Timestampt = $null| Out-Null}
                    }
                                                       
                    elseif($item.Type -eq 'badge' -and $xmlitem.badge -ne $false){
                       
                        if($xmlitem.badge.value.count -ge 1) {$BadgeValue = $xmlitem.badge.value} 
                            else {$BadgeValue = $null| Out-Null}
                        if($xmlitem.badge.version.count -ge 1) {$BadgeVersion = $xmlitem.badge.version} 
                            else {$BadgeVersion = $null| Out-Null}
                        }
                    
                    elseif($item.Type -eq 'tile' -and $xmlitem.tile -ne $false){

                        if($xmlitem.tile.visual.version.count -eq 1 -and $xmlitem.tile.visual.version -ne $false ){$TileVersion = $xmlitem.tile.visual.version} 
                            else {$TileVersion = $null| Out-Null}
                        if($xmlitem.tile.visual.binding.displayName.count -ge 1 -and $xmlitem.tile.visual.binding.displayName[0] -ne $false) {$displayName = $xmlitem.tile.visual.binding.displayName[0]} 
                            else {$displayName = $null| Out-Null}
                        if($xmlitem.tile.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.tile.visual.binding[0].text.'#text' -ne $false)  {$text1 = $xmlitem.tile.visual.binding[0].text.'#text' } 
                            elseif
                          ($xmlitem.tile.visual.binding.text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[0].text.'#cdata-section' -ne $null){$text1 = $xmlitem.tile.visual.binding[0].text.'#cdata-section' }
                            else {$text1 = $null| Out-Null}
                        if($xmlitem.tile.visual.binding.text.'#text'.count -ge 2 -and $xmlitem.tile.visual.binding[1].text.'#text' -ne $false)  {$text2 = $xmlitem.tile.visual.binding[1].text.'#text' } 
                            elseif
                          ($xmlitem.tile.visual.binding.text.'#cdata-section'.count -ge 2 -and $xmlitem.tile.visual.binding[1].text.'#cdata-section' -ne $null){$text2 = $xmlitem.tile.visual.binding[1].text.'#cdata-section' }
                            else {$text2 = $null| Out-Null}                         
                        if($xmlitem.tile.visual.binding.text.'#text'.count -ge 3 -and $xmlitem.tile.visual.binding[2].text.'#text' -ne $false)  {$text3 = $xmlitem.tile.visual.binding[2].text.'#text' } 
                            elseif
                          ($xmlitem.tile.visual.binding.text.'#cdata-section'.count -ge 3 -and $xmlitem.tile.visual.binding[2].text.'#cdata-section' -ne $null){$text3 = $xmlitem.tile.visual.binding[2].text.'#cdata-section' }
                            else {$text3 = $null| Out-Null}  
                        if($xmlitem.tile.visual.binding.text.'#text'.count -ge 4 -and $xmlitem.tile.visual.binding[3].text.'#text' -ne $false)  {$text4 = $xmlitem.tile.visual.binding[3].text.'#text' } 
                            elseif
                          ($xmlitem.tile.visual.binding.text.'#cdata-section'.count -ge 4 -and $xmlitem.tile.visual.binding[3].text.'#cdata-section' -ne $null){$text4 = $xmlitem.tile.visual.binding[3].text.'#cdata-section' }
                            else {$text4 = $null| Out-Null}  
                        if($xmlitem.tile.visual.binding.text.'#text'.count -ge 5 -and $xmlitem.tile.visual.binding[4].text.'#text' -ne $false)  {$text5 = $xmlitem.tile.visual.binding[4].text.'#text' } 
                            elseif
                          ($xmlitem.tile.visual.binding.text.'#cdata-section'.count -ge 5 -and $xmlitem.tile.visual.binding[4].text.'#cdata-section' -ne $null){$text5 = $xmlitem.tile.visual.binding[4].text.'#cdata-section' }
                            else {$text5 = $null| Out-Null} 
                        if($xmlitem.tile.visual.binding.text.'#text'.count -ge 6 -and $xmlitem.tile.visual.binding[5].text.'#text' -ne $false)  {$text6 = $xmlitem.tile.visual.binding[5].text.'#text' } 
                            elseif
                          ($xmlitem.tile.visual.binding.text.'#cdata-section'.count -ge 6 -and $xmlitem.tile.visual.binding[5].text.'#cdata-section' -ne $false){$text6 = $xmlitem.tile.visual.binding[5].text.'#cdata-section' }
                            else {$text6 = $null| Out-Null} 
                        if($xmlitem.tile.visual.'hint-lockDetailedStatus1'.count -ge 1) {$hintlockDetailedStatus1 = $xmlitem.tile.visual.'hint-lockDetailedStatus1'} 
                            else {$hintlockDetailedStatus1 = $null| Out-Null}
                        if($xmlitem.tile.visual.'hint-lockDetailedStatus2'.count -ge 2) {$hintlockDetailedStatus2 = $xmlitem.tile.visual.'hint-lockDetailedStatus2'} 
                            else {$hintlockDetailedStatus2 = $null| Out-Null}
                        if($xmlitem.tile.visual.'hint-lockDetailedStatus3'.count -ge 3) {$hintlockDetailedStatus3 = $xmlitem.tile.visual.'hint-lockDetailedStatus3'} 
                            else {$hintlockDetailedStatus3 = $null| Out-Null}
                        if($xmlitem.tile.visual.binding.image.src.count -ge 1 -and $xmlitem.tile.visual.binding[0].image.src -ne $false) {$image1 = $xmlitem.tile.visual.binding[0].image.src} 
                            elseif($xmlitem.tile.visual.binding.image.src.count -ge 1 -and $xmlitem.tile.visual.binding[1].image.src -ne $false) {$image1 = $xmlitem.tile.visual.binding[1].image.src} 
                            else {$image1 = $null| Out-Null}
                        if($xmlitem.tile.visual.binding.image.count -ge 3 -and $xmlitem.tile.visual.binding[2].image.src -ne $false) {$image2 = $xmlitem.tile.visual.binding[2].image.src} 
                            else {$image2 = $null| Out-Null}
                        if($xmlitem.tile.visual.binding[0].image.alt.count -ge 1 -and $xmlitem.tile.visual.binding[0].image.alt -ne $false) {$Alttext1 = $xmlitem.tile.visual.binding[0].image.alt} 
                            elseif($xmlitem.tile.visual.binding[1].image.alt.count -ge 2 -and $xmlitem.tile.visual.binding[1].image.alt -ne $null) {$alt1 = $xmlitem.tile.visual.binding[1].image.alt} 
                            else {$Alttext1 = $null| Out-Null}
                        if($xmlitem.tile.visual.binding[2].image.alt.count -ge 3 -and $xmlitem.tile.visual.binding[2].image.alt -ne $false) {$Alttext2 = $xmlitem.tile.visual.binding[2].image.alt} 
                            else {$Alttext2 = $null| Out-Null}
                        if($xmlitem.tile.visual.binding.'hint-presentation'.count -ge 1 -and $xmlitem.tile.visual.binding.'hint-presentation'[0] -ne $false){$TileHint1=$xmlitem.tile.visual.binding.'hint-presentation'[0]}
                            else {$TileHint1 = $null| Out-Null}    
                        if($xmlitem.tile.visual.binding.'hint-presentation'.count -ge 3 -and $xmlitem.tile.visual.binding.'hint-presentation'[2] -ne $false){$TileHint2=$xmlitem.tile.visual.binding.'hint-presentation'[2]}
                            else {$TileHint2 = $null| Out-Null}

                        if($xmlitem.tile.visual.binding.group.subgroup.count -ge 1){
                            if($xmlitem.tile.visual.binding.group.subgroup.text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding.group.subgroup.text[0].'#cdata-section' -ne $false) 
                                    {$SubText1 = $xmlitem.tile.visual.binding.group.subgroup.text[0].'#cdata-section'} 
                                elseif($xmlitem.tile.visual.binding.group.subgroup.text.'#text' -ge 1 -and $xmlitem.tile.visual.binding.group.subgroup.text[0].'#text' -ne $false) 
                                    {$SubText1 = $xmlitem.tile.visual.binding.group.subgroup.text[0].'#text'}     
                                else {$SubText1 = $null| Out-Null} 
                             if($xmlitem.tile.visual.binding.group.subgroup.text.'#cdata-section'.count -ge 2 -and $xmlitem.tile.visual.binding.group.subgroup.text[1].'#cdata-section' -ne $false) 
                                    {$SubText2 = $xmlitem.tile.visual.binding.group.subgroup.text[1].'#cdata-section'} 
                                elseif($xmlitem.tile.visual.binding.group.subgroup.text.'#text' -ge 1 -and $xmlitem.tile.visual.binding.group.subgroup.text[1].'#text' -ne $false) 
                                    {$SubText2 = $xmlitem.tile.visual.binding.group.subgroup.text[1].'#text'}     
                                else {$SubText2 = $null| Out-Null}
                             if($xmlitem.tile.visual.binding.group.subgroup.text.'#cdata-section'.count -ge 3 -and $xmlitem.tile.visual.binding.group.subgroup.text[2].'#cdata-section' -ne $false) 
                                    {$SubText3 = $xmlitem.tile.visual.binding.group.subgroup.text[2].'#cdata-section'} 
                                elseif($xmlitem.tile.visual.binding.group.subgroup.text.'#text' -ge 2 -and $xmlitem.tile.visual.binding.group.subgroup.text[2].'#text' -ne $false) 
                                    {$SubText3= $xmlitem.tile.visual.binding.group.subgroup.text[2].'#text'}     
                                else {$SubText3= $null| Out-Null}
                            }else {$null} 
                    }else{$null}

                                                                                               
                    
                    [PSCustomObject]@{
                                ID = $item.ID 
                                HandlerId = $item.HandlerId
                                HandlerType = $item.HandlerType
                                Type = $item.Type
                                Application = $item.Application
                                BadgeValue = $BadgeValue
                                BadgeVersion = $BadgeVersion
                                TileVersion = $TileVersion
                                Text1 = $text1
                                Text2 = $text2
                                Text3 = $text3
                                Text4 = $text4
                                Text5 = $text5
                                Text6 = $text6
                                ToastLaunch = $ToastLaunch
                                ToastActivationType = $ToastActivationType
                                ToastScenario = $ToastScenario
                                ToastText1 = $toasttext1
                                ToastText2 = $toasttext2
                                ToastText3 = $toasttext3
                                ToastText4 = $toasttext4
                                ToastText5 = $toasttext5
                                ToastText6 = $toasttext6
                                ToastImage = $ToastImage
                                SubText1 = $SubText1
                                SubText2 = $SubText2
                                SubText3 = $SubText3
                                TImeStamp = $Timestampt
                                AudioSrc = $Audio
                                Hint1 = $hintlockDetailedStatus1
                                Hint2 = $hintlockDetailedStatus2
                                Hint3 = $hintlockDetailedStatus3
                                Arg = $Arg
                                Content = $Content
                                AltText1 = $AltText1
                                ImgHint1 = $TileHint1
                                ImageMedium = $image1 
                                AltText2 = $AltText2
                                ImgHint2 = $TileHint2
                                ImageLarge = $image2 
                                DisplayName = $displayName
                                Tag = $item.Tag 
                                ArrivalTime = $item.ArrivalTime
                                ExpiryTime = $item.ExpiryTime
                                HandlerCreated = $item.HandlerCreated
                                HandlerModified = $item.HandlerModified
                                WNSId = $item.WNSId
                                WNFEventName = $item.WNFEventName
                                ChannelID = $item.ChannelID
                                Uri = $item.Uri
                                WNSCreatedTime = $item.WNSCreatedTime
                                WNSExpiryTime = $item.WNSExpiryTime
                                ActivityId = $item.ActivityId
                                PayloadType = $item.PayloadType
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