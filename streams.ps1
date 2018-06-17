$Files = Get-ChildItem

Foreach ($File in $Files)
{
	Write-Host "Zone.Identifier Stream contents of "$File.FullName -ForegroundColor Magenta
	Write-Host "Owner :"(Get-Acl $file).owner|Format-List
	$File| Select name, length, lastwritetime, attributes|Format-List
	Get-Content $File -Stream Zone.Identifier -ErrorAction SilentlyContinue|Format-List
	Get-Item $File -Stream Zone.Identifier -ErrorAction SilentlyContinue |Format-List
}
