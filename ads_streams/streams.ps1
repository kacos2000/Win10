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
	$foldername.Description = "Select a directory to scan files for Alternate Data Streams"
	$foldername.ShowNewFolderButton = $false
	
    if($foldername.ShowDialog() -eq "OK")
		{
        $folder += $foldername.SelectedPath
		 }
	        else  
        {
            Write-Host "(Streams.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}

$Folder = Get-Folder
Write-Host "(Streams.ps1):" -f Yellow -nonewline; write-host " Selected directory: ($Folder)" -f White

#Enumerate the files in the selected folder ( if -recurse below, recursively)
$Files = Get-ChildItem -Path $Folder -recurse -ErrorAction Ignore
$1=1

			  
#Display the following results for each file in the Directory:
$results = ForEach ($File in $Files) {$i++

	# Check that Alternate Data Streams exist, and if so split the output up to 5 variables
	try{$Stream = (Get-Item -literalpath $File.FullName -Stream *).stream|out-string|ConvertFrom-String -PropertyNames St1, St2, St3, Stl4, Stl5}
		Catch{$Stream = ""}
	
	# Check that Zone.Identifier exists, and if so split the output up to 5 variables
	try{$Zone = Get-Content -Stream Zone.Identifier -literalpath $File.FullName -ErrorAction Ignore|out-string|ConvertFrom-String -PropertyNames Z1, Z2, Z3, Z4, Z5}
		Catch{$Zone = ""}

	# Check the Hash function: if a directory or file is in use, the hash will be left blank
	try{$hashMD5 = (Get-FileHash -literalpath $File.FullName -Algorithm MD5 -ErrorAction Ignore).Hash}catch{$hash=""}
	
	#Progress Report
	Write-Progress -Activity "Collecting information for File: $file" -Status "File $i of $($Files.Count))" -PercentComplete (($i / $Files.Count) * 100)  

	[PSCustomObject]@{ 
	Path = Split-Path -literalpath $File.FullName 
	'File/Directory Name' = $File 
	'MD5 Hash (File Hash only)' = $hashMD5
	'Owner (name/sid)' = (Get-Acl -literalpath $file.FullName).owner
	Length = (Get-ChildItem -literalpath $File.FullName -force).length
	LastAccessTime = (Get-ItemProperty -literalpath $File.FullName).lastaccesstime
	LastWriteTime = (Get-ItemProperty -literalpath $File.FullName).lastwritetime
	Attributes = (Get-ItemProperty -literalpath $File.FullName).Mode
	Stream1 = $Stream.St1
	Stream2 = $Stream.St2
	Stream3 = $Stream.St3
	Stream4 = $Stream.St4
	ZoneId1 = $Zone.Z2
	ZoneId2 = $Zone.Z3
	ZoneId3 = $Zone.Z4
	ZoneId4 = $Zone.Z5
	}
	
 }

#Format of the txt filename and path:
$filenameFormat = $env:userprofile + "\desktop\streams" + " "  + (Get-Date -Format "dd-MM-yyyy hh-mm") + ".txt"

#Output results to screen table (and saves selected rows to txt) 
$results|Out-GridView -PassThru -Title "File Zone.Identifier Stream contents files in folder $Folder" |Out-File -FilePath $filenameFormat -Encoding Unicode
[gc]::Collect()

