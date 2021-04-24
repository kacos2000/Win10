select 
id,
json_extract(json,'$.id') as 'id',
json_extract(json,'$.tickerText') as 'tickerText',
json_extract(json,'$.title') as 'title',
json_extract(json,'$.bigText') as 'bigText',
json_extract(json,'$.text') as 'text',
json_extract(json,'$.subText') as 'subText',
json_extract(json,'$.key') as 'key',
json_extract(json,'$.groupKey') as 'groupkey',
json_extract(json,'$.tag') as 'tag',
json_extract(json,'$.packageName') as 'packagename',
json_extract(json,'$.appName') as 'appname',
json_extract(json,'$.isClearable') as 'isClearable',
json_extract(json,'$.isGroup') as 'isGroup',
json_extract(json,'$.isOngoing') as 'isOngoing',
json_extract(json,'$.featureFlags') as 'featureFlags',
json_extract(json,'$.platform') as 'platform',
json_extract(json,'$.version') as 'version',
json_extract(json,'$.category') as 'category',

json_extract(json,'$.flags') as 'flags',
datetime(json_extract(json,'$.postTime')/1000, 'unixepoch','localtime') as 'postTime',
datetime(json_extract(json,'$.timestamp')/1000, 'unixepoch','localtime') as 'timestamp',

json_extract(json,'$.notificationClass') as 'notificationClass',
json_extract(json,'$.template') as 'template',

datetime((post_time - 116444736000000000)/10000000, 'unixepoch','localtime') as 'post_time(local)',
state

from notifications
order by postTime desc
