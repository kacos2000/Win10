﻿#Requires -RunAsAdministrator
<#
	.SYNOPSIS
		Combined Windows 11 Program-Compatibility-Assistant parser
	
	.DESCRIPTION
		Combined parser for Windows 11 22H2+:
		
		-  \Windows\appcompat\pca\PcaAppLaunchDic.txt
		-  \Windows\appcompat\pca\PcaGeneralDb0.txt
		-  \Windows\appcompat\pca\PcaGeneralDb1.txt
		-  Windows\System32\winevt\Logs\Microsoft-Windows-Application-Experience%4Program-Compatibility-Assistant.evtx
	
	.PARAMETER Pca
		Full path of \Windows\appcompat\pca folder
	
	.PARAMETER Evtx
		Full Path to Microsoft-Windows-Application-Experience%4Program-Compatibility-Assistant.evtx
	
	.PARAMETER CSV
		A description of the CSV parameter.
	
	.PARAMETER OutPath
		Path for CSV output (Folder)
	
	.PARAMETER NoGUI
		Display the results or not
		If this parameter is false, the CSV parameter will be forced-set as true
	
	.EXAMPLE
		PS C:\> .\pca.ps1
	
	.NOTES
		Additional information about the file.
#>
param
(
	[System.String]$Pca = "$($env:windir)\appcompat\pca",
	[System.String]$Evtx = "$($env:windir)\System32\WinEvt\logs\Microsoft-Windows-Application-Experience%4Program-Compatibility-Assistant.evtx",
	[Switch]$CSV = $false,
	[System.String]$OutPath = [Environment]::GetFolderPath('Desktop'),
	[Switch]$NoGUI = $false
)

$null = [System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')

function Show-WarningMessage
{
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$WarningMessage
	)
	[void][System.Windows.Forms.MessageBox]::Show($owner, "$($WarningMessage)", "Program-Compatibility parser", "OK", "Warning")
}

function Is-Admin
{
	$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
	$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
	$principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}
# check priviledges (Admin)
If (!(Is-Admin))
{
	Show-WarningMessage -WarningMessage "This script needs to be run Elevated.`nPlease restart the script as an Administrator."
	return
}

Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;

public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    
    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}
"@ -ReferencedAssemblies "System.Windows.Forms.dll"
$owner = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

# Show an Open File Dialog and return the file selected by the user
Function Get-Files
{
    $folderbrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderbrowser.Description = "Select Program-Compatibility (pca) folder (Windows\appcompat\pca)"
    $folderbrowser.SelectedPath = "$($env:windir)\appcompat\pca"
    $folderbrowser.ShowNewFolderButton = $false
    	
    if($folderbrowser.ShowDialog($owner) -eq "OK")
		{
        $dirFiles = [System.IO.Directory]::GetFiles($folderbrowser.SelectedPath, '*.*')
		$Pcafiles = foreach ($file in $dirFiles)
		{
			[System.Windows.Forms.Application]::DoEvents()
			if ($file.EndsWith('.txt'))
			{
				[PSCustomObject][Ordered]@{
					FileName = $file
					CreationTimeUtc   = [system.IO.File]::GetCreationTimeUtc($file).ToString("dd/MM/yyyy HH:mm:ss.fffffff")
					LastAccessTimeUtc = [system.IO.File]::GetLastAccessTimeUtc($file).ToString("dd/MM/yyyy HH:mm:ss.fffffff")
					LastWriteTimeUtc  = [system.IO.File]::GetLastWriteTimeUtc($file).ToString("dd/MM/yyyy HH:mm:ss.fffffff")
					Attributes	      = [system.IO.File]::GetAttributes($file)
					Size		      = [System.IO.FileInfo]::new($file).Length
				}
			}
		 } # files end
        }
	        else  
        {
            Write-Host " User Cancelled" -f White
			exit
        }
    return $Pcafiles

	}


$e=0
$sw = [Diagnostics.Stopwatch]::StartNew()

$PCAcomplete = [System.Collections.ArrayList]@{}

if ($Pca -ne "$($env:windir)\appcompat\pca" -and !!(Test-Path -Path $Pca))
{
	$Pcafiles = $Pca
}
else
{
	$Pcafiles = Get-Files
}

if ($null -eq $NoGUI -or $NoGUI -eq $false)
{
	$Pcafiles.where{ $_.filename -match 'Pca' } | Format-Table -AutoSize
}

if($Pcafiles.count -ge 1){
$PcaAppLaunchDic = $Pcafiles.where{$_.filename -match 'PcaAppLaunchDic.txt' -and $_.Size -gt 0}
if($PcaAppLaunchDic.count -ge 1){
        foreach($PcaAppLaunchDicfile in $PcaAppLaunchDic){
        #Open file & read the text
	    $DataText = [System.IO.File]::ReadAllText("$($PcaAppLaunchDicfile.Filename)", [System.Text.Encoding]::UTF8 )
        $Header = 'ExePath','Time Created'
        ($DataText|ConvertFrom-Csv -Delimiter '|' -Header $Header )|foreach{
        
            try   {$time = get-date ($_.'Time Created') -f u}
            catch {$time = $_.'Time Created'}

            $null = $PCAcomplete.Add( [PSCustomObject]@{
                    'Source'                = (split-path $PcaAppLaunchDicfile.Filename -Leaf).TrimEnd('.txt')
                    'Time Created'          = $time
                    'ExePath'               = $_.ExePath
                    'ResolverName/Exit Code'= ''
                    'ApplicationName'       = ''
                    'ApplicationVersion'    = ''
                    'FileID'                = ''
                    'ProgramID'             = ''
                    'ScenarioId'            = ''
                    })
                } # end foreach line
    } # end foreach file
} # end if one or more


$PcaGeneralDb = $Pcafiles.where{$_.filename -match 'PcaGeneralDb' -and $_.Size -gt 0}
if($PcaGeneralDb.count -ge 1){
        foreach($PcaGeneralDbfile in $PcaGeneralDb){
        #Open file & read the text
	    $DataText = [System.IO.File]::ReadAllText("$($PcaGeneralDbfile.Filename)", [System.Text.Encoding]::Unicode )
        $Header = 'Time Created','Type','ExePath','ApplicationName','Copyright','ApplicationVersion','ProgramID','Exit Code'
        ($DataText|ConvertFrom-Csv -Delimiter '|' -Header $Header )|foreach{
        
            try   {$time = get-date ($_.'Time Created') -f u}
            catch {$time = $_.'Time Created'}

            $null = $PCAcomplete.Add( [PSCustomObject]@{
                    'Source'                = (split-path $PcaGeneralDbfile.Filename -Leaf).TrimEnd('.txt')
                    'Time Created'          = $time
                    'ExePath'               = $_.ExePath
                    'ResolverName/Exit Code'= $_.'Exit Code'
                    'ApplicationName'       = $_.ApplicationName
                    'ApplicationVersion'    = $_.ApplicationVersion
                    'FileID'                = ''
                    'ProgramID'             = $_.ProgramID
                    'ScenarioId'            = ''
                    })
                } # end foreach line
    } # end foreach file
 } # end if one or more
} # end if pcafiles are more that 0

