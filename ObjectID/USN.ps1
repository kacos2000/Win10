#Requires -RunAsAdministrator

# Prompt user to select one of the available drive letters
$drives = gwmi Win32_LogicalDisk|select-object -property DeviceID
$drive = $drives|Out-GridView  -OutputMode Single -Title 'Please select a drive letter'  
$drive=$drive.deviceID 
Write-Host "(USN.ps1):" -f Yellow -nonewline; write-host " Selected drive: $($drive)" -f White

#Format of the csv filename and path:
$filenameFormat = $env:userprofile + "\desktop\usn_"  + (Get-Date -Format "dd-MM-yyyy hh-mm") + ".csv"
Write-host "Selected rows will be saved as: "-f Yellow -nonewline; Write-Host $filenameFormat -f White
			  
#Create output:
$fs = @("usn", "readjournal" ,"$($drive)", "csv")
&fsutil $fs |Out-File -FilePath $filenameFormat -Encoding Unicode -Append
