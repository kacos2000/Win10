SELECT
		phone_apps.app_name as 'Application Name',
		phone_apps.package_name as 'Package_Name',
		phone_apps.version as 'Version',
		settings.setting_group_id as 'groupid',
		settings.setting_type as 'settingstype',
		case settings.setting_value 
				when 0 then 'off'
				when 1 then 'on'
		else settings.setting_value
		end as 'settingsvalue',
		phone_apps.blob as 'Icon',
		phone_apps.etag as 'etag'
from phone_apps
left join settings on 
settings.setting_key = phone_apps.package_name
order by app_name asc