# Get the pca events
# Show an Open File Dialog and return the file selected by the user
Function Get-File
{
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog 
    $OpenFileDialog.AutoUpgradeEnabled = $true
    $OpenFileDialog.InitialDirectory = "$($env:windir)\System32\WinEvt\logs\"
    $openfiledialog.Filter = "Event Log (evtx)|Microsoft-Windows-Application-Experience%4Program-Compatibility-Assistant.evtx|All files (*.*)|*.*"
    $openfiledialog.ReadOnlyChecked = $true
    $openfiledialog.Title = "Select Program-Compatibility-Assistant.evtx log (\System32\WinEvt\logs\)"
    $openfiledialog.FileName = "$($env:windir)\System32\WinEvt\logs\Microsoft-Windows-Application-Experience%4Program-Compatibility-Assistant.evtx"
	
    if($openfiledialog.ShowDialog($owner) -eq "OK")
		{
        $file = $openfiledialog.FileName
		 }
	        else  
        {
            Write-Host " User Cancelled" -f White
			exit
        }
    return $file

	}


if ($Evtx -ne "$($env:windir)\System32\WinEvt\logs\Microsoft-Windows-Application-Experience%4Program-Compatibility-Assistant.evtx" -and !!(Test-Path -Path $Evtx))
{
	$file = $Evtx
}
else
{
	$file = Get-File
}

Try { 
	$log = (Get-WinEvent -FilterHashtable @{path = $File; ProviderName="Microsoft-Windows-Program-Compatibility-Assistant","Microsoft-Windows-Application-Experience"} -ErrorAction Stop)
    }
catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") 
		{Write-host "No Matching Events Found" -f Red; exit}
		}

[xml[]]$xmllog = $log.toXml()
$Lcount = $xmllog.Count
if ($null -eq $NoGUI -or $NoGUI -eq $false)
{
	write-host "Found: $Lcount entries in Event Log: ($File)" -f White
}
foreach ($l in $xmllog) {$e++
			
			#Progress Bar
			write-progress -id 1 -activity "Collecting Security entries with EventID=4624 - $e of $($Lcount)"  -PercentComplete (($e / $Lcount) * 100)		
			
			# Format output fields
            $version =     if ($l.Event.System.Version -eq 0){"Windows Server 2008, Windows Vista"}
                        elseif($l.Event.System.Version -eq 1){"Windows Server 2012, Windows 8"}
                        elseif($l.Event.System.Version -eq 2){"Windows 10"}
             
            $Level =       if ($l.Event.System.Level -eq 0 ){"Undefined"}
                        elseif($l.Event.System.Level -eq 1){"Critical"}
                        elseif($l.Event.System.Level -eq 2){"Error"}
                        elseif($l.Event.System.Level -eq 3){"Warning"}
                        elseif($l.Event.System.Level -eq 4){"Information"}
                        elseif($l.Event.System.Level -eq 5){"Verbose"}

            $Date = get-date (get-date $l.Event.System.TimeCreated.SystemTime).ToUniversalTime() -f u  

            $ExePath =           if($l.Event.System.EventID -eq '17'){ $l.Event.UserData.ResolverFiredEvent.ExePath} elseif($l.Event.System.EventID -eq '105'){$l.Event.UserData.HelpedUserEvent.ExecutablePath}else{}
            $ResolverName =      if($l.Event.System.EventID -eq '17'){$l.Event.UserData.ResolverFiredEvent.ResolverName} else{}
            $ApplicationName =   if($l.Event.System.EventID -eq '105'){$l.Event.UserData.HelpedUserEvent.ApplicationName} else{} 
            $ApplicationVersion= if($l.Event.System.EventID -eq '105'){$l.Event.UserData.HelpedUserEvent.ApplicationVersion} else{} 
            $FileID =            if($l.Event.System.EventID -eq '105'){$l.Event.UserData.HelpedUserEvent.FileID} else{} 
            $ProgramID =         if($l.Event.System.EventID -eq '105'){$l.Event.UserData.HelpedUserEvent.ProgramID} else{} 
            $ScenarioId=         if($l.Event.System.EventID -eq '105'){$l.Event.UserData.HelpedUserEvent.ScenarioId} else{} 
            $UserAction =        if($l.Event.System.EventID -eq '105'){$l.Event.UserData.HelpedUserEvent.UserAction} else{} 
            $UserActionID =      if($l.Event.System.EventID -eq '105'){$l.Event.UserData.HelpedUserEvent.UserActionID} else{} 
			

            $null = $PCAcomplete.Add( [PSCustomObject]@{
                    'Source'                = "Event: $($l.Event.System.EventID) - RecId: $($l.Event.System.EventRecordID)"
                    'Time Created'          = $Date
                    'ExePath'               = $ExePath
                    'ResolverName/Exit Code'= $ResolverName
                    'ApplicationName'       = $ApplicationName
                    'ApplicationVersion'    = $ApplicationVersion
                    'FileID'                = $FileID
                    'ProgramID'             = $ProgramID
                    'ScenarioId'            = $ScenarioId
                    })
	}

