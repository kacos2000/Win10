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
        Write-Host "(wpn.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
		exit
}
write-host "SHA256 Hash of ($File) before access = " -f magenta -nonewline;write-host "($before)" -f Yellow
reg load HKEY_LOCAL_MACHINE\Temp $File

# MAIN
if (!(Get-PSDrive -Name HKLM -PSProvider Registry)){
    Try{New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE}
    Catch{"Error Mounting HKEY_Local_Machine"}
}


Try{$wpnidm = @(Get-ChildItem -Path "HKLM:\Temp\Software\Microsoft\Windows\CurrentVersion\PushNotifications\wpnidm" -ErrorAction Stop| Select-Object -ExpandProperty PSChildName)}
Catch{
    "Error Parsing InventoryApplicationFile Key. Likely unsupported Windows Version"
	[gc]::Collect()		
	reg unload HKEY_LOCAL_MACHINE\Temp 
    exit
}

$ImagePath = (Get-ItemProperty -Path "HKLM:\Temp\Software\Microsoft\Windows\CurrentVersion\PushNotifications\wpnidm").path
write-host "Notification Images (Path)  " -f red -nonewline;write-host "$ImagePath" -f Yellow

$i=0
$ipath = ((Get-childItem -Path "HKLM:\Temp\Software\Microsoft\Windows\CurrentVersion\PushNotifications\wpnidm").pspath)
$count = $ipath.count  
    
  
$result =  ForEach ($item in $ipath){$i++
	        Write-Progress -Activity "Collecting $File entries" -Status "Entry $i of $($count))" -PercentComplete (($i / $count)*100)
	        
            $Expiration = (get-itemproperty $item -ea 0).Expiration
            $Int64Value = [System.BitConverter]::ToInt64($Expiration, 0)
            $date = [DateTime]::FromFileTime($Int64Value) 
            $Notifications = (get-itemproperty $item -ea 0).Notifications
            $NotInt64 = [System.BitConverter]::ToInt64($Notifications, 0)
                       
            [PSCustomObject]@{
            Filename = (get-itemproperty $item -ea 0).pschildname
            Extension = (get-itemproperty $item -ea 0).FileExtension
            FileSize = (get-itemproperty $item -ea 0).FileSize
            Flag = (get-itemproperty $item -ea 0).Flag
            'Full Path and Filename' = (get-itemproperty $item -ea 0).LocalPath
            Application = (get-itemproperty $item -ea 0).Aumid
            Expiration = Get-Date $date -f o
            Count = (get-itemproperty $item -ea 0).NotificationsCount
            NotificationID = $NotInt64

						}
			}		 	



# output to Window
$result |Out-GridView -PassThru -Title "Image-Path =$ImagePath -$count NTUser.dat PushNotification entries of ($file)"

[gc]::Collect()		
reg unload HKEY_LOCAL_MACHINE\Temp  

$after = (Get-FileHash $File -Algorithm SHA256).Hash 
write-host "SHA256 Hash of ($File) after access = " -f magenta -nonewline;write-host "($after)" -f Yellow
$result = (compare-object -ReferenceObject $before -DifferenceObject $after -IncludeEqual).SideIndicator 
write-host "The before and after SHA256 Hashes of ($File) are ($result) `n `n" -ForegroundColor White 