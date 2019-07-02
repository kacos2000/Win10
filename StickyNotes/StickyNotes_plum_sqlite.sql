-- Sticky Notes (new) database path:
-- C:\Users\%username%\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\plum.sqlite

-- Local media path:
-- C:\Users\%username%\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\media


Select 
	Note.Text,
	json_extract(Note.LastServerVersion,'$.id') as 'LastServerID',
	json_extract(Note.LastServerVersion,'$.changeKey') as 'changeKey',
	json_extract(Note.LastServerVersion,'$.createdWithLocalId') as 'createdWithLocalId',
	json_extract(Note.LastServerVersion,'$.document.type') as 'DocType',
	json_extract(Note.LastServerVersion,'$.document.blocks[0].type') as 'DBlockType',
	json_extract(Note.LastServerVersion,'$.document.blocks[0].content[0].text') as 'Text1',
	json_extract(Note.LastServerVersion,'$.document.blocks[1].content[0].text') as 'Text2',
	json_extract(Note.LastServerVersion,'$.document.blocks[2].content[0].text') as 'Text3',
	json_extract(Note.LastServerVersion,'$.media[0].mimeType')||' ('||
		json_extract(Note.LastServerVersion,'$.media[0].imageDimensions.width')||' x '||
		json_extract(Note.LastServerVersion,'$.media[0].imageDimensions.height')||')' as 'MimeType(WxH)',
	json_extract(Note.LastServerVersion,'$.media[0].id') as 'MediaId1',
	json_extract(Note.LastServerVersion,'$.media[0].lastModified') as 'Media1lastModified',
	json_extract(Note.LastServerVersion,'$.media[1].mimeType')||' ('||
		json_extract(Note.LastServerVersion,'$.media[1].imageDimensions.width')||' x '||
		json_extract(Note.LastServerVersion,'$.media[1].imageDimensions.height')||')' as 'MimeType(WxH)',
	json_extract(Note.LastServerVersion,'$.media[1].id') as 'MediaId2',
	json_extract(Note.LastServerVersion,'$.media[1].lastModified') as 'Media2lastModified',
	json_extract(Note.LastServerVersion,'$.createdAt') as 'LSVcreatedAt',
	json_extract(Note.LastServerVersion,'$.lastModified') as 'LSVlastModified',
	json_extract(Note.LastServerVersion,'$.documentModifiedAt') as 'LSVdocumentModifiedAt',
	datetime(Note.createdAt/10000000 - 62135596800, 'unixepoch') as 'createdAt',
	datetime(Note.UpdatedAt/10000000 - 62135596800, 'unixepoch') as 'UpdatedAt',
	datetime(Note.DeletedAt/10000000 - 62135596800, 'unixepoch') as 'DeletedAt',
	datetime(media.UpdatedAt/10000000 - 62135596800, 'unixepoch') as 'MediaUpdatedAt',
	Note.Theme,
	case Note.IsOpen
		when 1 then 'Yes'
		end as 'isOpen',
	Media.LocalFileRelativePath
from Note
left join media on media.ParentId = note.Id