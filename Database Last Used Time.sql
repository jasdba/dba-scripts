select database_name = db_name(database_id), -- table_name = OBJECT_NAME(object_id), 
--user_seeks, user_scans, user_lookups, user_updates,
	last_user_seek = MAX(last_user_seek), last_user_scan = MAX(last_user_scan), last_user_lookup = MAX(last_user_lookup), last_user_update = MAX(last_user_update) --, * 
from sys.dm_db_index_usage_stats with (NOLOCK)
WHERE db_name(database_id) IN (
'ConfigDB', 'HEATClassicBRM', 'HEATEstates', 'IPCM', '[MBAM Compliance Status]', '[MBAM Recovery and Hardware]', 
'ReportServer', 'ReportServerTempdb', 'WORKSuite_LAS'
)
AND (last_user_seek > DATEADD(minute, -360, GETDATE()))
	OR 
	(last_user_scan > DATEADD(minute, -360, GETDATE()))
	OR
	(last_user_lookup > DATEADD(minute, -360, GETDATE()))
	OR 
	(last_user_update > DATEADD(minute, -360, GETDATE()))
GROUP BY db_name(database_id)--, OBJECT_NAME(object_id),
	--last_user_seek, last_user_scan, last_user_lookup, last_user_update
go
