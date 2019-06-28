-- Ref: https://boncaldoforensics.wordpress.com/2018/10/07/all-installed-apps-artifact-windows-10-forensics/
-- Windows Store applications
-- C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine.srd

Select 
Application._ApplicationID as 'AppID',
Application.ApplicationType as 'Type',
Package.PackageType,
Application.Subsystem,
Application."Package",
Application.DisplayName,
Application.Description,
CacheApplication.PackageRelativeApplicationId,
Application.ApplicationUserModelId,
Application.Executable,
Application.StartPage,
Application.PackageRelativeApplicationId,
Application.LockScreenNotification,
CachePackage.InstalledLocation,
datetime((PackageUser.InstallTime - 116444736000000000)/10000000, 'unixepoch') as 'PackageUserInstallTime',
PackageUser.OSVersionWhenInstalled,
datetime((PackageFamilyUser.WhenInstalled - 116444736000000000)/10000000, 'unixepoch') as 'PackageFamilyUserWhenInstalled' 


from Application
join Package on Package._PackageID = Application."Package"
join CacheApplication on CacheApplication._CacheApplicationID = Application._ApplicationID
join CachePackage on CachePackage._CachePackageID = CacheApplication."Package"
join MrtApplication on MrtApplication."Application" = Application._ApplicationID
join PackageUser on PackageUser."Package" = Application."Package"
left join PackageFamilyUser on PackageFamilyUser."PackageFamily" = Package."PackageFamily"

order by InstallTime desc