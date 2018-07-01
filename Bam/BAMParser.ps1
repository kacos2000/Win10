<#
.SYNOPSIS
    Invoke-BAMParser.ps1 parses BAM entries from SYSTEM registry hive.
    
    Name: Invoke-BAMParser.ps1
    Version: 0.1
    Author: Matt Green (@mgreen27)

.DESCRIPTION
    Background Activity Moderator (BAM) Service has been included from Windows 10 1709
    The BAM service key is an alternate evidence of execution source however in my testing I have noticed not all executables are populated.

    Invoke-BAMParser.ps1 parses BAM entries from SYSTEM registry hive and returns the data in an easy to read format.
    Currently only supported in Live Response mode (not against precollected files).
    Default output sorted by entry time in decending order but can be changed with -SortUser switch

   
.EXAMPLE
	Invoke-BAMParser.ps1

    PS C:\WINDOWS\system32> C:\tools\Invoke-BAMParser.ps1

    TimeUTC              Item                                                                                                User                   Sid                                           
    -------              ----                                                                                                ----                   ---                                           
    2018-04-15 02:17:13Z Microsoft.WindowsCalculator_8wekyb3d8bbwe                                                           DFIR\matt              S-1-5-21-204460083-2392015180-1890829323-1106 
    2018-04-15 02:16:58Z Microsoft.WindowsStore_8wekyb3d8bbwe                                                                DFIR\matt              S-1-5-21-204460083-2392015180-1890829323-1106 
    2018-04-15 02:16:57Z \Device\HarddiskVolume1\Windows\System32\ApplicationFrameHost.exe                                   DFIR\matt              S-1-5-21-204460083-2392015180-1890829323-1106 
    2018-04-15 02:13:02Z Microsoft.Windows.Cortana_cw5n1h2txyewy                                                             DFIR\matt              S-1-5-21-204460083-2392015180-1890829323-1106 
    2018-04-15 02:11:27Z \Device\HarddiskVolume1\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe                  DFIR\Administrator     S-1-5-21-204460083-2392015180-1890829323-500  
    2018-04-15 02:11:26Z \Device\HarddiskVolume1\Windows\System32\consent.exe                                                NT AUTHORITY\SYSTEM    S-1-5-18                                      
    2018-04-15 02:11:08Z \Device\HarddiskVolume1\Program Files\VMware\VMware Tools\vmtoolsd.exe                              DFIR\matt              S-1-5-21-204460083-2392015180-1890829323-1106 
    2018-04-15 02:10:59Z \Device\HarddiskVolume1\Windows\System32\dwm.exe                                                    Window Manager\DWM-1   S-1-5-90-0-1
    <...SNIP...>

.EXAMPLE
	Invoke-BAMParser.ps1 -SortSid
    
    Output ordered by User Sid instead of time

.NOTES
    References:
    https://www.linkedin.com/pulse/alternative-prefetch-bam-costas-katsavounidis/
    https://padawan-4n6.hatenablog.com/entry/2018/02/22/131110
    https://padawan-4n6.hatenablog.com/entry/2018/03/07/191419
    http://windowsir.blogspot.com.au/2018/03/new-and-updated-plugins-other-items.html
    http://batcmd.com/windows/10/services/bam/
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $False)][Switch]$SortSid=$Null
)

# Set SortSid if set by switch
#$SortSid = $PSBoundParameters.ContainsKey('SortSid')

$Output=@()
$Users=$null


# MAIN
if (!(Get-PSDrive -Name HKLM -PSProvider Registry)){
    Try{New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE}
    Catch{"Error Mounting HKEY_Local_Machine"}
}

Try{$Users = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\bam\UserSettings\" -ErrorAction Stop| Select-Object -ExpandProperty PSChildName}
Catch{
    "Error Parsing BAM Key. Likley unsupported Windows Version"
    exit
}

Foreach ($Sid in $Users){
    $Items = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\bam\UserSettings\$Sid"-ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property

    # Enumerating User - will roll back to SID on error
    Try{
        $objSID = New-Object System.Security.Principal.SecurityIdentifier($Sid) 
        $User = $objSID.Translate( [System.Security.Principal.NTAccount]) 
        $User = $User.Value
    }
    Catch{$User=""}

    Foreach ($Item in $Items){
        $Key = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\bam\UserSettings\$Sid" | Select-Object -ExpandProperty $Item
        
        If($key.length -eq 24){
            $Hex=[System.BitConverter]::ToString($key[7..0]) -replace "-",""
            $TimeUTC = Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))) -Format u

            # Setting up object for nicest output format
            $Line = "" | Select TimeUTC, Item, User, Sid
            $Line.TimeUTC = $TimeUTC
            $Line.Item = $Item
            $Line.User = $User
            $Line.Sid = $Sid
            $Output += $Line
        }
    }
}

# Sorting by User SID
If ($SortSid){$Output | Sort-Object Sid | Format-Table -AutoSize -Wrap}
Else{$Output | Sort-Object TimeUTC -Descending | Format-Table -AutoSize -Wrap}

[gc]::Collect()