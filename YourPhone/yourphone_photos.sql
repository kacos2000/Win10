Select 
	photo_id,
	datetime(("last_updated_time"/ 10000000) - 11644473600, 'unixepoch') as 'LastUpdated',
	name,
	"size",
	uri,
	thumbnail as 'Thumbnail',
	blob as 'Image'
from photo	
	