if ($null -eq $NoGUI -or $NoGUI -eq $false)
{
	$PCAcomplete | sort -Property 'Time Created' -Descending | Out-GridView -Title "Program-Compatibility: $($PCAcomplete.Count) entries" -PassThru
}
else
{
	$CSV = $true
}

# Export the output to CSV if switch is enabled
if ($CSV -eq $true)
{
	if ($OutPath -eq [Environment]::GetFolderPath('Desktop'))
	{
		$SaveFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
		$SaveFolderDialog.Description = "Select folder for the CSV output"
		$SaveFolderDialog.SelectedPath = [Environment]::GetFolderPath('Desktop')
		if ($SaveFolderDialog.ShowDialog($owner) -eq 'OK')
		{
			$OutPath = $SaveFolderDialog.SelectedPath
		}
	}
	$PCAcomplete | sort -Property 'Time Created' -Descending | Export-Csv -Path "$($OutPath)\PCA_list.csv" -Delimiter '|' -Encoding UTF8 -NoTypeInformation
}




# SIG # Begin signature block
# MIIviAYJKoZIhvcNAQcCoIIveTCCL3UCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC1yPO3Ie/29mFq
# pNAkq4WY7R+HmizQbJA6AsUPIE7k/KCCKI0wggQyMIIDGqADAgECAgEBMA0GCSqG
# SIb3DQEBBQUAMHsxCzAJBgNVBAYTAkdCMRswGQYDVQQIDBJHcmVhdGVyIE1hbmNo
# ZXN0ZXIxEDAOBgNVBAcMB1NhbGZvcmQxGjAYBgNVBAoMEUNvbW9kbyBDQSBMaW1p
# dGVkMSEwHwYDVQQDDBhBQUEgQ2VydGlmaWNhdGUgU2VydmljZXMwHhcNMDQwMTAx
# MDAwMDAwWhcNMjgxMjMxMjM1OTU5WjB7MQswCQYDVQQGEwJHQjEbMBkGA1UECAwS
# R3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHDAdTYWxmb3JkMRowGAYDVQQKDBFD
# b21vZG8gQ0EgTGltaXRlZDEhMB8GA1UEAwwYQUFBIENlcnRpZmljYXRlIFNlcnZp
# Y2VzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvkCd9G7h6naHHE1F
# RI6+RsiDBp3BKv4YH47kAvrzq11QihYxC5oG0MVwIs1JLVRjzLZuaEYLU+rLTCTA
# vHJO6vEVrvRUmhIKw3qyM2Di2olV8yJY897cz++DhqKMlE+faPKYkEaEJ8d2v+PM
# NSyLXgdkZYLASLCokflhn3YgUKiRx2a163hiA1bwihoT6jGjHqCZ/Tj29icyWG8H
# 9Wu4+xQrr7eqzNZjX3OM2gWZqDioyxd4NlGs6Z70eDqNzw/ZQuKYDKsvnw4B3u+f
# mUnxLd+sdE0bmLVHxeUp0fmQGMdinL6DxyZ7Poolx8DdneY1aBAgnY/Y3tLDhJwN
# XugvyQIDAQABo4HAMIG9MB0GA1UdDgQWBBSgEQojPpbxB+zirynvgqV/0DCktDAO
# BgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zB7BgNVHR8EdDByMDigNqA0
# hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2Vz
# LmNybDA2oDSgMoYwaHR0cDovL2NybC5jb21vZG8ubmV0L0FBQUNlcnRpZmljYXRl
# U2VydmljZXMuY3JsMA0GCSqGSIb3DQEBBQUAA4IBAQAIVvwC8Jvo/6T61nvGRIDO
# T8TF9gBYzKa2vBRJaAR26ObuXewCD2DWjVAYTyZOAePmsKXuv7x0VEG//fwSuMdP
# WvSJYAV/YLcFSvP28cK/xLl0hrYtfWvM0vNG3S/G4GrDwzQDLH2W3VrCDqcKmcEF
# i6sML/NcOs9sN1UJh95TQGxY7/y2q2VuBPYb3DzgWhXGntnxWUgwIWUDbOzpIXPs
# mwOh4DetoBUYj/q6As6nLKkQEyzU5QgmqyKXYPiQXnTUoppTvfKpaOCibsLXbLGj
# D56/62jnVvKu8uMrODoJgbVrhde+Le0/GreyY+L1YiyC1GoAQVDxOYOflek2lphu
# MIIFbzCCBFegAwIBAgIQSPyTtGBVlI02p8mKidaUFjANBgkqhkiG9w0BAQwFADB7
# MQswCQYDVQQGEwJHQjEbMBkGA1UECAwSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYD
# VQQHDAdTYWxmb3JkMRowGAYDVQQKDBFDb21vZG8gQ0EgTGltaXRlZDEhMB8GA1UE
# AwwYQUFBIENlcnRpZmljYXRlIFNlcnZpY2VzMB4XDTIxMDUyNTAwMDAwMFoXDTI4
# MTIzMTIzNTk1OVowVjELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5nIFJvb3Qg
# UjQ2MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAjeeUEiIEJHQu/xYj
# ApKKtq42haxH1CORKz7cfeIxoFFvrISR41KKteKW3tCHYySJiv/vEpM7fbu2ir29
# BX8nm2tl06UMabG8STma8W1uquSggyfamg0rUOlLW7O4ZDakfko9qXGrYbNzszwL
# DO/bM1flvjQ345cbXf0fEj2CA3bm+z9m0pQxafptszSswXp43JJQ8mTHqi0Eq8Nq
# 6uAvp6fcbtfo/9ohq0C/ue4NnsbZnpnvxt4fqQx2sycgoda6/YDnAdLv64IplXCN
# /7sVz/7RDzaiLk8ykHRGa0c1E3cFM09jLrgt4b9lpwRrGNhx+swI8m2JmRCxrds+
# LOSqGLDGBwF1Z95t6WNjHjZ/aYm+qkU+blpfj6Fby50whjDoA7NAxg0POM1nqFOI
# +rgwZfpvx+cdsYN0aT6sxGg7seZnM5q2COCABUhA7vaCZEao9XOwBpXybGWfv1Vb
# HJxXGsd4RnxwqpQbghesh+m2yQ6BHEDWFhcp/FycGCvqRfXvvdVnTyheBe6QTHrn
# xvTQ/PrNPjJGEyA2igTqt6oHRpwNkzoJZplYXCmjuQymMDg80EY2NXycuu7D1fkK
# dvp+BRtAypI16dV60bV/AK6pkKrFfwGcELEW/MxuGNxvYv6mUKe4e7idFT/+IAx1
# yCJaE5UZkADpGtXChvHjjuxf9OUCAwEAAaOCARIwggEOMB8GA1UdIwQYMBaAFKAR
# CiM+lvEH7OKvKe+CpX/QMKS0MB0GA1UdDgQWBBQy65Ka/zWWSC8oQEJwIDaRXBeF
# 5jAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggr
# BgEFBQcDAzAbBgNVHSAEFDASMAYGBFUdIAAwCAYGZ4EMAQQBMEMGA1UdHwQ8MDow
# OKA2oDSGMmh0dHA6Ly9jcmwuY29tb2RvY2EuY29tL0FBQUNlcnRpZmljYXRlU2Vy
# dmljZXMuY3JsMDQGCCsGAQUFBwEBBCgwJjAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuY29tb2RvY2EuY29tMA0GCSqGSIb3DQEBDAUAA4IBAQASv6Hvi3SamES4aUa1
# qyQKDKSKZ7g6gb9Fin1SB6iNH04hhTmja14tIIa/ELiueTtTzbT72ES+BtlcY2fU
# QBaHRIZyKtYyFfUSg8L54V0RQGf2QidyxSPiAjgaTCDi2wH3zUZPJqJ8ZsBRNraJ
# AlTH/Fj7bADu/pimLpWhDFMpH2/YGaZPnvesCepdgsaLr4CnvYFIUoQx2jLsFeSm
# TD1sOXPUC4U5IOCFGmjhp0g4qdE2JXfBjRkWxYhMZn0vY86Y6GnfrDyoXZ3JHFuu
# 2PMvdM+4fvbXg50RlmKarkUT2n/cR/vfw1Kf5gZV6Z2M8jpiUbzsJA8p1FiAhORF
# e1rYMIIFgzCCA2ugAwIBAgIORea7A4Mzw4VlSOb/RVEwDQYJKoZIhvcNAQEMBQAw
# TDEgMB4GA1UECxMXR2xvYmFsU2lnbiBSb290IENBIC0gUjYxEzARBgNVBAoTCkds
# b2JhbFNpZ24xEzARBgNVBAMTCkdsb2JhbFNpZ24wHhcNMTQxMjEwMDAwMDAwWhcN
# MzQxMjEwMDAwMDAwWjBMMSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3QgQ0EgLSBS
# NjETMBEGA1UEChMKR2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2lnbjCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJUH6HPKZvnsFMp7PPcNCPG0RQss
# grRIxutbPK6DuEGSMxSkb3/pKszGsIhrxbaJ0cay/xTOURQh7ErdG1rG1ofuTToV
# Bu1kZguSgMpE3nOUTvOniX9PeGMIyBJQbUJmL025eShNUhqKGoC3GYEOfsSKvGRM
# IRxDaNc9PIrFsmbVkJq3MQbFvuJtMgamHvm566qjuL++gmNQ0PAYid/kD3n16qIf
# KtJwLnvnvJO7bVPiSHyMEAc4/2ayd2F+4OqMPKq0pPbzlUoSB239jLKJz9CgYXfI
# WHSw1CM69106yqLbnQneXUQtkPGBzVeS+n68UARjNN9rkxi+azayOeSsJDa38O+2
# HBNXk7besvjihbdzorg1qkXy4J02oW9UivFyVm4uiMVRQkQVlO6jxTiWm05OWgtH
# 8wY2SXcwvHE35absIQh1/OZhFj931dmRl4QKbNQCTXTAFO39OfuD8l4UoQSwC+n+
# 7o/hbguyCLNhZglqsQY6ZZZZwPA1/cnaKI0aEYdwgQqomnUdnjqGBQCe24DWJfnc
# BZ4nWUx2OVvq+aWh2IMP0f/fMBH5hc8zSPXKbWQULHpYT9NLCEnFlWQaYw55PfWz
# jMpYrZxCRXluDocZXFSxZba/jJvcE+kNb7gu3GduyYsRtYQUigAZcIN5kZeR1Bon
# vzceMgfYFGM8KEyvAgMBAAGjYzBhMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
# BTADAQH/MB0GA1UdDgQWBBSubAWjkxPioufi1xzWx/B/yGdToDAfBgNVHSMEGDAW
# gBSubAWjkxPioufi1xzWx/B/yGdToDANBgkqhkiG9w0BAQwFAAOCAgEAgyXt6NH9
# lVLNnsAEoJFp5lzQhN7craJP6Ed41mWYqVuoPId8AorRbrcWc+ZfwFSY1XS+wc3i
# EZGtIxg93eFyRJa0lV7Ae46ZeBZDE1ZXs6KzO7V33EByrKPrmzU+sQghoefEQzd5
# Mr6155wsTLxDKZmOMNOsIeDjHfrYBzN2VAAiKrlNIC5waNrlU/yDXNOd8v9EDERm
# 8tLjvUYAGm0CuiVdjaExUd1URhxN25mW7xocBFymFe944Hn+Xds+qkxV/ZoVqW/h
# pvvfcDDpw+5CRu3CkwWJ+n1jez/QcYF8AOiYrg54NMMl+68KnyBr3TsTjxKM4kEa
# SHpzoHdpx7Zcf4LIHv5YGygrqGytXm3ABdJ7t+uA/iU3/gKbaKxCXcPu9czc8FB1
# 0jZpnOZ7BN9uBmm23goJSFmH63sUYHpkqmlD75HHTOwY3WzvUy2MmeFe8nI+z1TI
# vWfspA9MRf/TuTAjB0yPEL+GltmZWrSZVxykzLsViVO6LAUP5MSeGbEYNNVMnbrt
# 9x+vJJUEeKgDu+6B5dpffItKoZB0JaezPkvILFa9x8jvOOJckvB595yEunQtYQEg
# fn7R8k8HWV+LLUNS60YMlOH1Zkd5d9VUWx+tJDfLRVpOoERIyNiwmcUVhAn21klJ
# wGW45hpxbqCo8YLoRT5s1gLXCmeDBVrJpBAwggYaMIIEAqADAgECAhBiHW0MUgGe
# O5B5FSCJIRwKMA0GCSqGSIb3DQEBDAUAMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUg
# U2lnbmluZyBSb290IFI0NjAeFw0yMTAzMjIwMDAwMDBaFw0zNjAzMjEyMzU5NTla
# MFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxKzApBgNV
# BAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBDQSBSMzYwggGiMA0GCSqG
# SIb3DQEBAQUAA4IBjwAwggGKAoIBgQCbK51T+jU/jmAGQ2rAz/V/9shTUxjIztNs
# fvxYB5UXeWUzCxEeAEZGbEN4QMgCsJLZUKhWThj/yPqy0iSZhXkZ6Pg2A2NVDgFi
# gOMYzB2OKhdqfWGVoYW3haT29PSTahYkwmMv0b/83nbeECbiMXhSOtbam+/36F09
# fy1tsB8je/RV0mIk8XL/tfCK6cPuYHE215wzrK0h1SWHTxPbPuYkRdkP05ZwmRmT
# nAO5/arnY83jeNzhP06ShdnRqtZlV59+8yv+KIhE5ILMqgOZYAENHNX9SJDm+qxp
# 4VqpB3MV/h53yl41aHU5pledi9lCBbH9JeIkNFICiVHNkRmq4TpxtwfvjsUedyz8
# rNyfQJy/aOs5b4s+ac7IH60B+Ja7TVM+EKv1WuTGwcLmoU3FpOFMbmPj8pz44MPZ
# 1f9+YEQIQty/NQd/2yGgW+ufflcZ/ZE9o1M7a5Jnqf2i2/uMSWymR8r2oQBMdlyh
# 2n5HirY4jKnFH/9gRvd+QOfdRrJZb1sCAwEAAaOCAWQwggFgMB8GA1UdIwQYMBaA
# FDLrkpr/NZZILyhAQnAgNpFcF4XmMB0GA1UdDgQWBBQPKssghyi47G9IritUpimq
# F6TNDDAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUE
# DDAKBggrBgEFBQcDAzAbBgNVHSAEFDASMAYGBFUdIAAwCAYGZ4EMAQQBMEsGA1Ud
# HwREMEIwQKA+oDyGOmh0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGlnb1B1Ymxp
# Y0NvZGVTaWduaW5nUm9vdFI0Ni5jcmwwewYIKwYBBQUHAQEEbzBtMEYGCCsGAQUF
# BzAChjpodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2RlU2ln
# bmluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5zZWN0aWdv
# LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEABv+C4XdjNm57oRUgmxP/BP6YdURhw1aV
# cdGRP4Wh60BAscjW4HL9hcpkOTz5jUug2oeunbYAowbFC2AKK+cMcXIBD0ZdOaWT
# syNyBBsMLHqafvIhrCymlaS98+QpoBCyKppP0OcxYEdU0hpsaqBBIZOtBajjcw5+
# w/KeFvPYfLF/ldYpmlG+vd0xqlqd099iChnyIMvY5HexjO2AmtsbpVn0OhNcWbWD
# RF/3sBp6fWXhz7DcML4iTAWS+MVXeNLj1lJziVKEoroGs9Mlizg0bUMbOalOhOfC
# ipnx8CaLZeVme5yELg09Jlo8BMe80jO37PU8ejfkP9/uPak7VLwELKxAMcJszkye
# iaerlphwoKx1uHRzNyE6bxuSKcutisqmKL5OTunAvtONEoteSiabkPVSZ2z76mKn
# zAfZxCl/3dq3dUNw4rg3sTCggkHSRqTqlLMS7gjrhTqBmzu1L90Y1KWN/Y5JKdGv
# spbOrTfOXyXvmPL6E52z1NZJ6ctuMFBQZH3pwWvqURR8AgQdULUvrxjUYbHHj95E
# jza63zdrEcxWLDX6xWls/GDnVNueKjWUH3fTv1Y8Wdho698YADR7TNx8X8z2Bev6
# SivBBOHY+uqiirZtg0y9ShQoPzmCcn63Syatatvx157YK9hlcPmVoa1oDE5/L9Uo
# 2bC5a4CH2RwwggZZMIIEQaADAgECAg0B7BySQN79LkBdfEd0MA0GCSqGSIb3DQEB
# DAUAMEwxIDAeBgNVBAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFI2MRMwEQYDVQQK
# EwpHbG9iYWxTaWduMRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTE4MDYyMDAwMDAw
# MFoXDTM0MTIxMDAwMDAwMFowWzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2Jh
# bFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0YW1waW5nIENB
# IC0gU0hBMzg0IC0gRzQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDw
# AuIwI/rgG+GadLOvdYNfqUdSx2E6Y3w5I3ltdPwx5HQSGZb6zidiW64HiifuV6PE
# Ne2zNMeswwzrgGZt0ShKwSy7uXDycq6M95laXXauv0SofEEkjo+6xU//NkGrpy39
# eE5DiP6TGRfZ7jHPvIo7bmrEiPDul/bc8xigS5kcDoenJuGIyaDlmeKe9JxMP11b
# 7Lbv0mXPRQtUPbFUUweLmW64VJmKqDGSO/J6ffwOWN+BauGwbB5lgirUIceU/kKW
# O/ELsX9/RpgOhz16ZevRVqkuvftYPbWF+lOZTVt07XJLog2CNxkM0KvqWsHvD9WZ
# uT/0TzXxnA/TNxNS2SU07Zbv+GfqCL6PSXr/kLHU9ykV1/kNXdaHQx50xHAotIB7
# vSqbu4ThDqxvDbm19m1W/oodCT4kDmcmx/yyDaCUsLKUzHvmZ/6mWLLU2EESwVX9
# bpHFu7FMCEue1EIGbxsY1TbqZK7O/fUF5uJm0A4FIayxEQYjGeT7BTRE6giunUln
# EYuC5a1ahqdm/TMDAd6ZJflxbumcXQJMYDzPAo8B/XLukvGnEt5CEk3sqSbldwKs
# DlcMCdFhniaI/MiyTdtk8EWfusE/VKPYdgKVbGqNyiJc9gwE4yn6S7Ac0zd0hNkd
# Zqs0c48efXxeltY9GbCX6oxQkW2vV4Z+EDcdaxoU3wIDAQABo4IBKTCCASUwDgYD
# VR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFOoWxmnn
# 48tXRTkzpPBAvtDDvWWWMB8GA1UdIwQYMBaAFK5sBaOTE+Ki5+LXHNbH8H/IZ1Og
# MD4GCCsGAQUFBwEBBDIwMDAuBggrBgEFBQcwAYYiaHR0cDovL29jc3AyLmdsb2Jh
# bHNpZ24uY29tL3Jvb3RyNjA2BgNVHR8ELzAtMCugKaAnhiVodHRwOi8vY3JsLmds
# b2JhbHNpZ24uY29tL3Jvb3QtcjYuY3JsMEcGA1UdIARAMD4wPAYEVR0gADA0MDIG
# CCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5
# LzANBgkqhkiG9w0BAQwFAAOCAgEAf+KI2VdnK0JfgacJC7rEuygYVtZMv9sbB3DG
# +wsJrQA6YDMfOcYWaxlASSUIHuSb99akDY8elvKGohfeQb9P4byrze7AI4zGhf5L
# FST5GETsH8KkrNCyz+zCVmUdvX/23oLIt59h07VGSJiXAmd6FpVK22LG0LMCzDRI
# RVXd7OlKn14U7XIQcXZw0g+W8+o3V5SRGK/cjZk4GVjCqaF+om4VJuq0+X8q5+dI
# ZGkv0pqhcvb3JEt0Wn1yhjWzAlcfi5z8u6xM3vreU0yD/RKxtklVT3WdrG9KyC5q
# ucqIwxIwTrIIc59eodaZzul9S5YszBZrGM3kWTeGCSziRdayzW6CdaXajR63Wy+I
# Lj198fKRMAWcznt8oMWsr1EG8BHHHTDFUVZg6HyVPSLj1QokUyeXgPpIiScseeI8
# 5Zse46qEgok+wEr1If5iEO0dMPz2zOpIJ3yLdUJ/a8vzpWuVHwRYNAqJ7YJQ5NF7
# qMnmvkiqK1XZjbclIA4bUaDUY6qD6mxyYUrJ+kPExlfFnbY8sIuwuRwx773vFNgU
# QGwgHcIt6AvGjW2MtnHtUiH+PvafnzkarqzSL3ogsfSsqh3iLRSd+pZqHcY8yvPZ
# HL9TTaRHWXyVxENB+SXiLBB+gfkNlKd98rUJ9dhgckBQlSDUQ0S++qCV5yBZtnjG
# pGqqIpswggZoMIIEUKADAgECAhABSJA9woq8p6EZTQwcV7gpMA0GCSqGSIb3DQEB
# CwUAMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEw
# LwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTM4NCAtIEc0
# MB4XDTIyMDQwNjA3NDE1OFoXDTMzMDUwODA3NDE1OFowYzELMAkGA1UEBhMCQkUx
# GTAXBgNVBAoMEEdsb2JhbFNpZ24gbnYtc2ExOTA3BgNVBAMMMEdsb2JhbHNpZ24g
# VFNBIGZvciBNUyBBdXRoZW50aWNvZGUgQWR2YW5jZWQgLSBHNDCCAaIwDQYJKoZI
# hvcNAQEBBQADggGPADCCAYoCggGBAMLJ3AO2G1D6Kg3onKQh2yinHfWAtRJ0I/5e
# L8MaXZayIBkZUF92IyY1xiHslO+1ojrFkIGbIe8LJ6TjF2Q72pPUVi8811j5bazA
# L5B4I0nA+MGPcBPUa98miFp2e0j34aSm7wsa8yVUD4CeIxISE9Gw9wLjKw3/QD4A
# QkPeGu9M9Iep8p480Abn4mPS60xb3V1YlNPlpTkoqgdediMw/Px/mA3FZW0b1XRF
# OkawohZ13qLCKnB8tna82Ruuul2c9oeVzqqo4rWjsZNuQKWbEIh2Fk40ofye8eEa
# VNHIJFeUdq3Cx+yjo5Z14sYoawIF6Eu5teBSK3gBjCoxLEzoBeVvnw+EJi5obPrL
# TRl8GMH/ahqpy76jdfjpyBiyzN0vQUAgHM+ICxfJsIpDy+Jrk1HxEb5CvPhR8toA
# Ar4IGCgFJ8TcO113KR4Z1EEqZn20UnNcQqWQ043Fo6o3znMBlCQZQkPRlI9Lft3L
# bbwbTnv5qgsiS0mASXAbLU/eNGA+vQIDAQABo4IBnjCCAZowDgYDVR0PAQH/BAQD
# AgeAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMB0GA1UdDgQWBBRba3v0cHQIwQ0q
# yO/xxLlA0krG/TBMBgNVHSAERTBDMEEGCSsGAQQBoDIBHjA0MDIGCCsGAQUFBwIB
# FiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzAMBgNVHRMB
# Af8EAjAAMIGQBggrBgEFBQcBAQSBgzCBgDA5BggrBgEFBQcwAYYtaHR0cDovL29j
# c3AuZ2xvYmFsc2lnbi5jb20vY2EvZ3N0c2FjYXNoYTM4NGc0MEMGCCsGAQUFBzAC
# hjdodHRwOi8vc2VjdXJlLmdsb2JhbHNpZ24uY29tL2NhY2VydC9nc3RzYWNhc2hh
# Mzg0ZzQuY3J0MB8GA1UdIwQYMBaAFOoWxmnn48tXRTkzpPBAvtDDvWWWMEEGA1Ud
# HwQ6MDgwNqA0oDKGMGh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5jb20vY2EvZ3N0c2Fj
# YXNoYTM4NGc0LmNybDANBgkqhkiG9w0BAQsFAAOCAgEALms+j3+wsGDZ8Z2E3JW2
# 318NvyRR4xoGqlUEy2HB72Vxrgv9lCRXAMfk9gy8GJV9LxlqYDOmvtAIVVYEtuP+
# HrvlEHZUO6tcIV4qNU1Gy6ZMugRAYGAs29P2nd7KMhAMeLC7VsUHS3C8pw+rcryN
# y+vuwUxr2fqYoXQ+6ajIeXx2d0j9z+PwDcHpw5LgBwwTLz9rfzXZ1bfub3xYwPE/
# DBmyAqNJTJwEw/C0l6fgTWolujQWYmbIeLxpc6pfcqI1WB4m678yFKoSeuv0lmt/
# cqzqpzkIMwE2PmEkfhGdER52IlTjQLsuhgx2nmnSxBw9oguMiAQDVN7pGxf+LCue
# 2dZbIjj8ZECGzRd/4amfub+SQahvJmr0DyiwQJGQL062dlC8TSPZf09rkymnbOfQ
# MD6pkx/CUCs5xbL4TSck0f122L75k/SpVArVdljRPJ7qGugkxPs28S9Z05LD7Mtg
# Uh4cRiUI/37Zk64UlaiGigcuVItzTDcVOFBWh/FPrhyPyaFsLwv8uxxvLb2qtuto
# I/DtlCcUY8us9GeKLIHTFBIYAT+Eeq7sR2A/aFiZyUrCoZkVBcKt3qLv16dVfLyE
# G02Uu45KhUTZgT2qoyVVX6RrzTZsAPn/ct5a7P/JoEGWGkBqhZEcr3VjqMtaM7WU
# M36yjQ9zvof8rzpzH3sg23IwggZyMIIE2qADAgECAhALYufvMdbwtA/sWXrOPd+k
# MA0GCSqGSIb3DQEBDAUAMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdv
# IExpbWl0ZWQxKzApBgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBD
# QSBSMzYwHhcNMjIwMjA3MDAwMDAwWhcNMjUwMjA2MjM1OTU5WjB2MQswCQYDVQQG
# EwJHUjEdMBsGA1UECAwUS2VudHJpa8OtIE1ha2Vkb27DrWExIzAhBgNVBAoMGkth
# dHNhdm91bmlkaXMgS29uc3RhbnRpbm9zMSMwIQYDVQQDDBpLYXRzYXZvdW5pZGlz
# IEtvbnN0YW50aW5vczCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIxd
# u9+Lc83wVLNDuBn9NzaXp9JzWaiQs6/uQ6fbCUHC4/2lLfKzOUus3e76lSpnmo7b
# kCLipjwZH+yqWRuvrccrfZCoyVvBAuzdE69AMR02Z3Ay5fjN6kWPfACkgLe4D9og
# SDh/ZsOfHD89+yKKbMqsDdj4w/zjIRwcYGgBR6QOGP8mLAIKH7TwvoYBauLlb6aM
# /eG/TGm3cWd4oonwjiYU2fDkhPPdGgCXFem+vhuIWoDk0A0OVwEzDFi3H9zdv6hB
# bv+d37bl4W81zrm42BMC9kWgiEuoDUQeY4OX2RdNqNtzkPMI7Q93YlnJwitLfSrg
# GmcU6fiE0vIW3mkf7mebYttI7hJVvqt0BaCPRBhOXHT+KNUvenSXwBzTVef/9h70
# POF9ZXbUhTlJJIHJE5SLZ2DvjAOLUvZuvo3bGJIIASHnTKEIVLCUwJB77NeKsgDx
# YGDFc2OQiI9MuFWdaty4B0sXQMj+KxZTb/Q0O850xkLIbQrAS6T2LKEuviE6Ua7b
# QFXi1nFZ+r9XjOwZQmQDuKx2D92AUR/qwcpIM8tIbJdlNzEqE/2wwaE10G+sKuX/
# SaJFZbKXqDMqJr1fw0M9n0saSTX1IZrlrEcppDRN+OIdnQL3cf6PTqv1PTS4pZ/9
# m7iweMcU4lLJ7L/8ZKiIb0ThD9kIddJ5coICzr/hAgMBAAGjggGcMIIBmDAfBgNV
# HSMEGDAWgBQPKssghyi47G9IritUpimqF6TNDDAdBgNVHQ4EFgQUidoax6lNhMBv
# wMAg4rCjdP30S8QwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwEwYDVR0l
# BAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoGA1UdIARDMEEwNQYM
# KwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20v
# Q1BTMAgGBmeBDAEEATBJBgNVHR8EQjBAMD6gPKA6hjhodHRwOi8vY3JsLnNlY3Rp
# Z28uY29tL1NlY3RpZ29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNybDB5BggrBgEF
# BQcBAQRtMGswRAYIKwYBBQUHMAKGOGh0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2Vj
# dGlnb1B1YmxpY0NvZGVTaWduaW5nQ0FSMzYuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAYEAG+2x4Vn8dk+Y
# w0Khv6CZY+/QKXW+aG/siN+Wn24ijKmvbjiNEbEfCicwZ12YpkOCnuFtrXs8k9zB
# PusV1/wdH+0buzzSuCmkyx5v4wSqh8OsyWIyIsW/thnTyzYys/Gw0ep4RHFtbNTR
# K4+PowRHW1DxOjaxJUNi9sbNG1RiDSAVkGAnHo9m+wAK6WFOIFV5vAbCp8upQPwh
# aGo7u2hXP/d18mf/4BtQ+J7voX1BFwgCLhlrho0NY8MgLGuMBcu5zw07j0ZFBvyr
# axDPVwDoZw07JM018c2Nn4hg2XbYyMtUkvCi120uI6299fGs6Tmi9ttP4c6pubs4
# TY40jVxlxxnqqvIA/wRYXpWOe5Z3n80OFEatcFtzLrQTyO9Q1ptk6gso/RNpRu3r
# ug+aXqfvP3a32FNZAQ6dUGr0ae57OtgM+hlLMhSSyhugHrnbi9oNAsqa/KA6UtD7
# MxWJIwAqACTqqVjUTKjzaaE+12aS3vaO6tEqCuT+DOtu7aJRPnyyMYIGUTCCBk0C
# AQEwaDBUMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSsw
# KQYDVQQDEyJTZWN0aWdvIFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgUjM2AhALYufv
# MdbwtA/sWXrOPd+kMA0GCWCGSAFlAwQCAQUAoEwwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwLwYJKoZIhvcNAQkEMSIEINqf6hC9M3NhGT2LDUBHeUdYbNAYIMPU
# /gGRRXW6/DrgMA0GCSqGSIb3DQEBAQUABIICAFx0zvXe1Onzuu8C0Jd1IjYsGNl6
# ogJsI4C2dFF3sW8tJpzAwnsW8DSeD4wyUxMctp0XHc4j9iLZ6J8Glrig64o05LAu
# odwYE6OnbcWfk59YKD8v8zBzU//t4KNfwq1gSQLk9Vr/jxpv8PDT9qHySFZx13QA
# eqcY1//JRZp65f9cWAAclf4G1nz6Q90TA0HODMo4PvT8GXsBxpfGSoTsp4k0vYh1
# Fx2nwMbgoFbI02bY8gQkWdwe2zA++SIRh04jij0lLXSIYofTHzwon2o7ZKDBP7+A
# nmXEQyCvgZefbAbJPsDyqLjPap99bo2qxDH1s19267ipNz0QEi14+qHFQalD2FQ6
# yTKMit7emF1kXODV2YFgBNbMlCEA+8OXJzMpsQZcnXaE2xWCW0lkbvDwSuR/gmr0
# raiKkYLuRRMWHUdQHIGpuLR7I1nHjlbyLbgj2TMpYFV23ZbLMMmo7QZU16+L7xGn
# kwh7WAFH5bWx5Dp3ruR+NAumk31aT9h2vvJOQwDpvLLwfcWLobfqKvRSTeaTAG10
# 4OWIVZgS9+pZ7gc6+QFAHxbMd6zCZHYZ18ZKtgVK/VWHn5KS6aDqwlcGJEVGrVhg
# qCCLuavAOR/hKHyFZrLqRExkfW34/aXK3GhPRjXvz1d6+kQp7ueelGbs3UY5Z21Y
# BT6QAhrTN01yzTptoYIDbDCCA2gGCSqGSIb3DQEJBjGCA1kwggNVAgEBMG8wWzEL
# MAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMT
# KEdsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gU0hBMzg0IC0gRzQCEAFIkD3C
# irynoRlNDBxXuCkwCwYJYIZIAWUDBAIBoIIBPTAYBgkqhkiG9w0BCQMxCwYJKoZI
# hvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMzAxMTgyMTEwNTFaMCsGCSqGSIb3DQEJ
# NDEeMBwwCwYJYIZIAWUDBAIBoQ0GCSqGSIb3DQEBCwUAMC8GCSqGSIb3DQEJBDEi
# BCAd97BNc1oq6Kw6sDeV4KWbvtZ+avN7mRtNVIDaFkyk5DCBpAYLKoZIhvcNAQkQ
# AgwxgZQwgZEwgY4wgYsEFDEDDhdqpFkuqyyLregymfy1WF3PMHMwX6RdMFsxCzAJ
# BgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhH
# bG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTM4NCAtIEc0AhABSJA9woq8
# p6EZTQwcV7gpMA0GCSqGSIb3DQEBCwUABIIBgAGnxFWC1wU9K6ECpZaU8SzbQCTw
# 6ZOF0WIjO9IrlkmYYupyf1h+Ol+6AAzfZ5B2p60JxdIptem1rCGTtsOGBr1wi7YV
# y3gCtPZkFeUStHTVKLgqc95NP8SNWHRFuxjqMLNpbovfFOIhsSAOCNXZ/Fv5pkRg
# QuwF/DnzsTeS6sRa0vmpeAkN90IO/8jlQIsafluuGuJ5AzUg1qTAsRWLi6x8DKS6
# GOIAtRUtwSzK17jI9l5CnSvS1q7ClZtWtl1k997A9g1q6s+R1cKzgH5cwsDfBoRw
# vHiqfWOIG5cmT6SIVpBLYL9yF+yZyjS0Av6MHe9ZLsec5Rt/oB6WrMFl4BoydOpW
# +9fEPmvOoliVYrSMGyi014QnCN38p3r7dVbapnzVbTjSG/7VqYwNLETccmeMwXXk
# d9fLs4j6t0WMB6PdoqUnBfdlmg2xlfosS0dKjpNVb804IMEkTv1vVI2gxemB15lj
# zM5gTPIsxn5210133owy8B39yfuQJ9kxy0TBKA==
# SIG # End signature block
