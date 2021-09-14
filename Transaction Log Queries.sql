dbcc sqlperf(logspace)

DBCC LogInfo

SELECT DB_NAME() AS DbName,
name AS FileName,
size/128.0 AS CurrentSizeMB, 
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB
FROM sys.database_files

--DBCC SHRINKFILE (N'DBNAMEHERE' , TRUNCATEONLY)

select log_reuse_wait_desc,*
from sys.databases


---

SELECT DB_NAME () AS DbName,
name AS FileName,
size/128.0 AS CurrentSizeMB,
size/128.0 - CAST (FILEPROPERTY( name, 'SpaceUsed') AS INT )/128.0 AS FreeSpaceMB
FROM sys .database_files

sp_whoIsActive

 
SELECT database_transaction_state = CASE database_transaction_state
       WHEN 1 THEN 'The transaction has not been initialized.'
       WHEN 3 THEN 'The transaction has been initialized but has not generated any log records.'
       WHEN 4 THEN 'The transaction has generated log records.'
       WHEN 5 THEN 'The transaction has been prepared.'
       WHEN 10 THEN 'The transaction has been committed.'
       WHEN 11 THEN 'The transaction has been rolled back.'
       WHEN 12 THEN 'The transaction is being committed. In this state the log record is being generated, but it has not been materialized or persisted.'
       END
       , *
FROM sys .dm_tran_database_transactions
WHERE DB_NAME (5) = 'DBNAMEHERE'
AND database_transaction_state NOT IN (10, 11, 12 )
AND database_transaction_log_record_count > 0
ORDER BY database_transaction_begin_time
GO


--SELECT * FROM sys.dm_io_pending_io_requests
GO