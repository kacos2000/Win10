-- C:\Users\%username%\AppData\Local\Packages\Microsoft.YourPhone_8wekyb3d8bbwe\LocalCache\Indexed\1C8ABB45-8138-4600-8CA0-13FD3A82F826\System\Database\Phone.db


select  

message.Message_id,
message.Thread_id,
message.Status,
case  message.Type when 1 then 'Received' when 2 then 'Sent' end as 'Type',
datetime ((message.timestamp /10000000)-11644473600, 'unixepoch', 'localtime') as 'TimeStamp',
message.body,
conversation.Recipient_list,
message_to_address.address,
conversation.msg_count,
conversation.unread_count,
conversation.summary


from message
left join message_to_address on message.message_id = message_to_address.message_id
join conversation on message.thread_id = conversation.thread_id
left join address on address.address = conversation.recipient_list
order by TimeStamp desc