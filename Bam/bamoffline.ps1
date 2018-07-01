<# <!-- saved from url=(0023) https://kacos2000.github.io/WindowsTimeline/Bam/ --> 

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
 
$before = (Get-FileHash $File -Algorithm SHA1).Hash 
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

Foreach ($Sid in $Users){
    $Items = Get-Item -Path "HKLM:\Temp\ControlSet001\Services\bam\UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property

    # Enumerating User - will roll back to SID on error
    Try{
        $objSID = New-Object System.Security.Principal.SecurityIdentifier($Sid) 
        $User = $objSID.Translate( [System.Security.Principal.NTAccount]) 
        $User = $User.Value
    }
    Catch{$User=""}

    Foreach ($Item in $Items){
        $Key = Get-ItemProperty -Path "HKLM:\Temp\ControlSet001\Services\bam\UserSettings\$Sid" | Select-Object -ExpandProperty $Item
        
        If($key.length -eq 24){
            $Hex=[System.BitConverter]::ToString($key[7..0]) -replace "-",""
            $TimeLocal = Get-Date ([DateTime]::FromFileTime([Convert]::ToInt64($Hex, 16))) -Format o

            # Setting up object for nicest output format
            $Line = "" | Select 'Last Execution Time', Application, User, Sid
            $Line.'Last Execution Time' = $TimeLocal
            $Line.Application = $Item
            $Line.User = $User
            $Line.Sid = $Sid
            $Output += $Line
        }
    }
}

$Output |Out-GridView -PassThru -Title "($File) BAM Contents"

[gc]::Collect()		
reg unload HKEY_LOCAL_MACHINE\Temp 
$after = (Get-FileHash $File -Algorithm SHA1).Hash 
write-host "Hash of ($File) after access = ($after)" -ForegroundColor Magenta
$result = (compare-object -ReferenceObject $before -DifferenceObject $after -IncludeEqual).SideIndicator 
write-host "The before and after Hashes of ($File) are ($result) `n `n" -ForegroundColor White































