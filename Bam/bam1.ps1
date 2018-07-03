<#

.ORIGINALSOURCE 
   https://github.com/mgreen27/Powershell-IR/blob/master/Content/Other/BAMParser.ps1

.DESCRIPTION
    Background Activity Moderator (BAM) Service has been included from Windows 10 1709
   Invoke-BAMParser.ps1 parses BAM entries from SYSTEM registry hive and returns the data in an easy to read format.

.NOTES
    References:
    https://www.linkedin.com/pulse/alternative-prefetch-bam-costas-katsavounidis/
    https://padawan-4n6.hatenablog.com/entry/2018/02/22/131110
    https://padawan-4n6.hatenablog.com/entry/2018/03/07/191419
    http://windowsir.blogspot.com.au/2018/03/new-and-updated-plugins-other-items.html
    http://batcmd.com/windows/10/services/bam/
#>


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

$UserTime = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").TimeZoneKeyName
$UserBias = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").ActiveTimeBias
$UserDay = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").DaylightBias

$result = Foreach ($Sid in $Users){
    $Items = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\bam\UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property

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
                        'Last Execution Time (UTC)'= $TimeUTC
						'Local Time' = $TimeLocal
						'User Time' = $TimeUser
						 Application = $f
						'Full Path' = $path
						'Bam Original Entry' = $item
						 User = $User
						 Sid = $Sid
						}
					 	
		        }
				
   }
   
}

$result |Out-GridView -PassThru -Title "BAM key entries  - User TimeZone: ($UserTime) -> ActiveBias: ( $Bias) - DayLightTime: ($Day)"
[gc]::Collect()































