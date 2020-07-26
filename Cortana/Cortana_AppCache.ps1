clear-host
# Point the script to a folder containing at least one Cortana "AppCache*****.txt" file
# found at:
# $env:LOCALAPPDATA"\Packages\Microsoft.Windows.Cortana_cw5n1h2txyewy\LocalState\DeviceSearchCache\"

# Show an Open folder Dialog and return the file selected by the user
Function Get-Folder($initialDirectory="")

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder containing Cortana 'AppCache**.txt' files"
    $foldername.SelectedPath = "$($env:LOCALAPPDATA)\Packages\Microsoft.Windows.Cortana_cw5n1h2txyewy\LocalState\DeviceSearchCache\"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }else{ Write-warning "User Cancelled"; Exit}
    return $folder
}

$Folder = Get-Folder
write-host "Selected folder: " -f Yellow
Write-Host $folder -f White
# Get AppCache files
$AppcacheFiles = Get-ChildItem $Folder -Filter AppCache*.txt
if($AppcacheFiles.Count -lt 1){Write-warning "No 'AppCache**.txt' files found"; Exit}
[void][System.Text.Encoding]::utf8    
write-host "Files found:" -f Yellow
write-host $AppcacheFiles.name -f White
# Read the files   
$Apps = foreach($Appcache in $AppcacheFiles){
                (Get-Content $Appcache.fullname -encoding utf8 | Out-String | ConvertFrom-Json)
                }
       
$list =  foreach($app in $apps){

        $dateaccessed = if(![string]::IsNullOrEmpty($app.'System.DateAccessed'.Value) -and
                            $app.'System.DateAccessed'.Value -ne 0){
                             [datetime]::FromFileTime([bigint]($app.'System.DateAccessed'.Value))
                            }

        if($app.'System.ConnectedSearch.JumpList'.Value -ne"[]" -and (ConvertFrom-Json($app.'System.ConnectedSearch.JumpList'.Value)).items.count -ge 1){
                
                foreach($item in (ConvertFrom-Json($app.'System.ConnectedSearch.JumpList'.Value)).items){
                
                        [pscustomobject]@{
                        ItemNameDisplay = $app.'System.ItemNameDisplay'.value
                        FileName = $app.'System.FileName'.Value
                        TimesUsed = $app.'System.Software.TimesUsed'.Value
                        DateAccessed = if(![string]::IsNullOrEmpty($dateaccessed)){Get-Date $dateaccessed -f s }else{$null}
                        PackageFullName = $app.'System.AppUserModel.PackageFullName'.value
                        PackageType = $app.'System.AppUserModel.PackageFullName'.type
                        ItemType = $app.'System.ItemType'.Value
                        ProductVersion = $app.'System.Software.ProductVersion'.Value
                        ParsingName = $app.'System.ParsingName'.Value
                        Identity = $app.'System.Identity'.Value
                        JumplistType = $app.'System.ConnectedSearch.JumpList'.Type   
                        Type = $item.Type
                        Name = $item.Name
                        Path = $item.Path
                        Description = $item.Description
                        }   
                  }

                }
                else{$item=$null 
        
        [pscustomobject]@{
                ItemNameDisplay = $app.'System.ItemNameDisplay'.value
                FileName = $app.'System.FileName'.Value
                TimesUsed = $app.'System.Software.TimesUsed'.Value
                DateAccessed = if(![string]::IsNullOrEmpty($dateaccessed)){Get-Date $dateaccessed -f s }else{$null}
                PackageFullName = $app.'System.AppUserModel.PackageFullName'.value
                PackageType = $app.'System.AppUserModel.PackageFullName'.type
                ItemType = $app.'System.ItemType'.Value
                ProductVersion = $app.'System.Software.ProductVersion'.Value
                ParsingName = $app.'System.ParsingName'.Value
                Identity = $app.'System.Identity'.Value
                JumplistType = $app.'System.ConnectedSearch.JumpList'.Type
                Type = $null
                Name = $null
                Path = $null
                Description = $null
                } 
             }   
} 

$list|sort -Property DateAccessed -Descending|Out-GridView -PassThru -Title "AppCache.txt info from $($Folder)"

# Save output
$save = Read-Host "Save Output? (Y/N)" 

if ($save -eq 'y') {
    Function Get-FileName($InitialDirectory)
 {
  [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
  $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
  $SaveFileDialog.initialDirectory = $initialDirectory
  $SaveFileDialog.filter = "Comma Separated Values (*.csv)|*.csv|All Files (*.*)|(*.*)"
  $SaveFileDialog.ShowDialog() | Out-Null
  $SaveFileDialog.filename
 }
$outfile = Get-FileName -InitialDirectory "[environment]::GetFolderPath('Desktop')"
if(!$outfile){write-warning "Bye";exit}

	if (!(Test-Path -Path $outfile)) { New-Item -ItemType File -path $outfile| out-null }
	$list | Export-Csv -Delimiter "|" -NoTypeInformation -Encoding UTF8 -Path "$outfile"
	# Invoke-Item (split-path -path $outfile)
}