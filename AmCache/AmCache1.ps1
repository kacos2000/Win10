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
    
  
$InventoryApplicationFile =  ForEach ($item in $ipath){$i++
	Write-Progress -Activity "Collecting $File entries" -Status "Entry $i of $($count))" -PercentComplete (($i / $count)*100)
	$d = $item|get-itemproperty|Select-object -ExpandProperty LinkDate
    $p = 'MM/dd/yyyy HH:mm:ss'
    try {$dt = [datetime]::ParseExact($d,$p,$null)|Get-date -f s} catch {$dt = " "} 
    $B = $item|get-itemproperty|Select-object -ExpandProperty LongPathHash|Out-String|ConvertFrom-String -PropertyNames Name, Hash -Delimiter '\u007C'       
    
            
            [PSCustomObject]@{
            App = $B.Name
            Hash =($B.Hash).substring(0,16)
            Name = $item|get-itemproperty|Select-object -ExpandProperty Name
            PackageFullName = ""
            LowerCaseLongPath = $item|get-itemproperty|Select-object -ExpandProperty LowerCaseLongPath
            RootDirPath = ""

            FileId =$item|get-itemproperty|Select-object -ExpandProperty FileId
            IsPeFile = $item|get-itemproperty|Select-object -ExpandProperty IsPeFile
            IsOsComponent =$item|get-itemproperty|Select-object -ExpandProperty IsOsComponent
            ProgramId =$item|get-itemproperty|Select-object -ExpandProperty ProgramId
            Version = $item|get-itemproperty|Select-object -ExpandProperty Version
            ProductName = $item|get-itemproperty|Select-object -ExpandProperty ProductName
            ProductVersion = $item|get-itemproperty|Select-object -ExpandProperty ProductVersion
            Publisher = $item|get-itemproperty|Select-object -ExpandProperty Publisher
            Language = $item|get-itemproperty|Select-object -ExpandProperty Language
            LinkDate = $dt
            InstallDate = ""
            TZ_ActiveBias = $Bias
            Source = ""
			Type = ""
            InboxModernApp=""
            Size = $item|get-itemproperty|Select-object -ExpandProperty Size
            OSVersionAtInstallTime = ""
            BinaryType = $item|get-itemproperty|Select-object -ExpandProperty BinaryType
            BinFileVersion = $item|get-itemproperty|Select-object -ExpandProperty BinFileVersion
            BinProductVersion = $item|get-itemproperty|Select-object -ExpandProperty BinProductVersion
			}
			}		 	

$i1=0
$Apath = ((Get-childItem -Path "hklm:/temp/Root/InventoryApplication/").pspath)
$Acount = $Apath.count 

$InventoryApplication =  ForEach ($Aitem in $Apath){$i1++
	Write-Progress -Activity "Collecting $File entries" -Status "Entry $i1 of $($Acount))" -PercentComplete (($i1 / $Acount)*100)
	$d1 = $Aitem|get-itemproperty|Select-object -ExpandProperty InstallDate
    $p1 = 'MM/dd/yyyy HH:mm:ss'
    try {$dt1 = [datetime]::ParseExact($d1,$p1,$null)|Get-date -f s} catch {$dt1 = " "} 
    
            
            [PSCustomObject]@{
            Name = $Aitem|get-itemproperty|Select-object -ExpandProperty Name
            Source = $Aitem|get-itemproperty|Select-object -ExpandProperty Source
            Type = $Aitem|get-itemproperty|Select-object -ExpandProperty Type
            InboxModernApp =$Aitem|get-itemproperty|Select-object -ExpandProperty InboxModernApp
            RootDirPath = $Aitem|get-itemproperty|Select-object -ExpandProperty RootDirPath
            PackageFullName = $Aitem|get-itemproperty|Select-object -ExpandProperty PackageFullName
            Version = $Aitem|get-itemproperty|Select-object -ExpandProperty Version
            ProgramId =$Aitem|get-itemproperty|Select-object -ExpandProperty ProgramId
            Publisher = $Aitem|get-itemproperty|Select-object -ExpandProperty Publisher
            Language = $Aitem|get-itemproperty|Select-object -ExpandProperty Language
            InstallDate = $dt1
            OSVersionAtInstallTime = ($Aitem|get-itemproperty|Select-object -ExpandProperty OSVersionAtInstallTime).trim()
            TZ_ActiveBias = $Bias
						}
			}		 	
function Result{
$InventoryApplicationFile 
$InventoryApplication 
}


# output to Window
Result |Out-GridView -PassThru -Title "$count InventoryApplicationFile & $Acount InventoryApplication entries of ($file)"

[gc]::Collect()		
reg unload HKEY_LOCAL_MACHINE\Temp  

$after = (Get-FileHash $File -Algorithm SHA256).Hash 
write-host "SHA256 Hash of ($File) after access = " -f magenta -nonewline;write-host "($after)" -f Yellow
$result = (compare-object -ReferenceObject $before -DifferenceObject $after -IncludeEqual).SideIndicator 
write-host "The before and after SHA256 Hashes of ($File) are ($result) `n `n" -ForegroundColor White 