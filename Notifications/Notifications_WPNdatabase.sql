select
Notification.Id,
Notification.HandlerId as 'H_Id',
NotificationHandler.PrimaryId as 'Application',
NotificationHandler.HandlerType,
Notification.Type as 'Type',
replace(replace(replace(Notification.Payload,char(13)||char(10),''),' ',''),char(9),'') as 'Payload', 
Notification.PayloadType as 'PayloadType',
Notification.Tag as 'Tag',
datetime((Notification.ArrivalTime - 116444736000000000)/10000000, 'unixepoch') as ArrivalTime,
case when Notification.ExpiryTime = 0 then 'Expired' else datetime((Notification.ExpiryTime - 116444736000000000)/10000000, 'unixepoch') end as ExpiryTime,
NotificationHandler.CreatedTime as 'H_Created',
NotificationHandler.ModifiedTime as 'H_Modified',
hex(Notification.ActivityId) as 'ActivityId'
from Notification
Join NotificationHandler on NotificationHandler.RecordId = Notification.HandlerId
order by Id desc