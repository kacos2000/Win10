#Requires -RunAsAdministrator


# Reference: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/tracerpt_1
#
# Microsoft ® TraceRpt.Exe (10.0.17760.1)
# 
# Usage:
#   C:\WINDOWS\system32\tracerpt.exe <[-l] <value [value [...]]>|-rt <session_name [session_name [...]]>> [options]
# 
# Options:
#   -?                            Displays context sensitive help.
#   -config <filename>            Settings file containing command options.
#   -y                            Answer yes to all questions without prompting.
#   -f <XML|HTML>                 Report format.
#   -of <CSV|EVTX|XML>            Dump format, the default is XML.
#   -en <ANSI|Unicode>            Output file encoding. Only allowed with CSV output format.
#   -df <filename>                Microsoft specific counting/reporting schema file.
#   -import <filename [filename [...]]> Event Schema import file.
#   -int <filename>               Dump interpreted event structure into specified file.
#   -rts                          Report raw timestamp in event trace header.  Can only be used with -o, not -report or -summary.
#   -tmf <filename>               Trace Message Format definition file
#   -tp <value>                   TMF file search path.  Multiple paths can be used, separated with ';'.
#   -i <value>                    Specifies the provider image path.  The matching PDB will be located in the Symbol Server. Multiple
#                                 paths can be used, separated with ';'.
#   -pdb <value>                  Specifies the symbol server path.  Multiple paths can be used, separated with ';'.
#   -gmt                          Convert WPP payload timestamps to GMT time
#   -rl <value>                   System Report Level from 1 to 5, the default value is 1.
#   -summary [filename]           Summary report text file. Default is summary.txt.
#   -o [filename]                 Text output file. Default is dumpfile.xml.
#   -report [filename]            Text output report file. Default is workload.xml.
#   -lr                           Less restrictive; use best effort for events not matching event schema.
#   -export [filename]            Event Schema export file. Default is schema.man.
#   [-l] <value [value [...]]>    Event Trace log file to process.
#   -rt <session_name [session_name [...]]> Real-time Event Trace Session data source.
# 
# Examples:
#   tracerpt logfile1.etl logfile2.etl -o logdump.xml -of XML
#   tracerpt logfile.etl -o logdmp.xml -of XML -lr -summary logdmp.txt -report logrpt.xml
#   tracerpt logfile1.etl logfile2.etl -o -report
#   tracerpt logfile.etl counterfile.blg -report logrpt.xml -df schema.xml
#   tracerpt -rt "NT Kernel Logger" -o logfile.csv -of CSV



# Show an Open File Dialog and return the Folder selected by the user
# Default folder is c:\Windows\System32\WDI so if you
# want to get the results from your own system, just press OK
#
Function Get-Folder($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.SelectedPath = "C:\Windows\System32\WDI"
	$foldername.Description = "Select the location of WDI (\Windows\System32\WDI)"
	$foldername.ShowNewFolderButton = $false
	
    if($foldername.ShowDialog() -eq "OK")
		{$folder += $foldername.SelectedPath}else  
        {Write-Host "(WDI.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White
		 exit}
    return $Folder}

$F = Get-Folder +"\"
$Folder = $F +"\"
$DesktopPath = ($Env:WinDir+"\Windows\System32\WDI")

#Set the Logfile Folder path 
$sub = (Get-ChildItem $Folder).pschildname

#Get the Logfiles directory
$logfiles = ForEach($o in $sub){if ($o -eq 'Logfiles'){$Folder+$o}}

#Get all ETL files
$Folders = (Get-ChildItem -Path $folder -ErrorAction Ignore -recurse)
#Get the Log filenames 
$Lfiles = $Folders.pspath.replace('Microsoft.PowerShell.Core\FileSystem::','')


#Output Folder (at User's  Desktop)
$Lfolder = $env:userprofile + "\desktop\WDI_"+ (Get-Date -Format "dd-MM-yyyy hh-mm")+"\Logfiles"
New-Item -ItemType Directory -Force -Path $Lfolder 
Set-Location -Path $Lfolder 

$l=$null

#Run Tracerpt command against all ETL log files
foreach($lf in $Lfiles){$l++
                        $Lfilename = $lf -replace '\..*'|split-path -Leaf
                        $path = $lf|split-path -Resolve
                        $Trace = ("$($path)\$($Lfilename).etl","-summary", "$($Lfilename)_$($l).txt","-gmt","-o", "$($Lfilename)_$($l).csv","-of","csv")
                        &tracerpt $Trace
                        }

Copy-Item "$($logfiles)\StartupInfo" -Destination $Lfolder -Recurse -force





[gc]::Collect()

