#Requires -RunAsAdministrator

# Show an Open File Dialog and return the file selected by the user
Function Get-FileName($initialDirectory)

{  
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |Out-Null
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Title = 'Select SYSTEM hive file to open (the file will be accessed Read Only)'
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.Filter = "AmCache.hve (*.hve)|AmCache.hve"
$OpenFileDialog.ShowDialog()| Out-Null   
$OpenFileDialog.ReadOnlyChecked = $true
$OpenFileDialog.filename
$OpenFileDialog.ShowHelp = $false
} #end function Get-FileName 
$DesktopPath = [Environment]::GetFolderPath("Desktop")


$File = Get-FileName -initialDirectory $DesktopPath

Try{$before = (Get-FileHash $File -Algorithm SHA256).Hash}
Catch{
        Write-Host "(AmCache.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
		exit
}
write-host "SHA256 Hash of ($File) before access = " -f magenta -nonewline;write-host "($before)" -f Yellow
reg load HKEY_LOCAL_MACHINE\Temp $File

# MAIN
if (!(Get-PSDrive -Name HKLM -PSProvider Registry)){
    Try{New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE}
    Catch{"Error Mounting HKEY_Local_Machine"}
}


Try{$Apps = @(Get-ChildItem -Path "HKLM:\Temp\Root\InventoryApplicationFile" -ErrorAction Stop| Select-Object -ExpandProperty PSChildName)}
Catch{
    "Error Parsing InventoryApplicationFile Key. Likely unsupported Windows Version"
	[gc]::Collect()		
	reg unload HKEY_LOCAL_MACHINE\Temp 
    exit
}

$UserTime = (Get-ItemProperty -Path "HKLM:\Temp\Root\DeviceCensus\OS").DeviceTimeZone
$UserBias = (Get-ItemProperty -Path "HKLM:\Temp\Root\DeviceCensus\OS").OSTimeZoneBiasInMins
$hex = [System.BitConverter]::ToString($UserBias[7..0]) -replace "-",""
$Bias = ([Convert]::ToInt64($hex,16))/60
$i=0
$ipath = ((Get-childItem -Path "hklm:/temp/Root/InventoryApplicationFile/").pspath)
$count = $ipath.count  
    
  
$result =  ForEach ($item in $ipath){$i++
	Write-Progress -Activity "Collecting $File entries" -Status "Entry $i of $($count))" -PercentComplete (($i / $count)*100)
	$d = $item|get-itemproperty|Select-object -ExpandProperty LinkDate
    $p = 'MM/dd/yyyy HH:mm:ss'
    try {$dt = [datetime]::ParseExact($d,$p,$null)|Get-date -f s} catch {$dt = " "} 
    $B = $item|get-itemproperty|Select-object -ExpandProperty LongPathHash|Out-String|ConvertFrom-String -PropertyNames Name, Hash -Delimiter '\u007C'       
    
            
            [PSCustomObject]@{
            App = $B.Name
            Hash =($B.Hash).substring(0,16)
            BinaryType = $item|get-itemproperty|Select-object -ExpandProperty BinaryType
            BinFileVersion = $item|get-itemproperty|Select-object -ExpandProperty BinFileVersion
            BinProductVersion = $item|get-itemproperty|Select-object -ExpandProperty BinProductVersion
            FileId =$item|get-itemproperty|Select-object -ExpandProperty FileId
            IsPeFile = $item|get-itemproperty|Select-object -ExpandProperty IsPeFile
            IsOsComponent =$item|get-itemproperty|Select-object -ExpandProperty IsOsComponent
            LowerCaseLongPath = $item|get-itemproperty|Select-object -ExpandProperty LowerCaseLongPath
            Name = $item|get-itemproperty|Select-object -ExpandProperty Name
            Version = $item|get-itemproperty|Select-object -ExpandProperty Version
            ProductName = $item|get-itemproperty|Select-object -ExpandProperty ProductName
            ProductVersion = $item|get-itemproperty|Select-object -ExpandProperty ProductVersion
            ProgramId =$item|get-itemproperty|Select-object -ExpandProperty ProgramId
            Publisher = $item|get-itemproperty|Select-object -ExpandProperty Publisher
            Language = $item|get-itemproperty|Select-object -ExpandProperty Language
            LinkDate = $dt
            Size = $item|get-itemproperty|Select-object -ExpandProperty Size
			TZ_ActiveBias = $Bias
						}
			}		 	

# output to Window
$result |Out-GridView -PassThru -Title "$count AmCache.hve InventoryApplicationFile entries of ($file)"

[gc]::Collect()		
reg unload HKEY_LOCAL_MACHINE\Temp  

$after = (Get-FileHash $File -Algorithm SHA256).Hash 
write-host "SHA256 Hash of ($File) after access = " -f magenta -nonewline;write-host "($after)" -f Yellow
$result = (compare-object -ReferenceObject $before -DifferenceObject $after -IncludeEqual).SideIndicator 
write-host "The before and after SHA256 Hashes of ($File) are ($result) `n `n" -ForegroundColor White 