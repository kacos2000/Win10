#Requires -RunAsAdministrator
<#
.Original Script source 
	https://github.com/mgreen27/Powershell-IR/blob/master/Content/Other/BAMParser.ps1
#>
[gc]::Collect()	

# Show an Open File Dialog and return the file selected by the user
Function Get-FileName($initialDirectory)
{  
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |Out-Null
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Title = 'Select SYSTEM hive file to open (the file will be accessed Read Only)'
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.Filter = "SYSTEM (*.*)|SYSTEM"
$OpenFileDialog.ShowDialog() | Out-Null
$OpenFileDialog.ShowReadOnly = $true
$OpenFileDialog.filename
$OpenFileDialog.ShowHelp = $false
} #end function Get-FileName 

$DesktopPath = [Environment]::GetFolderPath("Desktop")

#  Note: OpenFile will always open the file in read-only mode.
#  https://technet.microsoft.com/en-us/library/system.windows.forms.openfiledialog.openfile(v=vs.100)

$File = Get-FileName -initialDirectory $DesktopPath
 
Try{$before = (Get-FileHash $File -Algorithm SHA256).Hash}
Catch{Write-Host "(BamOffline1.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White; exit}
write-host "SHA256 Hash of ($File) before access = " -f magenta -nonewline;write-host "($before)" -f Yellow


reg load HKEY_LOCAL_MACHINE\Temp $File

$Users=$null


# MAIN
if (!(Get-PSDrive -Name HKLM -PSProvider Registry)){
    Try{New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE}
    Catch{"Error Mounting HKEY_Local_Machine"}
}

Try{$Users = Get-ChildItem -Path "HKLM:\Temp\ControlSet001\Services\bam\UserSettings\" -ErrorAction Stop| Select-Object -ExpandProperty PSChildName}
Catch{
    "Error Parsing BAM Key. Likely unsupported Windows Version"
	[gc]::Collect()		
	reg unload HKEY_LOCAL_MACHINE\Temp 
    exit
}

$UserTime = (Get-ItemProperty -Path "HKLM:\Temp\ControlSet001\Control\TimeZoneInformation").TimeZoneKeyName
$UserBias = (Get-ItemProperty -Path "HKLM:\Temp\ControlSet001\Control\TimeZoneInformation").ActiveTimeBias
$UserDay = (Get-ItemProperty -Path "HKLM:\Temp\ControlSet001\Control\TimeZoneInformation").DaylightBias
$1=1

$result = Foreach ($Sid in $Users){$i++
    $Items = Get-Item -Path "HKLM:\Temp\ControlSet001\Services\bam\UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property

    # Enumerating User - will roll back to SID on error
    Try{
        $objSID = New-Object System.Security.Principal.SecurityIdentifier($Sid) 
        $User = $objSID.Translate( [System.Security.Principal.NTAccount]) 
        $User = $User.Value
    }
    Catch{$User=""}
	Write-Progress -Activity "Collecting BAM entries for each User (sid)" -Status "Entry $i of $($Users.Count))" -PercentComplete (($i / $Users.Count)*100)
    ForEach ($Item in $Items){
		$Key = Get-ItemProperty -Path "HKLM:\Temp\ControlSet001\Services\bam\UserSettings\$Sid" | Select-Object -ExpandProperty $Item
        
		
        If($key.length -eq 24){
            $Hex=[System.BitConverter]::ToString($key[7..0]) -replace "-",""
            $TimeLocal = Get-Date ([DateTime]::FromFileTime([Convert]::ToInt64($Hex, 16))) -Format o
			$TimeUTC = Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))) -Format u
			$Bias = -([convert]::ToInt32([Convert]::ToString($UserBias,2),2))
			$Day = -([convert]::ToInt32([Convert]::ToString($UserDay,2),2))
			$TImeUser = (Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))).addminutes($Bias) -Format s) 
			$d = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			{((split-path -path $item).Remove(23)).trimstart("\Device\HarddiskVolume")} else {$d = ""}
			$f = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			{Split-path -leaf ($item).TrimStart()} else {$item}	
			$cp = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			{($item).Remove(1,23)} else {$cp = ""}
			$path = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			{"(Vol"+$d+") "+$cp} else {$path = ""}			
			
            [PSCustomObject]@{
                        'Examiner Time' = $TimeLocal
						'Last Execution Time (UTC)'= $TimeUTC
						'Last Execution User Time' = $TimeUser
						 Application = 	$f
						 Path =  		$path
						 User = $User
						 Sid = $Sid
						 }
		        }
   }
}

# Output to Window
$result |Out-GridView -PassThru -Title "BAM key entries of ($File) - User TimeZone: ($UserTime) -> ActiveBias: ( $Bias) - DayLightTime: ($Day)"

[gc]::Collect()		
reg unload HKEY_LOCAL_MACHINE\Temp 
$after = (Get-FileHash $File -Algorithm SHA256).Hash 
write-host "SHA256 Hash of ($File) after access = " -f magenta -nonewline;write-host "($after)" -f Yellow
$result = (compare-object -ReferenceObject $before -DifferenceObject $after -IncludeEqual).SideIndicator 
write-host "The before and after SHA256 Hashes of ($File) are ($result) `n `n" -ForegroundColor White




























