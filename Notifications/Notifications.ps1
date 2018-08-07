#Set encoding to UTF-8 
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = (New-Object System.Text.UTF8Encoding)

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
order by ID desc
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
                    
                    $ID=$HandlerId=$HandlerType=$Type=$Application=$BadgeValue=$Version=$Text1=$Text2=$Text3=$Text4=$ToastLaunch=$ToastActivationType=$ToastScenario=$SubText1=$SubText2=$SubText3=$SubText4=$TImeStamp=$Audio=$Hint1=$Hint2=$Hint3=$Arg=$Content=$AltText1=$ImgHint1=$Image1=$AltText2=$ImgHint2=$Image2=$DisplayName=$Tag=$ArrivalTime=$ExpiryTime=$HandlerCreated=$HandlerModified=$WNSId=$WNFEventName =$ChannelID =$Uri =$WNSCreatedTime =$WNSExpiryTime=$ActivityId=$PayloadType=$Payload = $null                   
                    
                    #Remove-variable xmlitem
                    try {$xmlitem = [xml]($item.payload)} catch {}   
                     
                    
                   
                   if ($item.Type -eq 'toast' -and $xmlitem.toast -ne $false) { 

                     
                        if($xmlitem.toast.launch.count -ge 1 -and $xmlitem.toast.launch -ne $false) {$ToastLaunch = $xmlitem.toast.launch} 
                            else {$ToastLaunch = $null| Out-Null}
                        if($xmlitem.toast.activationType.count -ge 1 -and $xmlitem.toast.activationType -ne $false) {$ToastActivationType = $xmlitem.toast.activationType} 
                            else {$ToastActivationType = $null| Out-Null}
                        if($xmlitem.toast.scenario.count -ge 1 -and $xmlitem.toast.scenario -ne $false) {$ToastScenario = $xmlitem.toast.scenario} 
                            else {$ToastScenario = $null| Out-Null}
                        if ($xmlitem.toast.visual.binding.text.'#text'.count -eq 1 -and $xmlitem.toast.visual.binding.text.'#text'-ne $null){$text1 =$xmlitem.toast.visual.binding.text.'#text'}
                            elseif ($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[0].'#text' -ne $null){$text1 = $xmlitem.toast.visual.binding.text[0].'#text'}
                            elseif ($xmlitem.toast.visual.binding.text.count -ge 1 -and $xmlitem.toast.visual.binding.text[0] -ne $null){$text1 = $xmlitem.toast.visual.binding.text[0]}else{}
                        if ($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[1].'#text' -ne $null){$text2 =$xmlitem.toast.visual.binding.text[1].'#text'}
                             elseif ($xmlitem.toast.visual.binding.text.count -ge 1 -and $xmlitem.toast.visual.binding.text[1] -ne $null){$text2 = $xmlitem.toast.visual.binding.text[1]}else{}
                        if ($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[2].'#text' -ne $null){$text3 =$xmlitem.toast.visual.binding.text[2].'#text'}
                             elseif ($xmlitem.toast.visual.binding.text.count -ge 1 -and $xmlitem.toast.visual.binding.text[2] -ne $null){$text3 = $xmlitem.toast.visual.binding.text[2]}else{}
                        if ($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[3].'#text' -ne $null){$text4 =$xmlitem.toast.visual.binding.text[3].'#text'}
                             elseif ($xmlitem.toast.visual.binding.text.count -ge 1 -and $xmlitem.toast.visual.binding.text[3] -ne $null){$text4 = $xmlitem.toast.visual.binding.text[3]}else{}
                        if($xmlitem.toast.visual.binding.image.src.count -ge 1 -and $xmlitem.toast.visual.binding.image.src -ne $false) {$Image1 = $xmlitem.toast.visual.binding.image.src} 
                            else {$Image1 = $null| Out-Null}
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
                        if($xmlitem.badge.version.count -ge 1) {$Version = $xmlitem.badge.version} 
                            else {$Version = $null| Out-Null}
                        }
                    
                    elseif($item.Type -eq 'tile' -and $xmlitem.tile -ne $false){

                        if($xmlitem.tile.visual.version.count -eq 1 -and $xmlitem.tile.visual.version -ne $false ){$Version = $xmlitem.tile.visual.version} 
                            else {$Version = $null| Out-Null}
                        if($xmlitem.tile.visual.binding.displayName.count -ge 1 -and $xmlitem.tile.visual.binding.displayName[0] -ne $false) {$displayName = $xmlitem.tile.visual.binding.displayName[0]} 
                            else {$displayName = $null| Out-Null}
                    if ($xmlitem.tile.visual.binding[0].text.'#text'.count -ge 1 -and $xmlitem.tile.visual.binding[0].text.'#text' -ne $null){
                        foreach($x in $xmlitem.tile.visual.binding[0].text.'#text'){$Text1 += $x + " "}}
                    elseif($xmlitem.tile.visual.binding[0].text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[0].text.'#cdata-section' -ne $null){ 
                        foreach($x in $xmlitem.tile.visual.binding[0].text.'#cdata-section'){$Text1 += $x + " "}}
                    else{}  
                    if ($xmlitem.tile.visual.binding[1].text.'#text'.count -ge 1 -and $xmlitem.tile.visual.binding[1].text.'#text' -ne $null){
                        foreach($x in $xmlitem.tile.visual.binding[1].text.'#text'){$Text21 += $x + " "}}
                    elseif($xmlitem.tile.visual.binding[1].text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[1].text.'#cdata-section' -ne $null){ 
                        foreach($x in $xmlitem.tile.visual.binding[1].text.'#cdata-section'){$Text2 += $x + " "}}
                    else{}  
                    if ($xmlitem.tile.visual.binding[2].text.'#text'.count -ge 1 -and $xmlitem.tile.visual.binding[2].text.'#text' -ne $null){
                        foreach($x in $xmlitem.tile.visual.binding[2].text.'#text'){$Text3 += $x + " "}}
                    elseif($xmlitem.tile.visual.binding[2].text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[2].text.'#cdata-section' -ne $null){ 
                        foreach($x in $xmlitem.tile.visual.binding[2].text.'#cdata-section'){$Text3 += $x + " ,"}}
                    else{}  
                    if ($xmlitem.tile.visual.binding[3].text.'#text'.count -ge 1 -and $xmlitem.tile.visual.binding[3].text.'#text' -ne $null){
                        foreach($x in $xmlitem.tile.visual.binding[3].text.'#text'){$Text4 += $x + " "}}
                    elseif($xmlitem.tile.visual.binding[3].text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[3].text.'#cdata-section' -ne $null){ 
                        foreach($x in $xmlitem.tile.visual.binding[3].text.'#cdata-section'){$Text4 += $x + " "}}
                    else{}  
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

                    if ($xmlitem.tile.visual.binding[0].image.alt.count -ge 1 -and $xmlitem.tile.visual.binding[0].image.alt -ne $false){
                        foreach($a in $xmlitem.tile.visual.binding[0].image.alt){$Alttext1 += $a + " "}}
                    elseif ($xmlitem.tile.visual.binding[1].image.alt.count -ge 2 -and $xmlitem.tile.visual.binding[1].image.alt -ne $false){
                        foreach($a in $xmlitem.tile.visual.binding[1].image.alt){$Alttext1 += $a + " "}}
                    else{$Alttext1 = $null| Out-Null} 
                    if($xmlitem.tile.visual.binding[2].image.alt.count -ge 3 -and $xmlitem.tile.visual.binding[2].image.alt -ne $false) {$Alttext2 = $xmlitem.tile.visual.binding[2].image.alt} 
                        else {$Alttext2 = $null| Out-Null}
                    if($xmlitem.tile.visual.binding.'hint-presentation'.count -ge 1 -and $xmlitem.tile.visual.binding.'hint-presentation'[0] -ne $false){$TileHint1=$xmlitem.tile.visual.binding.'hint-presentation'[0]}
                        else {$TileHint1 = $null| Out-Null}    
                    if($xmlitem.tile.visual.binding.'hint-presentation'.count -ge 3 -and $xmlitem.tile.visual.binding.'hint-presentation'[2] -ne $false){$TileHint2=$xmlitem.tile.visual.binding.'hint-presentation'[2]}
                        else {$TileHint2 = $null| Out-Null}

                    if ($xmlitem.tile.visual.binding.group.subgroup.text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[0].group.subgroup.text.'#cdata-section' -ne $null){
                        foreach($t in $xmlitem.tile.visual.binding[0].group.subgroup.text.'#cdata-section'){$Subtext1 += $t + " "}}
                    elseif($xmlitem.tile.visual.binding.group.subgroup.text.'#text'.count -ge 1 -and $xmlitem.tile.visual.binding[0].group.subgroup.text.'#text' -ne $null){ 
                        foreach($t in $xmlitem.tile.visual.binding[0].group.subgroup.text.'#text'){$Subtext1 += $t + " "}}
                    else{}                    
                    if ($xmlitem.tile.visual.binding.group.subgroup.text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[1].group.subgroup.text.'#cdata-section' -ne $null){
                        foreach($t in $xmlitem.tile.visual.binding[1].group.subgroup.text.'#cdata-section'){$Subtext2 += $t + " "}}
                    elseif($xmlitem.tile.visual.binding.group.subgroup.text.'#text'.count -ge 1 -and $xmlitem.tile.visual.binding[1].group.subgroup.text.'#text' -ne $null){ 
                        foreach($t in $xmlitem.tile.visual.binding[1].group.subgroup.text.'#text'){$Subtext23 += $t + " "}}
                    else{}
                    if ($xmlitem.tile.visual.binding.group.subgroup.text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[2].group.subgroup.text.'#cdata-section' -ne $null){
                        foreach($t in $xmlitem.tile.visual.binding[2].group.subgroup.text.'#cdata-section'){$Subtext3 += $t + " "}}
                    elseif($xmlitem.tile.visual.binding.group.subgroup.text.'#text'.count -ge 1 -and $xmlitem.tile.visual.binding[2].group.subgroup.text.'#text' -ne $null){ 
                        foreach($t in $xmlitem.tile.visual.binding[2].group.subgroup.text.'#text'){$Subtext3 += $t + " "}}
                    if ($xmlitem.tile.visual.binding.group.subgroup.text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[3].group.subgroup.text.'#cdata-section' -ne $null){
                        foreach($t in $xmlitem.tile.visual.binding[3].group.subgroup.text.'#cdata-section'){$Subtext4 += $t + " "}}
                    elseif($xmlitem.tile.visual.binding.group.subgroup.text.'#text'.count -ge 1 -and $xmlitem.tile.visual.binding[3].group.subgroup.text.'#text' -ne $null){ 
                        foreach($t in $xmlitem.tile.visual.binding[3].group.subgroup.text.'#text'){$Subtext4 += $t + " "}}
                    if ($xmlitem.tile.visual.binding.group.subgroup.text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[4].group.subgroup.text.'#cdata-section' -ne $null){
                        foreach($t in $xmlitem.tile.visual.binding[4].group.subgroup.text.'#cdata-section'){$Subtext5 += $t + " "}}
                    elseif($xmlitem.tile.visual.binding.group.subgroup.text.'#text'.count -ge 1 -and $xmlitem.tile.visual.binding[4].group.subgroup.text.'#text' -ne $null){ 
                        foreach($t in $xmlitem.tile.visual.binding[4].group.subgroup.text.'#text'){$Subtext5 += $t + " "}}
                    else{}

                    }else{$null}

                                                                                               
                    
                    [PSCustomObject]@{
                                ID = $item.ID 
                                HandlerId = $item.HandlerId
                                HandlerType = $item.HandlerType
                                Type = $item.Type
                                Application = $item.Application
                                Tag = $item.Tag 
                                ArrivalTime = $item.ArrivalTime
                                ExpiryTime = $item.ExpiryTime
                                BadgeValue = $BadgeValue
                                Version = $Version
                                Text1 = $text1
                                Text2 = $text2
                                Text3 = $text3
                                Text4 = $text4
                                SubText1 = $SubText1
                                SubText2 = $SubText2
                                SubText3 = $SubText3
                                SubText4 = $SubText4
                                Hint1 = $hintlockDetailedStatus1
                                Hint2 = $hintlockDetailedStatus2
                                Hint3 = $hintlockDetailedStatus3
                                ToastLaunch = $ToastLaunch
                                ToastActivationType = $ToastActivationType
                                ToastScenario = $ToastScenario
                                TImeStamp = $Timestampt
                                AudioSrc = $Audio
                                Arg = $Arg
                                Content = $Content
                                AltText1 = $AltText1
                                ImgHint1 = $TileHint1
                                ImageMedium = $image1 
                                AltText2 = $AltText2
                                ImgHint2 = $TileHint2
                                ImageLarge = $image2 
                                DisplayName = $displayName
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
$output|Out-GridView -PassThru -Title "There are ($dbncount) Notifications in : '$File' - QueryTime $Tn"|Export-Csv -Path $filenameFormat -Encoding Unicode
[gc]::Collect() 