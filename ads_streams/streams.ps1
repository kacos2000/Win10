# ref: https://blogs.technet.microsoft.com/askcore/2013/03/24/alternate-data-streams-in-ntfs/
#
#
#
# Show a Select Folder Dialog and return the folder selected by the user
Function Get-Folder($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.rootfolder = "MyComputer"
    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

$Folder = Get-Folder

#Enumerate the files in the selected folder ( if -recurse below, recursively)
$Files = Get-ChildItem -Path $Folder -recurse -ErrorAction Ignore


			  
#Display the following results for each file in the Directory:
$results = ForEach ($File in $Files) {

	# Check that Alternate Data Streams exist, and if so split the output up to 5 variables
	try{$Stream = (Get-Item $File.FullName -Stream *).stream|out-string|ConvertFrom-String -PropertyNames St1, St2, St3, Stl4, Stl5}
		Catch{$Stream = ""}
	
	# Check that Zone.Identifier exists, and if so split the output up to 5 variables
	try{$Zone = Get-Content -Stream Zone.Identifier $File.FullName -ErrorAction Ignore|out-string|ConvertFrom-String -PropertyNames Z1, Z2, Z3, Z4, Z5}
		Catch{$Zone = ""}

	# Check the Hash function: if a directory or file is in use, the hash will be left blank
	try{$hash = (Get-FileHash $File.FullName -Algorithm MD5 -ErrorAction Ignore).Hash}catch{$hash=""} 	
	
	[PSCustomObject]@{ 
	Path = Split-Path -Path $File.FullName 
	'File/Directory Name' = $File 
	'MD5 Hash (File Hash only)' = $hash
	'Owner / sid' = (Get-Acl $file.FullName).owner
	Length = (Get-ItemProperty $File.FullName).length
	LastWriteTime = (Get-ItemProperty $File.FullName).lastwritetime
	Attributes = (Get-ItemProperty $File.FullName).Mode
	Stream1 = $Stream.St1
	Stream2 = $Stream.St2
	Stream3 = $Stream.St3
	ZoneId1 = $Zone.Z2
	ZoneId2 = $Zone.Z3
	ZoneId3 = $Zone.Z4
	ZoneId4 = $Zone.Z5
	}
	
 }

#Format of the txt filename and path:
$filenameFormat = $env:userprofile + "\desktop\streams" + " "  + (Get-Date -Format "dd-MM-yyyy hh-mm") + ".txt"

#Output results to screen table (and saves selected rows to txt) 
$results|Out-GridView -PassThru -Title "File Zone.Identifier Stream Contents" |Out-File -FilePath $filenameFormat -Encoding Unicode
[gc]::Collect()

