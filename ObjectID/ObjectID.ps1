#Requires -RunAsAdministrator
Clear-Host
# Check Validity of script
if ((Get-AuthenticodeSignature $MyInvocation.MyCommand.Path).Status -ne "Valid")
{
	
	$check = [System.Windows.Forms.MessageBox]::Show($this, "WARNING:`n$(Split-path $MyInvocation.MyCommand.Path -Leaf) has been modified since it was signed.`nPress 'YES' to Continue or 'No' to Exit", "Warning", 'YESNO', 48)
	switch ($check)
	{
		"YES"{ Continue }
		"NO"{ Exit }
	}
}
# Show a Select Folder Dialog and return the folder selected by the user
Function Get-Folder($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.rootfolder = "MyComputer"
	$foldername.Description = "Select a directory to scan files for ObjectIDs"
	$foldername.ShowNewFolderButton = $false
	
    if($foldername.ShowDialog() -eq "OK")
		{$folder += $foldername.SelectedPath}else  
        {Write-Host "(ObjectID.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
		exit}
    return $Folder}

$Folder = Get-Folder
Write-Host "(ObjectID.ps1):" -f Yellow -nonewline; write-host " Selected directory: ($Folder)" -f White

#Enumerate the files in the selected folder ( if -recurse below, recursively)
$Files = Get-ChildItem -Path $Folder -File -ErrorAction SilentlyContinue # can add '-Recurse' here
$fcount = $Files.Count
$i=$null

# Get offsets from 1582 & 1601
$1582offset = (New-Object DateTime(1582, 10, 15, 0, 0, 0)).Ticks
$1601offset = (New-Object DateTime(1601, 1, 1, 0, 0, 0)).Ticks
			  
