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
$Files = Get-ChildItem -Path $Folder -recurse


			  
#Display the following results for each file in the Directory:
$results = ForEach ($File in $Files) {

	try{$Stream = (Get-Item $File.FullName -Stream *).stream|out-string}
		Catch{$Stream = ""|out-string}
	try{$Zone = Get-Content -Stream Zone.Identifier $File.FullName -ErrorAction "Ignore" |Out-String}
		Catch{$Zone =""|out-string}
	 
		
	
	[PSCustomObject]@{ 
	Filename = $File.FullName 
	Owner = (Get-Acl $file.FullName).owner
	Length = (Get-ItemProperty $File.FullName).length
	LastWriteTime = (Get-ItemProperty $File.FullName).lastwritetime
	Attributes = (Get-ItemProperty $File.FullName).Mode
	Stream = $Stream
	ZoneIdContents = $Zone
	}
	
 }

#Format of the txt filename and path:
$filenameFormat = $env:userprofile + "\desktop\streams" + " "  + (Get-Date -Format "dd-MM-yyyy hh-mm") + ".txt"

#Output results to screen table (and saves selected rows to txt) 
$results|Out-GridView -PassThru -Title "File Zone.Identifier Stream Contents" |Out-File -FilePath $filenameFormat -Encoding Unicode
[gc]::Collect()

