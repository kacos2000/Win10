-- C:\Users\%username%\AppData\Local\Packages\Microsoft.YourPhone_8wekyb3d8bbwe\LocalCache\Indexed\<GUID>\System\Database\Phone.db
-- SMS & MMS

select  
		coalesce(message.Message_id, mms.message_id) as 'MessageID',
		coalesce(message.Thread_id, mms.thread_id) as 'ThreadId',
		coalesce(datetime ((message.timestamp /10000000)-11644473600, 'unixepoch', 'localtime'),
					datetime ((mms.timestamp /10000000)-11644473600, 'unixepoch', 'localtime')) as 'Time_Stamp',
		coalesce(message.Status, mms.status) as 'Status',
		case  
			coalesce(message.Type,mms.type) 
				when 1 then 'Received' 
				when 2 then 'Sent' 
		end as 'Type',
		coalesce(message.from_address, mms.from_address) as 'From Address',
		case 
			when message.from_address notnull
			then contact.display_name
		end as 'Sender',
		coalesce(message.body, mms_part.text) as 'MessageContent',
		mms_part.blob as 'Attachment', --contants sent attachments
		mms_part.content_type,
		mms_part.content_id,
		--conversation.summary as 'conversation summery', --Not exists in YourPhone 1.19061.410.0
		message_to_address.address as 'To Address',
		case 
			when message_to_address.address notnull
			then contact.display_name 
		end as 'Recipient',
		conversation.msg_count as 'mesgcount',
		case 
			when conversation.unread_count > 0
			then 'Yes'||', '||conversation.unread_count
			else 'No'
		end as 'unreadcount',
		coalesce(message.pc_status, mms.pc_status) as 'pc_status'
from conversation
	left join message on message.thread_id = conversation.thread_id
	left join mms on conversation.thread_id = mms.thread_id
	left join mms_part on mms_part.message_id = mms.message_id
	left join message_to_address on message.message_id = message_to_address.message_id
	left join address on address.address = message.from_address or address.address = message_to_address.address
	left join contact on contact.contact_id = address.contact_id
order by Time_Stamp desc