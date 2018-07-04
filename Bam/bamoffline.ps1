<#

.Original Script source 
	https://github.com/mgreen27/Powershell-IR/blob/master/Content/Other/BAMParser.ps1
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $False)][Switch]$SortSid=$Null
)

# Show an Open File Dialog and return the file selected by the user
Function Get-FileName($initialDirectory)

{  
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
Out-Null
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Title = 'Select SYSTEM hive file to open (the file will be accessed Read Only)'
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.Filter = "SYSTEM (*.*)|SYSTEM"
$OpenFileDialog.ShowDialog() | Out-Null
$OpenFileDialog.ReadOnlyChecked = $true
$OpenFileDialog.filename
$OpenFileDialog.ShowHelp = $true
} #end function Get-FileName 

$DesktopPath = [Environment]::GetFolderPath("Desktop")
$File = Get-FileName -initialDirectory $DesktopPath
 
$before = (Get-FileHash $File -Algorithm SHA256).Hash 
write-host "Hash of ($File) before access = ($before)" -ForegroundColor Magenta


reg load HKEY_LOCAL_MACHINE\Temp $File


$Output=@()
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


$result = Foreach ($Sid in $Users){
    $Items = Get-Item -Path "HKLM:\Temp\ControlSet001\Services\bam\UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property

    # Enumerating User - will roll back to SID on error
    Try{
        $objSID = New-Object System.Security.Principal.SecurityIdentifier($Sid) 
        $User = $objSID.Translate( [System.Security.Principal.NTAccount]) 
        $User = $User.Value
    }
    Catch{$User=""}

    ForEach ($Item in $Items){
		$Key = Get-ItemProperty -Path "HKLM:\Temp\ControlSet001\Services\bam\UserSettings\$Sid" | Select-Object -ExpandProperty $Item
        
		
        If($key.length -eq 24){
            $Hex=[System.BitConverter]::ToString($key[7..0]) -replace "-",""
            $TimeLocal = Get-Date ([DateTime]::FromFileTime([Convert]::ToInt64($Hex, 16))) -Format o
			$TimeUTC = Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))) -Format u
			$Bias = ([convert]::ToInt32([Convert]::ToString($UserBias,2),2))
			$Day = ([convert]::ToInt32([Convert]::ToString($UserDay,2),2))
			$TImeUser = (Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))).addminutes(-$Bias) -Format s )
			
            [PSCustomObject]@{
                        'Last Execution Time (UTC)'= $TimeUTC
						'User Timezone' = $UserTime
						'ActiveBias' = -$Bias
						'Daylight'= -$Day
						'User Time' = $TImeUser
						Application = $Item
						User = $User
						Sid = $Sid
						}
					 	
		        }
				
   }
   
}

# Output to Window
$result |Out-GridView -PassThru -Title "BAM key entries of ($File)"

[gc]::Collect()		
reg unload HKEY_LOCAL_MACHINE\Temp 
$after = (Get-FileHash $File -Algorithm SHA256).Hash 
write-host "Hash of ($File) after access = ($after)" -ForegroundColor Magenta
$result = (compare-object -ReferenceObject $before -DifferenceObject $after -IncludeEqual).SideIndicator 
write-host "The before and after Hashes of ($File) are ($result) `n `n" -ForegroundColor White































