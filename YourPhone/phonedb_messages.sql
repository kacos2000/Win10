-- C:\Users\%username%\AppData\Local\Packages\Microsoft.YourPhone_8wekyb3d8bbwe\LocalCache\Indexed\<GUID>\System\Database\Phone.db

select  
			message.Message_id as 'MessageID',
			message.Thread_id as 'ThreadId',
			message.Status as 'Status',
			case  
				message.Type 
					when 1 then 'Received' 
					when 2 then 'Sent' 
			end as 'Type',
			message.from_address as 'From Address',
			case 
				when message.from_address notnull
				then contact.display_name
			end as 'Sender',
			datetime ((message.timestamp /10000000)-11644473600, 'unixepoch', 'localtime') as 'TimeStamp',
			message.body as 'Body',
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
			conversation.Recipient_list as 'recipientlist'
		from message
		left join message_to_address on message.message_id = message_to_address.message_id
		join conversation on message.thread_id = conversation.thread_id
		left join address on address.address = conversation.recipient_list or address.address = message_to_address.address
		left join contact on contact.contact_id = address.contact_id
		order by TimeStamp desc