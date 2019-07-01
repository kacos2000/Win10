Select 
	photo_id as 'pid',
	uri,
	name,
	photo."size",
	datetime(("last_updated_time"/ 10000000) - 11644473600, 'unixepoch') as 'LastUpdated',
	hex(thumbnail) as 'Thumbnail',
	hex(blob) as 'Blob'
from photo