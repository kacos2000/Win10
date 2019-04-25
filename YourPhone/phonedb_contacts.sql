-- C:\Users\%username%\AppData\Local\Packages\Microsoft.YourPhone_8wekyb3d8bbwe\LocalCache\Indexed\<GUID>\System\Database\Phone.db


select 

Contact.contact_id,
contact.display_name,
contact.alternative_name,
contact.nicknames,
case when contact.last_updated_time notnull then datetime((contact.last_updated_time /10000000)-11644473600, 'unixepoch','localtime') end as 'Last_Updated',
address.address,
address.address_type, 
case address.is_primary when 0 then 'No' when 1 then 'Yes' end as 'Is_Primary',
address.times_contacted,
case when contact.last_contacted_time notnull then datetime((contact.last_contacted_time /10000000)-11644473600, 'unixepoch','localtime') end as 'Last_Contacted'

from contact 
left join address on  address.contact_id = contact.contact_id
order by address.times_contacted desc