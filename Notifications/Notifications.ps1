clear-host
# Check Validity of script
if ((Get-AuthenticodeSignature $MyInvocation.MyCommand.Path).Status -ne "Valid")
{
	
	$check = [System.Windows.Forms.MessageBox]::Show($this, "WARNING:`n$(Split-path $MyInvocation.MyCommand.Path -Leaf) has been modified since it was signed.`nPress 'YES' to Continue or 'No' to Exit", "Warning", 'YESNO', 48)
	switch ($check)
	{
		"YES"{ Continue }
		"NO"{ Exit }
	}
}
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
[Void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") 
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

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


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
                        if ($xmlitem.toast.visual.binding.text.'#text'.count -eq 1 -and $xmlitem.toast.visual.binding.text.'#text'-ne $false){$text1 =$xmlitem.toast.visual.binding.text.'#text'}
                            elseif ($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[0].'#text' -ne $false){$text1 = $xmlitem.toast.visual.binding.text[0].'#text'}
                            elseif ($xmlitem.toast.visual.binding.text.count -ge 1 -and $xmlitem.toast.visual.binding.text[0] -ne $false){$text1 = $xmlitem.toast.visual.binding.text[0]}else{}
                        if ($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[1].'#text' -ne $false){$text2 =$xmlitem.toast.visual.binding.text[1].'#text'}
                             elseif ($xmlitem.toast.visual.binding.text.count -ge 1 -and $xmlitem.toast.visual.binding.text[1] -ne $false){$text2 = $xmlitem.toast.visual.binding.text[1]}else{}
                        if ($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[2].'#text' -ne $false){$text3 =$xmlitem.toast.visual.binding.text[2].'#text'}
                             elseif ($xmlitem.toast.visual.binding.text.count -ge 1 -and $xmlitem.toast.visual.binding.text[2] -ne $false){$text3 = $xmlitem.toast.visual.binding.text[2]}else{}
                        if ($xmlitem.toast.visual.binding.text.'#text'.count -ge 1 -and $xmlitem.toast.visual.binding.text[3].'#text' -ne $false){$text4 =$xmlitem.toast.visual.binding.text[3].'#text'}
                             elseif ($xmlitem.toast.visual.binding.text.count -ge 1 -and $xmlitem.toast.visual.binding.text[3] -ne $false){$text4 = $xmlitem.toast.visual.binding.text[3]}else{}
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
                        foreach($x in $xmlitem.tile.visual.binding[1].text.'#text'){$Text2 += $x + " "}}
                    elseif($xmlitem.tile.visual.binding[1].text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[1].text.'#cdata-section' -ne $null){ 
                        foreach($x in $xmlitem.tile.visual.binding[1].text.'#cdata-section'){$Text2 += $x + " "}}
                    else{}  
                    if ($xmlitem.tile.visual.binding[2].text.'#text'.count -ge 1 -and $xmlitem.tile.visual.binding[2].text.'#text' -ne $null){
                        foreach($x in $xmlitem.tile.visual.binding[2].text.'#text'){$Text3 += $x + " "}}
                    elseif($xmlitem.tile.visual.binding[2].text.'#cdata-section'.count -ge 1 -and $xmlitem.tile.visual.binding[2].text.'#cdata-section' -ne $null){ 
                        foreach($x in $xmlitem.tile.visual.binding[2].text.'#cdata-section'){$Text3 += $x + " "}}
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
                                Text = "$($text1) $($text2) $($text3) $($text4)"
                                SubText = "$($SubText1) $($SubText2) $($SubText3) $($SubText4)"
                                Hint = "$($hintlockDetailedStatus1) $($hintlockDetailedStatus2) $($hintlockDetailedStatus3)"
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
$output|Out-GridView -PassThru -Title "There are ($dbncount) Notifications in : '$File' - QueryTime $Tn"#Export-Csv -Path $filenameFormat -Encoding UTF8
[gc]::Collect() 
# SIG # Begin signature block
# MIIfcAYJKoZIhvcNAQcCoIIfYTCCH10CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBA6m+pOaZKw64c
# zVksOu7xN6pRyGRDNNsYF1jV7zygjaCCGf4wggQVMIIC/aADAgECAgsEAAAAAAEx
# icZQBDANBgkqhkiG9w0BAQsFADBMMSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3Qg
# Q0EgLSBSMzETMBEGA1UEChMKR2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2ln
# bjAeFw0xMTA4MDIxMDAwMDBaFw0yOTAzMjkxMDAwMDBaMFsxCzAJBgNVBAYTAkJF
# MRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWdu
# IFRpbWVzdGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyMIIBIjANBgkqhkiG9w0BAQEF
# AAOCAQ8AMIIBCgKCAQEAqpuOw6sRUSUBtpaU4k/YwQj2RiPZRcWVl1urGr/SbFfJ
# MwYfoA/GPH5TSHq/nYeer+7DjEfhQuzj46FKbAwXxKbBuc1b8R5EiY7+C94hWBPu
# TcjFZwscsrPxNHaRossHbTfFoEcmAhWkkJGpeZ7X61edK3wi2BTX8QceeCI2a3d5
# r6/5f45O4bUIMf3q7UtxYowj8QM5j0R5tnYDV56tLwhG3NKMvPSOdM7IaGlRdhGL
# D10kWxlUPSbMQI2CJxtZIH1Z9pOAjvgqOP1roEBlH1d2zFuOBE8sqNuEUBNPxtyL
# ufjdaUyI65x7MCb8eli7WbwUcpKBV7d2ydiACoBuCQIDAQABo4HoMIHlMA4GA1Ud
# DwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBSSIadKlV1k
# sJu0HuYAN0fmnUErTDBHBgNVHSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYm
# aHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wNgYDVR0fBC8w
# LTAroCmgJ4YlaHR0cDovL2NybC5nbG9iYWxzaWduLm5ldC9yb290LXIzLmNybDAf
# BgNVHSMEGDAWgBSP8Et/qC5FJK5NUPpjmove4t0bvDANBgkqhkiG9w0BAQsFAAOC
# AQEABFaCSnzQzsm/NmbRvjWek2yX6AbOMRhZ+WxBX4AuwEIluBjH/NSxN8RooM8o
# agN0S2OXhXdhO9cv4/W9M6KSfREfnops7yyw9GKNNnPRFjbxvF7stICYePzSdnno
# 4SGU4B/EouGqZ9uznHPlQCLPOc7b5neVp7uyy/YZhp2fyNSYBbJxb051rvE9ZGo7
# Xk5GpipdCJLxo/MddL9iDSOMXCo4ldLA1c3PiNofKLW6gWlkKrWmotVzr9xG2wSu
# kdduxZi61EfEVnSAR3hYjL7vK/3sbL/RlPe/UOB74JD9IBh4GCJdCC6MHKCX8x2Z
# faOdkdMGRE4EbnocIOM28LZQuTCCBMYwggOuoAMCAQICDCRUuH8eFFOtN/qheDAN
# BgkqhkiG9w0BAQsFADBbMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2ln
# biBudi1zYTExMC8GA1UEAxMoR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBT
# SEEyNTYgLSBHMjAeFw0xODAyMTkwMDAwMDBaFw0yOTAzMTgxMDAwMDBaMDsxOTA3
# BgNVBAMMMEdsb2JhbFNpZ24gVFNBIGZvciBNUyBBdXRoZW50aWNvZGUgYWR2YW5j
# ZWQgLSBHMjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANl4YaGWrhL/
# o/8n9kRge2pWLWfjX58xkipI7fkFhA5tTiJWytiZl45pyp97DwjIKito0ShhK5/k
# Ju66uPew7F5qG+JYtbS9HQntzeg91Gb/viIibTYmzxF4l+lVACjD6TdOvRnlF4RI
# shwhrexz0vOop+lf6DXOhROnIpusgun+8V/EElqx9wxA5tKg4E1o0O0MDBAdjwVf
# ZFX5uyhHBgzYBj83wyY2JYx7DyeIXDgxpQH2XmTeg8AUXODn0l7MjeojgBkqs2Iu
# YMeqZ9azQO5Sf1YM79kF15UgXYUVQM9ekZVRnkYaF5G+wcAHdbJL9za6xVRsX4ob
# +w0oYciJ8BUCAwEAAaOCAagwggGkMA4GA1UdDwEB/wQEAwIHgDBMBgNVHSAERTBD
# MEEGCSsGAQQBoDIBHjA0MDIGCCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxz
# aWduLmNvbS9yZXBvc2l0b3J5LzAJBgNVHRMEAjAAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMEYGA1UdHwQ/MD0wO6A5oDeGNWh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5j
# b20vZ3MvZ3N0aW1lc3RhbXBpbmdzaGEyZzIuY3JsMIGYBggrBgEFBQcBAQSBizCB
# iDBIBggrBgEFBQcwAoY8aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNl
# cnQvZ3N0aW1lc3RhbXBpbmdzaGEyZzIuY3J0MDwGCCsGAQUFBzABhjBodHRwOi8v
# b2NzcDIuZ2xvYmFsc2lnbi5jb20vZ3N0aW1lc3RhbXBpbmdzaGEyZzIwHQYDVR0O
# BBYEFNSHuI3m5UA8nVoGY8ZFhNnduxzDMB8GA1UdIwQYMBaAFJIhp0qVXWSwm7Qe
# 5gA3R+adQStMMA0GCSqGSIb3DQEBCwUAA4IBAQAkclClDLxACabB9NWCak5BX87H
# iDnT5Hz5Imw4eLj0uvdr4STrnXzNSKyL7LV2TI/cgmkIlue64We28Ka/GAhC4evN
# GVg5pRFhI9YZ1wDpu9L5X0H7BD7+iiBgDNFPI1oZGhjv2Mbe1l9UoXqT4bZ3hcD7
# sUbECa4vU/uVnI4m4krkxOY8Ne+6xtm5xc3NB5tjuz0PYbxVfCMQtYyKo9JoRbFA
# uqDdPBsVQLhJeG/llMBtVks89hIq1IXzSBMF4bswRQpBt3ySbr5OkmCCyltk5lXT
# 0gfenV+boQHtm/DDXbsZ8BgMmqAc6WoICz3pZpendR4PvyjXCSMN4hb6uvM0MIIF
# PDCCBCSgAwIBAgIRALjpohQ9sxfPAIfj9za0FgUwDQYJKoZIhvcNAQELBQAwfDEL
# MAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UE
# BxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtT
# ZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwHhcNMjAwMjIwMDAwMDAwWhcNMjIw
# MjE5MjM1OTU5WjCBrDELMAkGA1UEBhMCR1IxDjAMBgNVBBEMBTU1NTM1MRUwEwYD
# VQQIDAxUaGVzc2Fsb25pa2kxDzANBgNVBAcMBlB5bGFpYTEbMBkGA1UECQwSMzIg
# Qml6YW5pb3UgU3RyZWV0MSMwIQYDVQQKDBpLYXRzYXZvdW5pZGlzIEtvbnN0YW50
# aW5vczEjMCEGA1UEAwwaS2F0c2F2b3VuaWRpcyBLb25zdGFudGlub3MwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDa2C7McRZbPAGLVPCcYCmhqbVRVGBV
# JXZhqJKFbJA95o2z4AiyB7C/cQGy1F3c3jW9Balp3uESAsy6JrJI+g62vxzk6chx
# tcre1PPnjqdcDQyetHRA7ZseDnFhk6DvxDR0emBHmdycAjWq3kACWwkKQADyuQ3D
# 6MxRhG3InKkv+e1OjVjW8zJobo8wxfVVrxDML8TIOu2QzgpCMf67gcFtzhtkNYKO
# 0ukSgVZ4YXrv8tenw5jLxR9Yv5RKGE1yXzafUy17RsxsEIEZx2IGBxmSF2HJCSbW
# vEXtcVslnzmttRS+tyNBxnXB/NK8Zf2h189414mjZy/pfUmTMQwcZOKdAgMBAAGj
# ggGGMIIBgjAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUH9X2tKd+540Ixy1znv3RfwoyR9cwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEAG
# A1UdIAQ5MDcwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwuc2Vj
# dGlnby5jb20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3JsMHMGCCsGAQUFBwEB
# BGcwZTA+BggrBgEFBQcwAoYyaHR0cDovL2NydC5zZWN0aWdvLmNvbS9TZWN0aWdv
# UlNBQ29kZVNpZ25pbmdDQS5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLnNl
# Y3RpZ28uY29tMA0GCSqGSIb3DQEBCwUAA4IBAQBbQmN6mJ6/Ff0c3bzLtKFKxbXP
# ZHjHTxB74mqp38MGdhMfPsQ52I5rH9+b/d/6g6BKJnTz293Oxcoa29+iRuwljGbv
# /kkjM80iALnorUQsk+RA+jCJ9XTqUbiWtb2Zx828GoCE8OJ1EyAozVVEA4bcu+nc
# cAFDd78YGyguDMHaYfnWjA2R2HkT4nYSu2u80+FeRuodmnB2dcM89k0a+XjuhDuG
# 8DJRcI2tjRZnR7geRHwVEFFPc/ZdAjRaFpAUgEArCWoIHAMtIf0W/fdtXrbdIeg9
# ibmcGiFH70Q/VvaXoDx+9qYLeYvEtAAEiHflfFElV2WIC+N47DLZxpkO7D68MIIF
# 3jCCA8agAwIBAgIQAf1tMPyjylGoG7xkDjUDLTANBgkqhkiG9w0BAQwFADCBiDEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNl
# eSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMT
# JVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTAwMjAx
# MDAwMDAwWhcNMzgwMTE4MjM1OTU5WjCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Ck5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg
# VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQCAEmUXNg7D2wiz0KxXDXbtzSfTTK1Qg2HiqiBNCS1kCdzOiZ/MPans9s/B3PHT
# sdZ7NygRK0faOca8Ohm0X6a9fZ2jY0K2dvKpOyuR+OJv0OwWIJAJPuLodMkYtJHU
# YmTbf6MG8YgYapAiPLz+E/CHFHv25B+O1ORRxhFnRghRy4YUVD+8M/5+bJz/Fp0Y
# vVGONaanZshyZ9shZrHUm3gDwFA66Mzw3LyeTP6vBZY1H1dat//O+T23LLb2VN3I
# 5xI6Ta5MirdcmrS3ID3KfyI0rn47aGYBROcBTkZTmzNg95S+UzeQc0PzMsNT79uq
# /nROacdrjGCT3sTHDN/hMq7MkztReJVni+49Vv4M0GkPGw/zJSZrM233bkf6c0Pl
# fg6lZrEpfDKEY1WJxA3Bk1QwGROs0303p+tdOmw1XNtB1xLaqUkL39iAigmTYo61
# Zs8liM2EuLE/pDkP2QKe6xJMlXzzawWpXhaDzLhn4ugTncxbgtNMs+1b/97lc6wj
# Oy0AvzVVdAlJ2ElYGn+SNuZRkg7zJn0cTRe8yexDJtC/QV9AqURE9JnnV4eeUB9X
# VKg+/XRjL7FQZQnmWEIuQxpMtPAlR1n6BB6T1CZGSlCBst6+eLf8ZxXhyVeEHg9j
# 1uliutZfVS7qXMYoCAQlObgOK6nyTJccBz8NUvXt7y+CDwIDAQABo0IwQDAdBgNV
# HQ4EFgQUU3m/WqorSs9UgOHYm8Cd8rIDZsswDgYDVR0PAQH/BAQDAgEGMA8GA1Ud
# EwEB/wQFMAMBAf8wDQYJKoZIhvcNAQEMBQADggIBAFzUfA3P9wF9QZllDHPFUp/L
# +M+ZBn8b2kMVn54CVVeWFPFSPCeHlCjtHzoBN6J2/FNQwISbxmtOuowhT6KOVWKR
# 82kV2LyI48SqC/3vqOlLVSoGIG1VeCkZ7l8wXEskEVX/JJpuXior7gtNn3/3ATiU
# FJVDBwn7YKnuHKsSjKCaXqeYalltiz8I+8jRRa8YFWSQEg9zKC7F4iRO/Fjs8PRF
# /iKz6y+O0tlFYQXBl2+odnKPi4w2r78NBc5xjeambx9spnFixdjQg3IM8WcRiQyc
# E0xyNN+81XHfqnHd4blsjDwSXWXavVcStkNr/+XeTWYRUc+ZruwXtuhxkYzeSf7d
# NXGiFSeUHM9h4ya7b6NnJSFd5t0dCy5oGzuCr+yDZ4XUmFF0sbmZgIn/f3gZXHlK
# YC6SQK5MNyosycdiyA5d9zZbyuAlJQG03RoHnHcAP9Dc1ew91Pq7P8yF1m9/qS3f
# uQL39ZeatTXaw2ewh0qpKJ4jjv9cJ2vhsE/zB+4ALtRZh8tSQZXq9EfX7mRBVXyN
# WQKV3WKdwrnuWih0hKWbt5DHDAff9Yk2dDLWKMGwsAvgnEzDHNb842m1R0aBL6KC
# q9NjRHDEjf8tM7qtj3u1cIiuPhnPQCjY/MiQu12ZIvVS5ljFH4gxQ+6IHdfGjjxD
# ah2nGN59PRbxYvnKkKj9MIIF9TCCA92gAwIBAgIQHaJIMG+bJhjQguCWfTPTajAN
# BgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJz
# ZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNU
# IE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBB
# dXRob3JpdHkwHhcNMTgxMTAyMDAwMDAwWhcNMzAxMjMxMjM1OTU5WjB8MQswCQYD
# VQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdT
# YWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJDAiBgNVBAMTG1NlY3Rp
# Z28gUlNBIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
# AQoCggEBAIYijTKFehifSfCWL2MIHi3cfJ8Uz+MmtiVmKUCGVEZ0MWLFEO2yhyem
# mcuVMMBW9aR1xqkOUGKlUZEQauBLYq798PgYrKf/7i4zIPoMGYmobHutAMNhodxp
# ZW0fbieW15dRhqb0J+V8aouVHltg1X7XFpKcAC9o95ftanK+ODtj3o+/bkxBXRIg
# CFnoOc2P0tbPBrRXBbZOoT5Xax+YvMRi1hsLjcdmG0qfnYHEckC14l/vC0X/o84X
# pi1VsLewvFRqnbyNVlPG8Lp5UEks9wO5/i9lNfIi6iwHr0bZ+UYc3Ix8cSjz/qfG
# FN1VkW6KEQ3fBiSVfQ+noXw62oY1YdMCAwEAAaOCAWQwggFgMB8GA1UdIwQYMBaA
# FFN5v1qqK0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQWBBQO4TqoUzox1Yq+wbutZxoD
# ha00DjAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHSUE
# FjAUBggrBgEFBQcDAwYIKwYBBQUHAwgwEQYDVR0gBAowCDAGBgRVHSAAMFAGA1Ud
# HwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RS
# U0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2BggrBgEFBQcBAQRqMGgwPwYI
# KwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FB
# ZGRUcnVzdENBLmNydDAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0
# LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEATWNQ7Uc0SmGk295qKoyb8QAAHh1iezrX
# MsL2s+Bjs/thAIiaG20QBwRPvrjqiXgi6w9G7PNGXkBGiRL0C3danCpBOvzW9Ovn
# 9xWVM8Ohgyi33i/klPeFM4MtSkBIv5rCT0qxjyT0s4E307dksKYjalloUkJf/wTr
# 4XRleQj1qZPea3FAmZa6ePG5yOLDCBaxq2NayBWAbXReSnV+pbjDbLXP30p5h1zH
# QE1jNfYw08+1Cg4LBH+gS667o6XQhACTPlNdNKUANWlsvp8gJRANGftQkGG+OY96
# jk32nw4e/gdREmaDJhlIlc5KycF/8zoFm/lv34h/wCOe0h5DekUxwZxNqfBZslkZ
# 6GqNKQQCd3xLS81wvjqyVVp4Pry7bwMQJXcVNIr5NsxDkuS6T/FikyglVyn7URnH
# oSVAaoRXxrKdsbwcCtp8Z359LukoTBh+xHsxQXGaSynsCz1XUNLK3f2eBVHlRHjd
# Ad6xdZgNVCT98E7j4viDvXK6yz067vBeF5Jobchh+abxKgoLpbn0nu6YMgWFnuv5
# gynTxix9vTp3Los3QqBqgu07SqqUEKThDfgXxbZaeTMYkuO1dfih6Y4KJR7kHvGf
# Wocj/5+kUZ77OYARzdu1xKeogG/lU9Tg46LC0lsa+jImLWpXcBw8pFguo/NbSwfc
# Mlnzh6cabVgxggTIMIIExAIBATCBkTB8MQswCQYDVQQGEwJHQjEbMBkGA1UECBMS
# R3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9T
# ZWN0aWdvIExpbWl0ZWQxJDAiBgNVBAMTG1NlY3RpZ28gUlNBIENvZGUgU2lnbmlu
# ZyBDQQIRALjpohQ9sxfPAIfj9za0FgUwDQYJYIZIAWUDBAIBBQCgTDAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAvBgkqhkiG9w0BCQQxIgQgXkYeTd1V9dxYeIen
# dxf+I7tRAwguySRVBswMk6KnScgwDQYJKoZIhvcNAQEBBQAEggEAY/td0eFkZsRK
# pT2SlHQFfXgt1iJJcKHzKc96J7MtaHaqgsa0/z1hRVIKz7um1C4ja+NQdnPXKnRQ
# dN/o4WKWW295fI7MjPcorKXu8ZpI1nO65a1s3gog9kP+x51bMTb/t9n2/vjTUubx
# 0WkDOD5DzvxG4BUY8cS8r1ls3qMaxVOc+ZIPzfO+zbpJVVQD8vxWE9UZdL8/xMse
# 12kvoiIa7ARMDEYFZ77JZ18//I92bcg4QrU6HBFbQXSBKRMnstoLTAcnHXz55Gc5
# W/9udo/4TDjeC6rTF394GaDvnbsUEdlQRwNagp/n4lphyzi9sODnZ00GgGVza1az
# 0i9SYBWo06GCArkwggK1BgkqhkiG9w0BCQYxggKmMIICogIBATBrMFsxCzAJBgNV
# BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9i
# YWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyAgwkVLh/HhRTrTf6
# oXgwDQYJYIZIAWUDBAIBBQCgggEMMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
# HAYJKoZIhvcNAQkFMQ8XDTIwMDMwMTEyMjUzM1owLwYJKoZIhvcNAQkEMSIEIDcH
# 5o6uw+D96EOFBUOloWP0LsJG22CF4l6zAnZPMINHMIGgBgsqhkiG9w0BCRACDDGB
# kDCBjTCBijCBhwQUPsdm1dTUcuIbHyFDUhwxt5DZS2gwbzBfpF0wWzELMAkGA1UE
# BhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2Jh
# bFNpZ24gVGltZXN0YW1waW5nIENBIC0gU0hBMjU2IC0gRzICDCRUuH8eFFOtN/qh
# eDANBgkqhkiG9w0BAQEFAASCAQBIlFB/zFJIYmatTs/Auu/AyMHpTopljHH+E6h2
# DbR58Mowms45H/ZxLdj7Bk9p5oEv3iwsAlOZw/sHoPDuNqt3tZsRdfzYYevO51WV
# 290QueVQU/T4Tgztl/NFt6CVuUtKOQ0u3ZbZzZy+HLRmv1dhztmm/WYA93G9UMRJ
# mwdBR5FlctcTcYxiV3EharT3n1YdpmGYL8hprFxwzOCb9fcYKD8TJAYWQA4j4OXA
# ILBUuIOFeRWwykWFf+ea/iecxvEsA/Ua6jBzQYQuEZgjf77AHIw5EjAhi7YTLyCN
# 9blpDDRt/L4mVSHuHiz6KKbwJhOtTL8M9PsZNkVTPbDEIFNN
# SIG # End signature block
