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
$results = ForEach ($File in $Files)
{
	[PSCustomObject]@{ 
	Filename = $File.FullName 
	Owner = (Get-Acl $file.FullName).owner
	Attributes = $File| Select length, lastwritetime, attributes
	Stream = (Get-Item $File.FullName -Stream *).stream |Out-String 
	StreamContents = Get-Content -Stream Zone.Identifier $File.FullName -ErrorAction "Ignore" |Out-String 
    }
	
 }
#Format of the CSV filename and path:
$filenameFormat = $env:userprofile + "\desktop\streams" + " "  + (Get-Date -Format "dd-MM-yyyy hh-mm") + ".csv"

#Output results to screen table (and saves selected rows to CSV) - save needs work
$results|Out-GridView -PassThru -Title "File Zone.Identifier Stream Contents" 

# |Export-Csv -Path $filenameFormat -NoTypeInformation -Encoding Unicode


