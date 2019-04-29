select
Notification.Id as 'ID',
Notification.HandlerId as 'Handler_Id',
NotificationHandler.PrimaryId as 'Application',
NotificationHandler.HandlerType as 'HandlerType',
Notification.Type as 'Type',
replace(replace(replace(replace(Notification.Payload, x'0A',''),x'09',''),x'20'||x'20',''),x'0D','') as 'payload',
Notification.PayloadType as 'PayloadType',
Notification.Tag as 'Tag',
datetime((Notification.ArrivalTime - 116444736000000000)/10000000, 'unixepoch') as 'ArrivalTime',
case when Notification.ExpiryTime = 0 then 'Expired' else datetime((Notification.ExpiryTime - 116444736000000000)/10000000, 'unixepoch') end as 'ExpiryTime',
NotificationHandler.CreatedTime as 'Handler_Created',
NotificationHandler.ModifiedTime as 'Handler_Modified',
case 
	when NotificationHandler.WNSId notnull 
	then NotificationHandler.WNSId
	else ''
end as 'WNSId',
case 
	when NotificationHandler.WNFEventName notnull 
	then NotificationHandler.WNFEventName
	else ''
end as 'WNFEventName',
case 
	when WNSPushChannel.ChannelId notnull 
	then WNSPushChannel.ChannelId
	else ''
end as 'Channel_ID',
case 
	when WNSPushChannel.Uri notnull 
	then WNSPushChannel.Uri
	else ''
end as 'Uri',
case 
	when WNSPushChannel.CreatedTime
	then datetime((WNSPushChannel.CreatedTime - 116444736000000000)/10000000, 'unixepoch') 
	else ''
end as 'WNS_CreatedTime',
case 
	when WNSPushChannel.ExpiryTime
	then datetime((WNSPushChannel.ExpiryTime - 116444736000000000)/10000000, 'unixepoch')
	else ''	
end as 'WNS_ExpiryTime',
case 
	when hex(Notification.ActivityId) = '00000000000000000000000000000000'
	then ''
	else hex(Notification.ActivityId)
end as 'ActivityId'
from Notification
Join NotificationHandler on NotificationHandler.RecordId = Notification.HandlerId
Left Join WNSPushChannel on WNSPushChannel.HandlerId = NotificationHandler.RecordId
order by Id desc