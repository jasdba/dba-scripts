
SELECT TOP 1 s.server_name
,d.name
,s.database_name
,m.physical_device_name
,s.backup_start_date
,CASE s.[type] WHEN 'D'
THEN 'Full'
WHEN 'I'
THEN 'Differential'
WHEN 'L'
THEN 'Transaction Log'
END AS BackupType
into #backedupdbs
FROM sys.databases d  
INNER JOIN msdb.dbo.backupset s ON d.name = s.database_name
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE m.physical_device_name LIKE '\\HQ-SQL-Backup%'

DELETE FROM #backedupdbs

DECLARE @DB_NAME VARCHAR(100);
DECLARE CURSOR_ALLDB_NAMES CURSOR FOR
 SELECT NAME FROM SYS.DATABASES ORDER BY NAME
OPEN CURSOR_ALLDB_NAMES
FETCH CURSOR_ALLDB_NAMES INTO @DB_NAME
WHILE @@Fetch_Status = 0
BEGIN
INSERT INTO #backedupdbs
SELECT TOP 1 s.server_name
,d.name
,s.database_name
,m.physical_device_name
,s.backup_start_date
,CASE s.[type] WHEN 'D'
THEN 'Full'
WHEN 'I'
THEN 'Differential'
WHEN 'L'
THEN 'Transaction Log'
END AS BackupType
FROM sys.databases d  
INNER JOIN msdb.dbo.backupset s ON d.name = s.database_name
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE m.physical_device_name LIKE '\\HQ-SQL-Backup%'
and s.database_name = @DB_NAME
and s.type = 'D'
--AND s.backup_start_date > DATEADD(DAY, -1, GETDATE())
ORDER BY s.backup_start_date DESC 

 FETCH CURSOR_ALLDB_NAMES INTO @DB_NAME
END
CLOSE CURSOR_ALLDB_NAMES
DEALLOCATE CURSOR_ALLDB_NAMES

select * from #backedupdbs
