-- MUST RUN IN SQLCMD MODE!!!

-- DISABLE...

:CONNECT HQCADSQL01\DB_PRD_1

EXEC msdb.dbo.sp_update_job @job_name = 'DBA_BACKUP_DB_LOG', @enabled = 0;

:CONNECT HQCADSQL02\DB_PRD_1

EXEC msdb.dbo.sp_update_job @job_name = 'DBA_BACKUP_DB_LOG', @enabled = 0;

:CONNECT BWCADSQL02\DB_PRD_1

EXEC msdb.dbo.sp_update_job @job_name = 'DBA_BACKUP_DB_LOG', @enabled = 0;


-- RE-ENABLE...
/*
:CONNECT HQCADSQL01\DB_PRD_1

EXEC msdb.dbo.sp_update_job @job_name = 'DBA_BACKUP_DB_LOG', @enabled = 1;

:CONNECT HQCADSQL02\DB_PRD_1

EXEC msdb.dbo.sp_update_job @job_name = 'DBA_BACKUP_DB_LOG', @enabled = 1;

:CONNECT BWCADSQL02\DB_PRD_1

EXEC msdb.dbo.sp_update_job @job_name = 'DBA_BACKUP_DB_LOG', @enabled = 1;
*/

