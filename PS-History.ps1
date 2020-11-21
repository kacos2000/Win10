# Get read PowerShell History file(s) from the current user's profile

$logpath = "$($env:APPDATA)\Microsoft\Windows\PowerShell\PSReadline\"
$logfiles = get-childitem -path $logpath -filter "*history*.txt" -Force -ErrorAction SilentlyContinue

$logentries = if($logfiles.count -ge 1){
              foreach($log in $logfiles){
                            Write-Output ""
                            Write-Output "--------------------------------------------"
                            Write-Output "$($log) - Creation Time: $($log.CreationTime)"
                            Write-Output "$($log) - Creation Time: $($log.LastWriteTime)"
                            Write-Output "$($log) - Creation Time: $($log.LastAccessTime)"
                            Write-Output "--------------------------------------------"
                            Write-Output "Entries from $($log)"
                            Write-Output "--------------------------------------------"
                            Write-Output ""
                            $read = New-Object System.IO.StreamReader($log.FullName)
                            [int]$i = 1
                                
                                while(!$read.EndOfStream ) {
                                    $line = $read.ReadLine()
                                    Write-Output "($($i)) $($line)"
                                    $i++
                                }
                               
                            
                            $read.Close()
                            $read.Dispose()
                        }
   }
$logentries