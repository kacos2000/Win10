# Use "fsutil file layout 'filename&path'" to confirm

# List attribute types:
# [System.Enum]::GetNames([System.IO.FileAttributes])
# Attributes:
# ReadOnly
# Hidden
# System
# Directory
# Archive
# Device
# Normal
# Temporary
# SparseFile
# ReparsePoint
# Compressed
# Offline
# NotContentIndexed
# Encrypted
# IntegrityStream
# NoScrubData

# This script checks for files that are links (e.g. HardLink, Junction point)

# Show an Open File Dialog and return the file selected by the user
Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.SelectedPath = [Environment]::GetFolderPath("Desktop")
	$foldername.Description = "Select the folder to search for Reparse Points"
	$foldername.ShowNewFolderButton = $false
	
    if($foldername.ShowDialog() -eq "OK")
		{
        $folder += $foldername.SelectedPath
		 }
	        else  
        {
            Write-Host "(FindLinks.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}
$F = Get-Folder
Write-host "Selected Folder: $F" -f white

# Search the system path (Env:Path) directories for the existence for SQLite3.exe 


$out = foreach ($item in $F)
    {

        Get-ChildItem -Path $item -recurse -force -ErrorAction SilentlyContinue| Where-Object {$_.LinkType -ne $null}|Select-Object -Property FullName, PSIsContainer, LinkType, Target, Attributes, LastWriteTime 
  
    }

$out|Out-GridView -PassThru -Title "Files with link attributes in $F and subfolders"



