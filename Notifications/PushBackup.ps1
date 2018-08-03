#Requires -RunAsAdministrator

# Show an Open File Dialog and return the file selected by the user
Function Get-FileName($initialDirectory)

{  
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |Out-Null
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Title = 'Select NTUser.dat  file to open'
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.Filter = "NTUser.dat (*.dat)|NTUser.dat"
$OpenFileDialog.ShowDialog()| Out-Null   
$OpenFileDialog.ReadOnlyChecked = $true
$OpenFileDialog.filename
$OpenFileDialog.ShowHelp = $false
} #end function Get-FileName 
$DesktopPath = [Environment]::GetFolderPath("Desktop")


$File = Get-FileName -initialDirectory $DesktopPath

Try{$before = (Get-FileHash $File -Algorithm SHA256).Hash}
Catch{
        Write-Host "(PushBackup.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
		exit
}
write-host "SHA256 Hash of ($File) before access = " -f magenta -nonewline;write-host "($before)" -f Yellow
reg load HKEY_LOCAL_MACHINE\Temp $File

# MAIN
if (!(Get-PSDrive -Name HKLM -PSProvider Registry)){
    Try{New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE}
    Catch{"Error Mounting HKEY_Local_Machine"}
}


Try{$wpnidm = @(Get-ChildItem -Path "HKLM:\Temp\Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup" -ErrorAction Stop| Select-Object -ExpandProperty PSChildName)}
Catch{
    "Error Parsing InventoryApplicationFile Key. Likely unsupported Windows Version"
	[gc]::Collect()		
	reg unload HKEY_LOCAL_MACHINE\Temp 
    exit
}


$i=0
$ipath = ((Get-childItem -Path "HKLM:\Temp\Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup").pspath)
$count = $ipath.count  
    
  
$result =  ForEach ($item in $ipath){$i++
	        Write-Progress -Activity "Collecting $File entries" -Status "Entry $i of $($count))" -PercentComplete (($i / $count)*100)
	        
            $Creation = (get-itemproperty $item -ea 0).ChannelCreation 
            $Expiry = (get-itemproperty $item -ea 0).ChannelExpiry 
            $CID = if(((get-itemproperty $item -ea 0).ChannelId) -ne $null) {[Text.Encoding]::Unicode.GetBytes((get-itemproperty $item -ea 0).ChannelId)} else {$null}
            $ChannelID =if($CID -ne $null){(([System.BitConverter]::ToString($CID, 0).Replace("-", " ")) -split ' '|ForEach-Object {[char][byte]"0x$_"}) -join ''}else{$null}
            $Uri = if(((get-itemproperty $item -ea 0).ChannelUri) -ne $null) {[Text.Encoding]::Unicode.GetBytes((get-itemproperty $item -ea 0).ChannelUri)} else {$null}
            $channelUri = if($Uri -ne $null){(([System.BitConverter]::ToString($Uri, 0).Replace("-", " ")) -split ' '|ForEach-Object {[char][byte]"0x$_"}) -join ''}else{$null}
                 
            [PSCustomObject]@{
            Application = (get-itemproperty $item -ea 0).pschildname
            AppType = (get-itemproperty $item -ea 0).AppType 
            WnsID = (get-itemproperty $item -ea 0).WnsID 
            WNSEventName = (get-itemproperty $item -ea 0).WNSEventName 
            ChannelId = $ChannelID
            channelUri = $channelUri
            ChannelExpiry = if ($Expiry -ne $null){Get-Date ([DateTime]::FromFileTime($Expiry)) -Format o} else{$null}
            ChannelCreation = if ($Creation -ne $null){Get-Date ([DateTime]::FromFileTime($Creation)) -Format o} else{$null}
            Setting = (get-itemproperty $item -ea 0).Setting 
						}
			}		 	



# output to Window
$result |Out-GridView -PassThru -Title "$count NTUser.dat PushNotifications backup entries in ($file)"

[gc]::Collect()		
reg unload HKEY_LOCAL_MACHINE\Temp  

$after = (Get-FileHash $File -Algorithm SHA256).Hash 
write-host "SHA256 Hash of ($File) after access = " -f magenta -nonewline;write-host "($after)" -f Yellow
$result = (compare-object -ReferenceObject $before -DifferenceObject $after -IncludeEqual).SideIndicator 
write-host "The before and after SHA256 Hashes of ($File) are ($result) `n `n" -ForegroundColor White 