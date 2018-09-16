# Prompt user to select one of the available drive letters
$drives = gwmi Win32_LogicalDisk|select-object -property DeviceID
$drive = $drives|Out-GridView  -Title 'Please select a drive letter' -OutputMode Single 
$drive=$drive.deviceID 
Write-Host "(NTFS.ps1):" -f Yellow -nonewline; write-host " Selected drive: ($drive)" -f White

$fs = @("fsinfo", "ntfsinfo" ,"$($drive)")
$ntfsinfo = (&fsutil $fs|ConvertFrom-String -Delimiter '\u003a' -PropertyNames 'Title', 'Value')

$results =  [PSCustomObject]@{ 
	                    'NTFS Volume Serial Number'       = (([Convert]::ToString($ntfsinfo[0].value,16)).ToUpper() -replace '(....)','$1-').trim('-')
	                    'NTFS Version'                    = $ntfsinfo[1].value
                        'LFS Version'                     = $ntfsinfo[2].value
                        'Number Sectors '                 = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[3].value,16),16))
                        'Total Clusters'                  = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[4].value,16),16))
                        'Free Clusters'                   = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[5].value,16),16))
                        'Total Reserved'                  = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[6].value,16),16))
                        'Bytes Per Sector'                = $ntfsinfo[7].value
                        'Bytes Per Physical Sector'       = $ntfsinfo[8].value
                        'Bytes Per Cluster'               = $ntfsinfo[9].value
                        'Bytes Per FileRecord Segment'    = $ntfsinfo[10].value
                        'Clusters Per FileRecord Segment' = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[11].value,16),16))
                        'Mft Valid Data Length'           = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[12].value,16),16))
                        'Mft Start Lcn'                   = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[13].value,16),16))
                        'Mft2 Start Lcn'                  = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[14].value,16),16))
                        'Mft Zone Start'                  = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[15].value,16),16))
                        'Mft Zone End'                    = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[16].value,16),16))
                        'Max Device Trim Extent Count'    = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[17].value,16),16))
                        'Max Device Trim Byte Count'      = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[18].value,16),16))
                        'Max Volume Trim Extent Count'    = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[19].value,16),16))
                        'Max Volume Trim Byte Count'      = '{0:N0}' -f ([Convert]::ToInt64("0x"+[Convert]::ToString($ntfsinfo[20].value,16),16))
                    	}

#Output results 
$results