#Create output:
$results = ForEach  ($File in $Files) {$i++

    $fs = @("objectid", "query" ,"$($file.FullName)")
    $ob = &fsutil $fs
    if($ob -like 'Object ID*'){$ob|ConvertFrom-String -Delimiter '\u002c' -PropertyNames 'Object ID', 'BirthVolume ID','BirthObject ID','Domain ID' }

	#Progress Report
    Write-Progress -Activity "Collecting information for File: $($file)" -Status "File $i of $($fCount))" -PercentComplete (($i / $fCount)*100)

    # Get the GUIDs + MAC Addresses + Timestamps:
        # Object ID
	    $objectid = if($ob -like 'Object ID*'){$ob[0].SubString(19)}else{''}
        if(![String]::IsNullOrEmpty($objectid)){
                        $version  = [Convert]::ToUInt64("0x$(($objectid.tostring()).Substring(14, 1))", 16)
						$vs       = [convert]::ToString("0x$(($objectid.tostring()).Substring(19, 4))", 2)
						$variant  = [Convert]::ToInt16($vs.Substring(0, 2), 2)
						$Sequence = [Convert]::ToInt16($vs.PadLeft(16,'0').Substring(2, 14), 2)
                        if (($objectid.tostring()).Substring(14, 1) -eq 1)
							{
								# Format MAC
								$mac = ((($objectid.tostring()).Substring(20, 12) -split "(..)" -ne "") -join ":").ToUpper()
								# Get the Date
								# Get the first 16 bytes 
								$tm = $objectid.tostring().substring(0,16)
								# Replace the Version nimmble (14) with 0
								$tm = $tm.Remove(14, 1).Insert(14, '0')
								# Reverse Endianess
								$tm = $tm -split "(..)" -ne ""
								[Array]::Reverse($tm)
								$tm = $tm -join ""
								# Convert to Decimal
								$timedec = [Convert]::ToUInt64("0x$($tm)", 16)
								# Calculate the Date after substracting the two Date offsets
								$ObjectIdCreated = [datetime]::FromFileTimeUtc($timedec - ($1601offset - $1582offset)).ToString("dd/MM/yyyy HH:mm:ss.fffffff")
                             }else{$mac = $ObjectIdCreated = $null}
                        $objectid = ([guid]$objectid).guid.ToUpper()
                      }else{$objectid = $version = $variant = $Sequence = $mac = $ObjectIdCreated = $null}

        # Birth Volume ID
        $birthvolumeid = if($ob -like 'BirthVolume ID*'){$ob[1].SubString(19)}else{''}
                if(![String]::IsNullOrEmpty($birthvolumeid)){
                        $bvversion  = [Convert]::ToUInt64("0x$(($birthvolumeid.tostring()).Substring(14, 1))", 16)
						$bvvs       = [convert]::ToString("0x$(($birthvolumeid.tostring()).Substring(19, 4))", 2)
						$bvvariant  = [Convert]::ToInt16($bvvs.Substring(0, 2), 2)
						$bvSequence = [Convert]::ToInt16($bvvs.PadLeft(16,'0').Substring(2, 14), 2)
                        $birthvolumeid = ([guid]$birthvolumeid).guid.ToUpper()
                      }else{$bvobjectid = $bvversion = $bvvariant = $bvSequence = $bvmac = $bvObjectIdCreated = $null}

        # Birth ObjectID
        $birthobjectid = if($ob -like 'BirthObjectId ID*'){$ob[2].SubString(19)}else{''}
                if(![String]::IsNullOrEmpty($birthobjectid)){
                        $boversion  = [Convert]::ToUInt64("0x$(($birthobjectid.tostring()).Substring(14, 1))", 16)
						$bovs       = [convert]::ToString("0x$(($birthobjectid.tostring()).Substring(19, 4))", 2)
						$bovariant  = [Convert]::ToInt16($bovs.Substring(0, 2), 2)
						$boSequence = [Convert]::ToInt16($bovs.PadLeft(16,'0').Substring(2, 14), 2)
                        if (($birthobjectid.tostring()).Substring(14, 1) -eq 1)
							{
								# Format MAC
								$bomac = ((($birthobjectid.tostring()).Substring(20, 12) -split "(..)" -ne "") -join ":").ToUpper()
								# Get the Date
								# Get the first 16 bytes 
								$botm = $birthobjectid.tostring().substring(0,16)
								# Replace the Version nimmble (14) with 0
								$botm = $botm.Remove(14, 1).Insert(14, '0')
								# Reverse Endianess
								$botm = $botm -split "(..)" -ne ""
								[Array]::Reverse($tm)
								$botm = $botm -join ""
								# Convert to Decimal
								$botimedec = [Convert]::ToUInt64("0x$($tm)", 16)
								# Calculate the Date after substracting the two Date offsets
								$boObjectIdCreated = [datetime]::FromFileTimeUtc($botimedec - ($1601offset - $1582offset)).ToString("dd/MM/yyyy HH:mm:ss.fffffff")
                        }else{$bomac = $boObjectIdCreated = $null}
                        $birthobjectid = ([guid]$birthobjectid.ToUpper()).guid.ToUpper()
                      }else{$boobjectid = $boversion = $bovariant = $boSequence = $bomac = $boObjectIdCreated = $null}

          <#  $Domainid = if($ob -like 'Domain ID*'){([System.GUID]::Parse($ob[3].substring(19)).guid).ToUpper()}else{''} # Unused in NTFS #>


	[PSCustomObject]@{ 
	         Parent          = $file.DirectoryName
	        'File Name'      = $File.Name 
    	    'ObjectID'       = $objectid
            'BirthVolume ID' = $birthvolumeid
            'BirthObject ID' = $birthobjectid
             MAC_Address             = $mac
             BirthObjID_MAC          = $bomac
             ObjectID_Created        = $ObjectIdCreated
             BirthObjID_Created      = $boObjectIdCreated
             ObjID_Version           = $version
             BirthVolID_Version      = $bvversion
             BirthObjID_version      = $boversion 
             ObjID_Variant           = $variant
             BirthVol_Variant        = $bvvariant
             BirthObjID_variant      = $bovariant
             ObjID_Sequence          = $Sequence
             BirthVolume_ID_Sequence = $bvSequence
             BirthObjID_sequence     = $boSequence
            }
 }


#Output results 
$results|Out-GridView -PassThru -Title "Results for $($fcount) files in the selected folder: $Folder" 



