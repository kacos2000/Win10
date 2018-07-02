# Show an Open File Dialog and return the file selected by the user
Function Get-FileName($initialDirectory)

{  
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
Out-Null
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Title = 'Select NTUSER.dat file to open (the file will be accessed Read Only)'
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.Filter = "NTuser.dat (*.dat)|NTuser.dat"
$OpenFileDialog.ShowDialog() | Out-Null
$OpenFileDialog.ReadOnlyChecked = $true
$OpenFileDialog.filename
$OpenFileDialog.ShowHelp = $true
} #end function Get-FileName 
$DesktopPath = [Environment]::GetFolderPath("Desktop")

#  Note: OpenFile will always open the file in read-only mode.
#  https://technet.microsoft.com/en-us/library/system.windows.forms.openfiledialog.openfile(v=vs.100)


$File = Get-FileName -initialDirectory $DesktopPath
 
$before = (Get-FileHash $File -Algorithm SHA256).Hash 
write-host "Hash of ($File) before access = ($before)" -ForegroundColor Magenta

reg load HKEY_LOCAL_MACHINE\Temp $File
$ErrorActionPreference = "Stop"

try{$Key = (Get-ItemProperty -Path "HKLM:\Temp\Software\Microsoft\Windows\CurrentVersion\Search\JumplistData")
Write-Host -ForegroundColor Green "File loaded OK"}
Catch{
	Write-Host -ForegroundColor Yellow "The selectd ($File) does not have the" 
	Write-Host -ForegroundColor Yellow "'Software\Microsoft\Windows\CurrentVersion\Search\JumplistData' registry key." 
	Write-Host -ForegroundColor Red $Error[0].Exception.GetType() 
	[gc]::Collect()		
	reg unload HKEY_LOCAL_MACHINE\Temp 
    exit}
finally{
    Write-Host -ForegroundColor DarkYellow "_._"
}


$Key.PSObject.Properties| ForEach-Object {
				if($_.Name -notmatch 'PSChildname|PSDrive|PSParentPath|PSPath|PSProvider'){
				[PSCustomObject]@{ 
				Application = $_.Name
				Local_Time = if($_.Value -match '\d{18}'){Get-Date ([DateTime]::FromFileTime($_.Value)) -Format o}
				}}
			} |Out-GridView -PassThru -Title "Windows 10 Search Jumplist Data"
	[gc]::Collect()		
reg unload HKEY_LOCAL_MACHINE\Temp 
$after = (Get-FileHash $File -Algorithm SHA256).Hash 
write-host "Hash of ($File) after access = ($after)" -ForegroundColor Magenta
$result = (compare-object -ReferenceObject $before -DifferenceObject $after -IncludeEqual).SideIndicator 
write-host "The before and after Hashes of ($File) are ($result) `n `n" -ForegroundColor White
 






























