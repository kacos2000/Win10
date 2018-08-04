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
NotificationHandler.WNSId as 'WNSId',
NotificationHandler.WNFEventName as 'WNFEventName',
WNSPushChannel.ChannelId as 'Channel_ID',
WNSPushChannel.Uri as 'Uri',
datetime((WNSPushChannel.CreatedTime - 116444736000000000)/10000000, 'unixepoch') as 'WNS_CreatedTime',
datetime((WNSPushChannel.ExpiryTime - 116444736000000000)/10000000, 'unixepoch') as 'WNS_ExpiryTime',
hex(Notification.ActivityId) as 'ActivityId'
from Notification
Join NotificationHandler on NotificationHandler.RecordId = Notification.HandlerId
Left Join WNSPushChannel on WNSPushChannel.HandlerId = NotificationHandler.RecordId
order by Id desc