# SIG # Begin signature block
# MIIsuAYJKoZIhvcNAQcCoIIsqTCCLKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC3pPNjSvgmGPwV
# w3k7rahoKDPd5VadPtOgbkF7Rn9PY6CCJo8wggNfMIICR6ADAgECAgsEAAAAAAEh
# WFMIojANBgkqhkiG9w0BAQsFADBMMSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3Qg
# Q0EgLSBSMzETMBEGA1UEChMKR2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2ln
# bjAeFw0wOTAzMTgxMDAwMDBaFw0yOTAzMTgxMDAwMDBaMEwxIDAeBgNVBAsTF0ds
# b2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWduMRMwEQYD
# VQQDEwpHbG9iYWxTaWduMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# zCV2kHkGeCIW9cCDtoTKKJ79BXYRxa2IcvxGAkPHsoqdBF8kyy5L4WCCRuFSqwyB
# R3Bs3WTR6/Usow+CPQwrrpfXthSGEHm7OxOAd4wI4UnSamIvH176lmjfiSeVOJ8G
# 1z7JyyZZDXPesMjpJg6DFcbvW4vSBGDKSaYo9mk79svIKJHlnYphVzesdBTcdOA6
# 7nIvLpz70Lu/9T0A4QYz6IIrrlOmOhZzjN1BDiA6wLSnoemyT5AuMmDpV8u5BJJo
# aOU4JmB1sp93/5EU764gSfytQBVI0QIxYRleuJfvrXe3ZJp6v1/BE++bYvsNbOBU
# aRapA9pu6YOTcXbGaYWCFwIDAQABo0IwQDAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0T
# AQH/BAUwAwEB/zAdBgNVHQ4EFgQUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZI
# hvcNAQELBQADggEBAEtA28BQqv7IDO/3llRFSbuWAAlBrLMThoYoBzPKa+Z0uboA
# La6kCtP18fEPir9zZ0qDx0R7eOCvbmxvAymOMzlFw47kuVdsqvwSluxTxi3kJGy5
# lGP73FNoZ1Y+g7jPNSHDyWj+ztrCU6rMkIrp8F1GjJXdelgoGi8d3s0AN0GP7URt
# 11Mol37zZwQeFdeKlrTT3kwnpEwbc3N29BeZwh96DuMtCK0KHCz/PKtVDg+Rfjbr
# w1dJvuEuLXxgi8NBURMjnc73MmuUAaiZ5ywzHzo7JdKGQM47LIZ4yWEvFLru21Vv
# 34TuBQlNvSjYcs7TYlBlHuuSl4Mx2bO1ykdYP18wggU8MIIEJKADAgECAhEAuOmi
# FD2zF88Ah+P3NrQWBTANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJHQjEbMBkG
# A1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYD
# VQQKEw9TZWN0aWdvIExpbWl0ZWQxJDAiBgNVBAMTG1NlY3RpZ28gUlNBIENvZGUg
# U2lnbmluZyBDQTAeFw0yMDAyMjAwMDAwMDBaFw0yMjAyMTkyMzU5NTlaMIGsMQsw
# CQYDVQQGEwJHUjEOMAwGA1UEEQwFNTU1MzUxFTATBgNVBAgMDFRoZXNzYWxvbmlr
# aTEPMA0GA1UEBwwGUHlsYWlhMRswGQYDVQQJDBIzMiBCaXphbmlvdSBTdHJlZXQx
# IzAhBgNVBAoMGkthdHNhdm91bmlkaXMgS29uc3RhbnRpbm9zMSMwIQYDVQQDDBpL
# YXRzYXZvdW5pZGlzIEtvbnN0YW50aW5vczCCASIwDQYJKoZIhvcNAQEBBQADggEP
# ADCCAQoCggEBANrYLsxxFls8AYtU8JxgKaGptVFUYFUldmGokoVskD3mjbPgCLIH
# sL9xAbLUXdzeNb0FqWne4RICzLomskj6Dra/HOTpyHG1yt7U8+eOp1wNDJ60dEDt
# mx4OcWGToO/ENHR6YEeZ3JwCNareQAJbCQpAAPK5DcPozFGEbcicqS/57U6NWNbz
# MmhujzDF9VWvEMwvxMg67ZDOCkIx/ruBwW3OG2Q1go7S6RKBVnhheu/y16fDmMvF
# H1i/lEoYTXJfNp9TLXtGzGwQgRnHYgYHGZIXYckJJta8Re1xWyWfOa21FL63I0HG
# dcH80rxl/aHXz3jXiaNnL+l9SZMxDBxk4p0CAwEAAaOCAYYwggGCMB8GA1UdIwQY
# MBaAFA7hOqhTOjHVir7Bu61nGgOFrTQOMB0GA1UdDgQWBBQf1fa0p37njQjHLXOe
# /dF/CjJH1zAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAK
# BggrBgEFBQcDAzARBglghkgBhvhCAQEEBAMCBBAwQAYDVR0gBDkwNzA1BgwrBgEE
# AbIxAQIBAwIwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNvbS9DUFMw
# QwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0aWdv
# UlNBQ29kZVNpZ25pbmdDQS5jcmwwcwYIKwYBBQUHAQEEZzBlMD4GCCsGAQUFBzAC
# hjJodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NB
# LmNydDAjBggrBgEFBQcwAYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZI
# hvcNAQELBQADggEBAFtCY3qYnr8V/RzdvMu0oUrFtc9keMdPEHviaqnfwwZ2Ex8+
# xDnYjmsf35v93/qDoEomdPPb3c7Fyhrb36JG7CWMZu/+SSMzzSIAueitRCyT5ED6
# MIn1dOpRuJa1vZnHzbwagITw4nUTICjNVUQDhty76dxwAUN3vxgbKC4Mwdph+daM
# DZHYeRPidhK7a7zT4V5G6h2acHZ1wzz2TRr5eO6EO4bwMlFwja2NFmdHuB5EfBUQ
# UU9z9l0CNFoWkBSAQCsJaggcAy0h/Rb9921ett0h6D2JuZwaIUfvRD9W9pegPH72
# pgt5i8S0AASId+V8USVXZYgL43jsMtnGmQ7sPrwwggVHMIIEL6ADAgECAg0B8kBC
# QM79ItvpbHH8MA0GCSqGSIb3DQEBDAUAMEwxIDAeBgNVBAsTF0dsb2JhbFNpZ24g
# Um9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWduMRMwEQYDVQQDEwpHbG9i
# YWxTaWduMB4XDTE5MDIyMDAwMDAwMFoXDTI5MDMxODEwMDAwMFowTDEgMB4GA1UE
# CxMXR2xvYmFsU2lnbiBSb290IENBIC0gUjYxEzARBgNVBAoTCkdsb2JhbFNpZ24x
# EzARBgNVBAMTCkdsb2JhbFNpZ24wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
# AoICAQCVB+hzymb57BTKezz3DQjxtEULLIK0SMbrWzyug7hBkjMUpG9/6SrMxrCI
# a8W2idHGsv8UzlEUIexK3RtaxtaH7k06FQbtZGYLkoDKRN5zlE7zp4l/T3hjCMgS
# UG1CZi9NuXkoTVIaihqAtxmBDn7EirxkTCEcQ2jXPTyKxbJm1ZCatzEGxb7ibTIG
# ph75ueuqo7i/voJjUNDwGInf5A959eqiHyrScC5757yTu21T4kh8jBAHOP9msndh
# fuDqjDyqtKT285VKEgdt/Yyyic/QoGF3yFh0sNQjOvddOsqi250J3l1ELZDxgc1X
# kvp+vFAEYzTfa5MYvms2sjnkrCQ2t/DvthwTV5O23rL44oW3c6K4NapF8uCdNqFv
# VIrxclZuLojFUUJEFZTuo8U4lptOTloLR/MGNkl3MLxxN+Wm7CEIdfzmYRY/d9XZ
# kZeECmzUAk10wBTt/Tn7g/JeFKEEsAvp/u6P4W4LsgizYWYJarEGOmWWWcDwNf3J
# 2iiNGhGHcIEKqJp1HZ46hgUAntuA1iX53AWeJ1lMdjlb6vmlodiDD9H/3zAR+YXP
# M0j1ym1kFCx6WE/TSwhJxZVkGmMOeT31s4zKWK2cQkV5bg6HGVxUsWW2v4yb3BPp
# DW+4LtxnbsmLEbWEFIoAGXCDeZGXkdQaJ783HjIH2BRjPChMrwIDAQABo4IBJjCC
# ASIwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFK5s
# BaOTE+Ki5+LXHNbH8H/IZ1OgMB8GA1UdIwQYMBaAFI/wS3+oLkUkrk1Q+mOai97i
# 3Ru8MD4GCCsGAQUFBwEBBDIwMDAuBggrBgEFBQcwAYYiaHR0cDovL29jc3AyLmds
# b2JhbHNpZ24uY29tL3Jvb3RyMzA2BgNVHR8ELzAtMCugKaAnhiVodHRwOi8vY3Js
# Lmdsb2JhbHNpZ24uY29tL3Jvb3QtcjMuY3JsMEcGA1UdIARAMD4wPAYEVR0gADA0
# MDIGCCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0
# b3J5LzANBgkqhkiG9w0BAQwFAAOCAQEASaxexYPzWsthKk2XShUpn+QUkKoJ+cR6
# nzUYigozFW1yhyJOQT9tCp4YrtviX/yV0SyYFDuOwfA2WXnzjYHPdPYYpOThaM/v
# f2VZQunKVTm808Um7nE4+tchAw+3TtlbYGpDtH0J0GBh3artAF5OMh7gsmyePLLC
# u5jTkHZqaa0a3KiJ2lhP0sKLMkrOVPs46TsHC3UKEdsLfCUn8awmzxFT5tzG4mE1
# MvTO3YPjGTrrwmijcgDIJDxOuFM8sRer5jUs+dNCKeZfYAOsQmGmsVdqM0LfNTGG
# yj43K9rE2iT1ThLytrm3R+q7IK1hFregM+Mtiae8szwBfyMagAk06TCCBd4wggPG
# oAMCAQICEAH9bTD8o8pRqBu8ZA41Ay0wDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0
# eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VS
# VHJ1c3QgUlNBIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTEwMDIwMTAwMDAw
# MFoXDTM4MDExODIzNTk1OVowgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpOZXcg
# SmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJU
# UlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRpZmljYXRp
# b24gQXV0aG9yaXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAgBJl
# FzYOw9sIs9CsVw127c0n00ytUINh4qogTQktZAnczomfzD2p7PbPwdzx07HWezco
# EStH2jnGvDoZtF+mvX2do2NCtnbyqTsrkfjib9DsFiCQCT7i6HTJGLSR1GJk23+j
# BvGIGGqQIjy8/hPwhxR79uQfjtTkUcYRZ0YIUcuGFFQ/vDP+fmyc/xadGL1RjjWm
# p2bIcmfbIWax1Jt4A8BQOujM8Ny8nkz+rwWWNR9XWrf/zvk9tyy29lTdyOcSOk2u
# TIq3XJq0tyA9yn8iNK5+O2hmAUTnAU5GU5szYPeUvlM3kHND8zLDU+/bqv50TmnH
# a4xgk97Exwzf4TKuzJM7UXiVZ4vuPVb+DNBpDxsP8yUmazNt925H+nND5X4OpWax
# KXwyhGNVicQNwZNUMBkTrNN9N6frXTpsNVzbQdcS2qlJC9/YgIoJk2KOtWbPJYjN
# hLixP6Q5D9kCnusSTJV882sFqV4Wg8y4Z+LoE53MW4LTTLPtW//e5XOsIzstAL81
# VXQJSdhJWBp/kjbmUZIO8yZ9HE0XvMnsQybQv0FfQKlERPSZ51eHnlAfV1SoPv10
# Yy+xUGUJ5lhCLkMaTLTwJUdZ+gQek9QmRkpQgbLevni3/GcV4clXhB4PY9bpYrrW
# X1Uu6lzGKAgEJTm4Diup8kyXHAc/DVL17e8vgg8CAwEAAaNCMEAwHQYDVR0OBBYE
# FFN5v1qqK0rPVIDh2JvAnfKyA2bLMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
# BTADAQH/MA0GCSqGSIb3DQEBDAUAA4ICAQBc1HwNz/cBfUGZZQxzxVKfy/jPmQZ/
# G9pDFZ+eAlVXlhTxUjwnh5Qo7R86ATeidvxTUMCEm8ZrTrqMIU+ijlVikfNpFdi8
# iOPEqgv976jpS1UqBiBtVXgpGe5fMFxLJBFV/ySabl4qK+4LTZ9/9wE4lBSVQwcJ
# +2Cp7hyrEoygml6nmGpZbYs/CPvI0UWvGBVkkBIPcyguxeIkTvxY7PD0Rf4is+sv
# jtLZRWEFwZdvqHZyj4uMNq+/DQXOcY3mpm8fbKZxYsXY0INyDPFnEYkMnBNMcjTf
# vNVx36px3eG5bIw8El1l2r1XErZDa//l3k1mEVHPma7sF7bocZGM3kn+3TVxohUn
# lBzPYeMmu2+jZyUhXebdHQsuaBs7gq/sg2eF1JhRdLG5mYCJ/394GVx5SmAukkCu
# TDcqLMnHYsgOXfc2W8rgJSUBtN0aB5x3AD/Q3NXsPdT6uz/MhdZvf6kt37kC9/WX
# mrU12sNnsIdKqSieI47/XCdr4bBP8wfuAC7UWYfLUkGV6vRH1+5kQVV8jVkCld1i
# ncK57loodISlm7eQxwwH3/WJNnQy1ijBsLAL4JxMwxzW/ONptUdGgS+igqvTY0Rw
# xI3/LTO6rY97tXCIrj4Zz0Ao2PzIkLtdmSL1UuZYxR+IMUPuiB3Xxo48Q2odpxje
# fT0W8WL5ypCo/TCCBfUwggPdoAMCAQICEB2iSDBvmyYY0ILgln0z02owDQYJKoZI
# hvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5MRQw
# EgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3
# b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRpZmljYXRpb24gQXV0aG9y
# aXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIzNTk1OVowfDELMAkGA1UEBhMC
# R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
# ZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJT
# QSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilAhlRGdDFixRDtsocnppnLlTDA
# VvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6DBmJqGx7rQDDYaHcaWVtH24n
# lteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpyvjg7Y96Pv25MQV0SIAhZ6DnN
# j9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52BxHJAteJf7wtF/6POF6YtVbC3
# sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G2flGHNyMfHEo8/6nxhTdVZFu
# ihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIBYDAfBgNVHSMEGDAWgBRTeb9a
# qitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6qFM6MdWKvsG7rWcaA4WtNA4w
# DgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0lBBYwFAYI
# KwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBH
# MEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2Vy
# dGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYBBQUHAQEEajBoMD8GCCsGAQUF
# BzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQWRkVHJ1
# c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20w
# DQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNveaiqMm/EAAB4dYns61zLC9rPg
# Y7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS9At3WpwqQTr81vTr5/cVlTPD
# oYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3ZLCmI2pZaFJCX/8E6+F0ZXkI
# 9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1fqW4w2y1z99KeYdcx0BNYzX2
# MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6fICUQDRn7UJBhvjmPeo5N9p8O
# Hv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIeQ3pFMcGcTanwWbJZGehqjSkE
# And8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lkuk/xYpMoJVcp+1EZx6ElQGqE
# V8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9V1DSyt39ngVR5UR43QHesXWY
# DVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoKC6W59J7umDIFhZ7r+YMp08Ys
# fb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLjtXX4oemOCiUe5B7xn1qHI/+f
# pFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1qV3AcPKRYLqPzW0sH3DJZ84en
# Gm1YMIIGWTCCBEGgAwIBAgINAewckkDe/S5AXXxHdDANBgkqhkiG9w0BAQwFADBM
# MSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3QgQ0EgLSBSNjETMBEGA1UEChMKR2xv
# YmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2lnbjAeFw0xODA2MjAwMDAwMDBaFw0z
# NDEyMTAwMDAwMDBaMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWdu
# IG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNI
# QTM4NCAtIEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA8ALiMCP6
# 4BvhmnSzr3WDX6lHUsdhOmN8OSN5bXT8MeR0EhmW+s4nYluuB4on7lejxDXtszTH
# rMMM64BmbdEoSsEsu7lw8nKujPeZWl12rr9EqHxBJI6PusVP/zZBq6ct/XhOQ4j+
# kxkX2e4xz7yKO25qxIjw7pf23PMYoEuZHA6HpybhiMmg5ZninvScTD9dW+y279Jl
# z0ULVD2xVFMHi5luuFSZiqgxkjvyen38DljfgWrhsGweZYIq1CHHlP5CljvxC7F/
# f0aYDoc9emXr0VapLr37WD21hfpTmU1bdO1yS6INgjcZDNCr6lrB7w/Vmbk/9E81
# 8ZwP0zcTUtklNO2W7/hn6gi+j0l6/5Cx1PcpFdf5DV3Wh0MedMRwKLSAe70qm7uE
# 4Q6sbw25tfZtVv6KHQk+JA5nJsf8sg2glLCylMx75mf+pliy1NhBEsFV/W6Rxbux
# TAhLntRCBm8bGNU26mSuzv31BebiZtAOBSGssREGIxnk+wU0ROoIrp1JZxGLguWt
# WoanZv0zAwHemSX5cW7pnF0CTGA8zwKPAf1y7pLxpxLeQhJN7Kkm5XcCrA5XDAnR
# YZ4miPzIsk3bZPBFn7rBP1Sj2HYClWxqjcoiXPYMBOMp+kuwHNM3dITZHWarNHOP
# Hn18XpbWPRmwl+qMUJFtr1eGfhA3HWsaFN8CAwEAAaOCASkwggElMA4GA1UdDwEB
# /wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBTqFsZp5+PLV0U5
# M6TwQL7Qw71lljAfBgNVHSMEGDAWgBSubAWjkxPioufi1xzWx/B/yGdToDA+Bggr
# BgEFBQcBAQQyMDAwLgYIKwYBBQUHMAGGImh0dHA6Ly9vY3NwMi5nbG9iYWxzaWdu
# LmNvbS9yb290cjYwNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5nbG9iYWxz
# aWduLmNvbS9yb290LXI2LmNybDBHBgNVHSAEQDA+MDwGBFUdIAAwNDAyBggrBgEF
# BQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wDQYJ
# KoZIhvcNAQEMBQADggIBAH/iiNlXZytCX4GnCQu6xLsoGFbWTL/bGwdwxvsLCa0A
# OmAzHznGFmsZQEklCB7km/fWpA2PHpbyhqIX3kG/T+G8q83uwCOMxoX+SxUk+RhE
# 7B/CpKzQss/swlZlHb1/9t6CyLefYdO1RkiYlwJnehaVSttixtCzAsw0SEVV3ezp
# Sp9eFO1yEHF2cNIPlvPqN1eUkRiv3I2ZOBlYwqmhfqJuFSbqtPl/KufnSGRpL9Ka
# oXL29yRLdFp9coY1swJXH4uc/LusTN763lNMg/0SsbZJVU91naxvSsguarnKiMMS
# ME6yCHOfXqHWmc7pfUuWLMwWaxjN5Fk3hgks4kXWss1ugnWl2o0et1sviC49ffHy
# kTAFnM57fKDFrK9RBvARxx0wxVFWYOh8lT0i49UKJFMnl4D6SIknLHniPOWbHuOq
# hIKJPsBK9SH+YhDtHTD89szqSCd8i3VCf2vL86VrlR8EWDQKie2CUOTRe6jJ5r5I
# qitV2Y23JSAOG1Gg1GOqg+pscmFKyfpDxMZXxZ22PLCLsLkcMe+97xTYFEBsIB3C
# LegLxo1tjLZx7VIh/j72n585Gq6s0i96ILH0rKod4i0UnfqWah3GPMrz2Ry/U02k
# R1l8lcRDQfkl4iwQfoH5DZSnffK1CfXYYHJAUJUg1ENEvvqglecgWbZ4xqRqqiKb
# MIIGZTCCBE2gAwIBAgIQARh4g+/0PkBCzMWBmgW5hzANBgkqhkiG9w0BAQsFADBb
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTExMC8GA1UE
# AxMoR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBTSEEzODQgLSBHNDAeFw0y
# MTAxMjgxMTA0MTdaFw0zMjAzMDExMTA0MTdaMGMxCzAJBgNVBAYTAkJFMRkwFwYD
# VQQKDBBHbG9iYWxTaWduIG52LXNhMTkwNwYDVQQDDDBHbG9iYWxzaWduIFRTQSBm
# b3IgTVMgQXV0aGVudGljb2RlIGFkdmFuY2VkIC0gRzQwggGiMA0GCSqGSIb3DQEB
# AQUAA4IBjwAwggGKAoIBgQCmldNJa1iNrSwdYCWQIlzOw411VUeFx0v3Z/BZAGtU
# uuqldXzT3+kAAD/QKLC3OQA3BhOaV0yGNsNkrGk8XUtQjtU5EQN+XRrmC6JAky8c
# ZcU9BtiyjClZFkcBDeiOUeNCGpYybmdl+qVK2iFKyZFv5cVSF5GQqVsaOUZNYu1N
# B+V0TPEqD1fwsnhyv6Gp0ePEEkVTYY7MfuGqqi9kJWH+Y1P1+DQtTNuudRjYVRPB
# ks30Bbt6Uei+FPH5eFX8FLz4zEYiD/ZvK46dZ0ARFU8mqJMsa0sDguKCgERJzbmC
# GpR58N2OQABlaF5c7aw4iGi1S90AR1f+QIWHfVgKqwJDh4uZpuynRjfkCaqQqJqD
# v0Aa7/gr21ulDe4KsrgSTh7P/M6iFVe7MsqzEz6gUVy3pwYq3WQXCx+VT7s7+FrJ
# lvnnP7srcocSlVENATYoE+bQnYJpGBI1KOXGtgMZe2sfh9bbDvDDbK6CQm7ofS8L
# 0rtkCpNg1poICC1OszgmHg0CAwEAAaOCAZswggGXMA4GA1UdDwEB/wQEAwIHgDAW
# BgNVHSUBAf8EDDAKBggrBgEFBQcDCDAdBgNVHQ4EFgQUDxGEOp3Lpd/Y+nl6Ke+f
# B5sCvSwwTAYDVR0gBEUwQzBBBgkrBgEEAaAyAR4wNDAyBggrBgEFBQcCARYmaHR0
# cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADCB
# kAYIKwYBBQUHAQEEgYMwgYAwOQYIKwYBBQUHMAGGLWh0dHA6Ly9vY3NwLmdsb2Jh
# bHNpZ24uY29tL2NhL2dzdHNhY2FzaGEzODRnNDBDBggrBgEFBQcwAoY3aHR0cDov
# L3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvZ3N0c2FjYXNoYTM4NGc0LmNy
# dDAfBgNVHSMEGDAWgBTqFsZp5+PLV0U5M6TwQL7Qw71lljBBBgNVHR8EOjA4MDag
# NKAyhjBodHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2NhL2dzdHNhY2FzaGEzODRn
# NC5jcmwwDQYJKoZIhvcNAQELBQADggIBAJEZBqYh1viB1DggucoVJ9jTvKMuJHym
# I/KJV1XVfW2q3Q1kumJUOK46IzHX39DSYrAP3jiB/ZNG6ZZ+znENgm2ZB7rfxje9
# qH4YlkY8NHNsvPJ9Bjr+6k57MSMceb7ehhXtSGko58szIgSCn6K1SRw9bqaPUODc
# DFZDL0HS/CoAm5M3gzmTmcM10MiEedtPeMGsWDd0vRoMk53+5lHiJ3o7sJc4Is51
# ZEM0reGoYjUloQSz77xKMIXQbeWp7TBE8gqskDFcjr0kapPyFXs1xOJiyQPUpttr
# odZLuUVo904XBuCx9n1+ApDSe+kk+Lr75ETPstv/QXppb/PwcaT0BFl4D3HB3MHt
# hPLPAhPwA1FjlkIaG5xXheFGZavESl4NWy8imgB4uwmbSWMOWiVLLGDivNlHApgZ
# tMfImLkdrb30DONk3rR2jsbN0nfiVTCCwiyKHDC511PxLHTVSLXNWPWvb+xshwWt
# WNaxBguupr2k3j0WeBE4MGwhkx05ecSo6pY92zC5PMFE0P8Rz9Jcn6dPb1U/zxwg
# FB22oAxW+1iC92NeC18PDdLR+DSdN510PCnM6dok5AJggLGSmoGRTEi1ULYu7z9m
# 3enzNw37DUO67RaGhiyU7SdQmSipWXTSxWLuBMM5kiZD5bBFj46e0QPlnkDIkZcU
# HuJtZs6Ou0htMYIFfzCCBXsCAQEwgZEwfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgT
# EkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMP
# U2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25p
# bmcgQ0ECEQC46aIUPbMXzwCH4/c2tBYFMA0GCWCGSAFlAwQCAQUAoEwwGQYJKoZI
# hvcNAQkDMQwGCisGAQQBgjcCAQQwLwYJKoZIhvcNAQkEMSIEIFxYZh0Tky+vAt5j
# +Fdx17TrYXcbeG8reXgmVf6AKOySMA0GCSqGSIb3DQEBAQUABIIBAC5yf9E9DzYB
# Zahgg8v1xrzvkSiq93zAIJ1gdyWU2V3VfD6GG/dI7UKYBI7RccboWBT/0lxYjxAZ
# VyDXS3zgoNuEGfgQRF5e2OoVNJW3p6Si0dNA6bFbzcBYY2UEJ1O4SbGzcBto8oG0
# jN+KaY9Sl/WQ+gS/worU8+X0kwKqKzIqr2YlsghHGMaDlADEH4YoBFQ33US1Y2zv
# nafs8/R3JFML7VNY/tRS68P4N4qoLG+2kqNLO96Wr3vy4S8SsxwX3xGBL0eNYP0V
# vLaIa9ps61GJ3aGTRbjLYSmCEdMEXsehyBzQ5x1LRN72CQY08xSMXAjQXnh/ROiX
# KbM8RkmutcuhggNwMIIDbAYJKoZIhvcNAQkGMYIDXTCCA1kCAQEwbzBbMQswCQYD
# VQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTExMC8GA1UEAxMoR2xv
# YmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBTSEEzODQgLSBHNAIQARh4g+/0PkBC
# zMWBmgW5hzANBglghkgBZQMEAgEFAKCCAT8wGAYJKoZIhvcNAQkDMQsGCSqGSIb3
# DQEHATAcBgkqhkiG9w0BCQUxDxcNMjEwMzE0MDIxNjUzWjAtBgkqhkiG9w0BCTQx
# IDAeMA0GCWCGSAFlAwQCAQUAoQ0GCSqGSIb3DQEBCwUAMC8GCSqGSIb3DQEJBDEi
# BCDntxY8G38btXL2eaaxC5Cc9ChP21cKcXqahwIJkbYspTCBpAYLKoZIhvcNAQkQ
# AgwxgZQwgZEwgY4wgYsEFHCARsJoOLyLBYEfaQ+pq4iBjUj3MHMwX6RdMFsxCzAJ
# BgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhH
# bG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTM4NCAtIEc0AhABGHiD7/Q+
# QELMxYGaBbmHMA0GCSqGSIb3DQEBCwUABIIBgGBOa/dxiiCu7DeyeDpEPkgEKD5r
# L3amDazGuSJpF1ap8cthF2b3kL0/wr7U/e+eVqrAEyIs9p8P3/Aa7qg3RKU7HtRu
# SDsNFIsd8htcuGS7AkD8RnkM5m1/PF2zv/zwDZAOQJ+xRa+fh8dYgugXyvS1SYA3
# dAuU0X0VYQNEZfOsV3WJEaYSmNvZt9yPx6+FQMWzhRNd/3HmlE4drgL0UT9fiR5k
# 5D/Nn8nVoZx+bEenktgRyQgQeq72khjnV7oSWWaqDjhKDPdQoqHPdubgGx86hCyI
# r2O4T22qxT+y8PxSFztbNhGOhfkLLyACgMbHSxuPhVVMl2GxUtD9G3TzrF3mkZ7S
# 61dFNbvEgSHu0PvvZKfQUTUt1gxPNPlmSj/NMARnnQiVVoky2/VIDr4ujqHjMNpz
# CaMZRWc91MRUhmdOoosHMZ9LpFcnJDF6dGYzO2HsLvtYBBg/LR1TpbI0pn0ztJnA
# Pex3m3icUNTHyvjEwf5Y5SJj6v1uaYGN+VoIcA==
# SIG # End signature block
