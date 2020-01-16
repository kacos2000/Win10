Select 

	call_id,
	phone_number as 'PhoneNumber',
	--phone_account_id,
	datetime((start_time - 116444736000000000)/10000000, 'unixepoch', 'localtime') as 'StartTime',-- Time is LocalTime
	datetime((last_updated_time - 116444736000000000)/10000000, 'unixepoch', 'localtime') as 'LastUpdated',-- Time is LocalTime
	case is_read when 1 then 'Yes' else 'No' end as 'IsRead',
	time(duration,'unixepoch') as 'CallDuration', 
	case call_type
		
		when 1 then 'Incomming ('||call_type||')'
		when 2 then 'OutGoing ('||call_type||')'
		when 3 then 'Missed ('||call_type||')'
		when 4 then 'VoiceMail ('||call_type||')'
		when 5 then 'Rejected ('||call_type||')'
		when 6 then 'Blocked ('||call_type||')'
		when 7 then 'Answered Externally ('||call_type||')'
		else '('||call_type||')' 
		end as 'CallType'
	-- conforms to https://developer.android.com/reference/android/provider/CallLog.Calls	

from call_history
order by call_id desc