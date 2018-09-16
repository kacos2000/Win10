#Requires -RunAsAdministrator

# Show a Select Folder Dialog and return the folder selected by the user
Function Get-Folder($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.rootfolder = "MyComputer"
	$foldername.Description = "Select a directory to scan files for ObjectIDs"
	$foldername.ShowNewFolderButton = $false
	
    if($foldername.ShowDialog() -eq "OK")
		{
        $folder += $foldername.SelectedPath
		 }
	        else  
        {
            Write-Host "(ObjectID.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
			exit
        }
    return $Folder

	}

$Folder = Get-Folder
Write-Host "(ObjectID.ps1):" -f Yellow -nonewline; write-host " Selected directory: ($Folder)" -f White

#Enumerate the files in the selected folder ( if -recurse below, recursively)
$Files = Get-ChildItem -Path $Folder -recurse -ErrorAction Ignore
$fcount = $Files.Count
$i=$null

			  
#Create output:
$results = ForEach  ($File in $Files) {$i++

    $fs = @("objectid", "query" ,"$($file.FullName)")
    $ob = &fsutil $fs
    if($ob -like 'Object ID*'){$ob|ConvertFrom-String -Delimiter '\u002c' -PropertyNames 'Object ID', 'BirthVolume ID','BirthObject ID','Domain ID' }

	#Progress Report
    Write-Progress -Activity "Collecting information for File: $file" -Status "File $i of $($fCount))" -PercentComplete (($i / $fCount)*100)
	 

	[PSCustomObject]@{ 
	Path = Split-Path -literalpath $File.FullName 
	'File/Directory Name' = $File 
    'ObjectID' = if($ob -like 'Object ID*'){[GUID]$ob[0].SubString(19)}else{$ob}
    'BirthVolume ID' = if($ob -like 'Object ID*'){[GUID]$ob[1].SubString(19)}else{''}
    'BirthObject ID' = if($ob -like 'Object ID*'){[GUID]$ob[2].SubString(19)}else{''}
    'Domain ID' = if($ob -like 'Object ID*'){[GUID]$ob[3].SubString(19)}else{''}
    
	}
	
 }


#Output results 
$results|Out-GridView -PassThru -Title "Results for $($fcount) files in the selected folder: $Folder" 
[gc]::Collect()

