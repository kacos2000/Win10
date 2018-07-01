<#

.SOURCE 
	https://github.com/mgreen27/Powershell-IR/blob/master/Content/Other/BAMParser.ps1
	
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
    "Error Parsing BAM Key. Likely unsupported Windows Version"
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

$Output |Out-GridView -PassThru -Title "BAM Contents"































