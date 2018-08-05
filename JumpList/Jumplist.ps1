#Requires -RunAsAdministrator
$Key = $null

function Results{
$Key.PSObject.Properties| ForEach-Object {
				if($_.Name -notmatch 'PSChildname|PSDrive|PSParentPath|PSPath|PSProvider'){
				[PSCustomObject]@{ 
				Application = $_.Name
				Local_Time = if($_.Value -match '\d{18}'){Get-Date ([DateTime]::FromFileTime($_.Value)) -Format o}
				
				}}
			} |Out-GridView -PassThru -Title "$Title"
Exit            
}#End Results

Function Offline {
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
$OpenFileDialog.ShowHelp = $false
} #end function Get-FileName 
$DesktopPath = [Environment]::GetFolderPath("Desktop")


$File = Get-FileName -initialDirectory $DesktopPath

Try{$before = (Get-FileHash $File -Algorithm SHA256).Hash}
Catch{
        Write-Host "(Jumplist.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
		exit
} 
write-host "SHA256 Hash of ($File) before access = " -f magenta -nonewline;write-host "($before)" -f Yellow

$Title = "Windows 10 Search Jumplist Data from '$File'"

reg load HKEY_LOCAL_MACHINE\Temp $File
$ErrorActionPreference = "Stop"

try{$Key = Get-ItemProperty -Path "HKLM:\Temp\Software\Microsoft\Windows\CurrentVersion\Search\JumplistData"
Write-Host -ForegroundColor Green "File loaded OK"}
Catch{
	Write-Warning "The selected ($File) does not have the 'Software\Microsoft\Windows\CurrentVersion\Search\JumplistData' key." 
	[gc]::Collect()		
	reg unload HKEY_LOCAL_MACHINE\Temp 
    exit}
finally{
    }

Results
EndOffline
} #End Function offline


#Local Function (current user)
Function Local {
$Title = "Windows 10 Search Jumplist Data from 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\JumplistData'"
try{$Key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\JumplistData"
Write-Host -ForegroundColor Green "HKCU loaded OK"}
Catch{
	Write-Warning "Current user does not have the Software\Microsoft\Windows\CurrentVersion\Search\JumplistData' registry key." 
	[gc]::Collect()		
    exit}

Results
}#End Local Function


#ask user for choice
$Title = "Jumplist.ps1"
$Info = "Selection Option to continue:"
 
$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Local", "&Offline", "E&xit")
[int]$defaultchoice = 0
$opt = $host.UI.PromptForChoice($Title , $Info , $Options,$defaultchoice)
switch($opt)
{
0 { Local; Write-Host "Current User" -ForegroundColor Green}
1 { Offline; Write-Host $File -ForegroundColor Green }
2 { Exit; Write-Host "bye bye - Nice to see you :)" -ForegroundColor Green}
}


function EndOffline {
reg unload HKEY_LOCAL_MACHINE\Temp 
$after = (Get-FileHash $File -Algorithm SHA256).Hash 
write-host "SHA256 Hash of ($File) before access = " -f magenta -nonewline;write-host "($before)" -f Yellow
$result = (compare-object -ReferenceObject $before -DifferenceObject $after -IncludeEqual).SideIndicator 
write-host "The before and after Hashes of ($File) are ($result) `n `n" -ForegroundColor White
}

[gc]::Collect()		


 






























