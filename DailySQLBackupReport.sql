
-- ============================================= 
-- Author:   
-- Create date: 15th May 2013 
-- Description: Emails last x hours of of backups 
/* 
Needs... 
use msdb 
CREATE USER SQLMonitor FOR LOGIN SQLMonitor 
grant select on backupset to SQLMonitor 
*/ 
-- ============================================= 
CREATE PROCEDURE [dbo].[up_daily_SQL_Backups] 
AS 
BEGIN 
DECLARE @dc    CHAR(3)   = SUBSTRING(@@SERVERNAME,1,3) 
DECLARE @EmailTo  VARCHAR(100) = 'DBAs@sage.com' 
DECLARE @EmailSubject VARCHAR(100) = 'Daily SQL Backup Report '+@dc 
DECLARE @EmailBody  VARCHAR(MAX) 
DECLARE @Message  VARCHAR(MAX) 
DECLARE @howmanyhours INT = 24 
DECLARE @startdate  DATETIME 
DECLARE @enddate  DATETIME 

--SET @dc=[dbo].[fnGetDC]() 

--when you say 48 hours, that means -48 hours 
SET @howmanyhours=@howmanyhours*-1 
SET @startdate=DATEADD(hh, @howmanyhours, GETDATE()) 
SET @enddate=GETDATE() 

SET @EmailBody= '<!DOCTYPE html> 
<html lang="en-US"> 
<head> 
 <title>Daily tblTransaction Counts</title> 
 <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" /> 

</head> 
<body>'+CHAR(13)+ 
' <h1><font face="arial">SQL Backups in the last '+LTRIM(RTRIM(@howmanyhours))+' hours</font></h1>'+CHAR(13)+ 
' <table border="1">'+CHAR(13)+ 
'  <tr>'+CHAR(13)+ 
'   <th><font face="arial">id</font></th>'+CHAR(13)+ 
'   <th><font face="arial">site</font></th>'+CHAR(13)+ 
'   <th><font face="arial">server</font></th>'+CHAR(13)+ 
'   <th><font face="arial">database</font></th>'+CHAR(13)+ 
'   <th><font face="arial">start date</font></th>'+CHAR(13)+ 
'   <th><font face="arial">finish date</font></th>'+CHAR(13)+ 
'   <th><font face="arial">mins</font></th>'+CHAR(13)+ 
'   <th><font face="arial">type</font></th>'+CHAR(13)+ 
'   <th><font face="arial">filename</font></th>'+CHAR(13)+ 
'   <th><font face="arial">size (mb)</font></th>'+CHAR(13)+ 
'   <th><font face="arial">compresses size</font></th>'+CHAR(13)+ 
'  </tr>'+CHAR(13) 


DECLARE @backups TABLE ( 
 id INT, 
 site VARCHAR(10), 
 server_name VARCHAR(25), 
 database_name VARCHAR(20), 
 backup_start_date datetime, 
 backup_finish_date datetime, 
 type VARCHAR(10), 
 name VARCHAR(150), 
 backup_size DECIMAL(15,2), 
 compressed_backup_size DECIMAL(15,2), 
 length INT 
 ) 

INSERT INTO @backups 
SELECT ROW_NUMBER() OVER (ORDER BY database_name ASC),@dc site,SUBSTRING(server_name,CHARINDEX('\',server_name)+1,10) server_name, database_name, backup_start_date, backup_finish_date,type, ISNULL(name,RIGHT(physical_device_name,50)), backup_size, compres
sed_backup_size, 0 
FROM   rep.msdb.dbo.backupmediafamily bmf 
INNER JOIN rep.msdb.dbo.backupset bs 
   ON bmf.media_set_id = bs.media_set_id 
WHERE (backup_start_date BETWEEN @startdate AND @enddate 
   OR  backup_finish_date BETWEEN @startdate AND @enddate) 
AND Type in ('D','I') 
ORDER BY site desc,server_name, database_name 

INSERT INTO @backups 
SELECT ROW_NUMBER() OVER (ORDER BY database_name ASC),@dc site,SUBSTRING(server_name,CHARINDEX('\',server_name)+1,10) server_name, database_name, backup_start_date, backup_finish_date,type, ISNULL(name,RIGHT(physical_device_name,50)), backup_size, compres
sed_backup_size, 0 
FROM [set].msdb.dbo.backupmediafamily bmf 
INNER JOIN [set].msdb.dbo.backupset bs 
   ON bmf.media_set_id = bs.media_set_id 
WHERE (backup_start_date BETWEEN @startdate AND @enddate 
   OR  backup_finish_date BETWEEN @startdate AND @enddate) 
AND Type in ('D','I') 
ORDER BY site desc,server_name, database_name 

INSERT INTO @backups 
SELECT ROW_NUMBER() OVER (ORDER BY database_name ASC), @dc site,SUBSTRING(server_name,CHARINDEX('\',server_name)+1,10) server_name, database_name, backup_start_date, backup_finish_date,type, ISNULL(name,RIGHT(physical_device_name,50)), backup_size, compre
ssed_backup_size, 0 
FROM act.msdb.dbo.backupmediafamily bmf 
INNER JOIN act.msdb.dbo.backupset bs 
   ON bmf.media_set_id = bs.media_set_id 
WHERE (backup_start_date BETWEEN @startdate AND @enddate 
   OR  backup_finish_date BETWEEN @startdate AND @enddate) 
AND Type in ('D','I') 
ORDER BY site desc,server_name, database_name 

INSERT INTO @backups 
SELECT ROW_NUMBER() OVER (ORDER BY database_name ASC), @dc site,SUBSTRING(server_name,CHARINDEX('\',server_name)+1,10) server_name, database_name, backup_start_date, backup_finish_date,type, ISNULL(name,RIGHT(physical_device_name,50)), backup_size, compre
ssed_backup_size, 0 
FROM rpt.msdb.dbo.backupmediafamily bmf 
INNER JOIN rpt.msdb.dbo.backupset bs 
   ON bmf.media_set_id = bs.media_set_id 
WHERE (backup_start_date BETWEEN @startdate AND @enddate 
   OR  backup_finish_date BETWEEN @startdate AND @enddate) 
AND Type in ('D','I') 
ORDER BY site desc,server_name, database_name 

INSERT INTO @backups 
SELECT ROW_NUMBER() OVER (ORDER BY database_name ASC), @dc site,SUBSTRING(server_name,CHARINDEX('\',server_name)+1,10) server_name, database_name, backup_start_date, backup_finish_date,type, ISNULL(name,RIGHT(physical_device_name,50)), backup_size, compre
ssed_backup_size, 0 
FROM msdb.dbo.backupmediafamily bmf 
INNER JOIN msdb.dbo.backupset bs 
   ON bmf.media_set_id = bs.media_set_id 
WHERE (backup_start_date BETWEEN @startdate AND @enddate 
   OR  backup_finish_date BETWEEN @startdate AND @enddate) 
AND Type in ('D','I') 
ORDER BY site desc,server_name, database_name 

--INSERT INTO @backups 
--SELECT ROW_NUMBER() OVER (ORDER BY database_name ASC), 'TCL' site,server_name, database_name, backup_start_date, backup_finish_date,type, name, backup_size, compressed_backup_size, 0 
--FROM TCL_TESTDB2.msdb.dbo.backupset 
--WHERE (backup_start_date BETWEEN @startdate AND @enddate 
--   OR  backup_finish_date BETWEEN @startdate AND @enddate) 
--AND Type in ('D','I') 
--ORDER BY site desc,server_name, database_name 

--INSERT INTO @backups 
--SELECT ROW_NUMBER() OVER (ORDER BY database_name ASC), 'GSL' site,server_name, database_name, backup_start_date, backup_finish_date,type, name, backup_size, compressed_backup_size, 0 
--FROM GSL_DBSRV1.msdb.dbo.backupset 
--WHERE (backup_start_date BETWEEN @startdate AND @enddate 
--   OR  backup_finish_date BETWEEN @startdate AND @enddate) 
--AND Type in ('D','I') 
--ORDER BY site desc,server_name, database_name 

--INSERT INTO @backups 
--SELECT ROW_NUMBER() OVER (ORDER BY database_name ASC), 'GSL' site,server_name, database_name, backup_start_date, backup_finish_date,type, name, backup_size, compressed_backup_size, 0 
--FROM GSL_DBSRV3.msdb.dbo.backupset 
--WHERE (backup_start_date BETWEEN @startdate AND @enddate 
--   OR  backup_finish_date BETWEEN @startdate AND @enddate) 
--AND Type in ('D','I') 
--ORDER BY site desc,server_name, database_name 

--INSERT INTO @backups 
--SELECT ROW_NUMBER() OVER (ORDER BY database_name ASC), 'GSL' site,server_name, database_name, backup_start_date, backup_finish_date,type, name, backup_size, compressed_backup_size, 0 
--FROM GSL_DBSRV5.msdb.dbo.backupset 
--WHERE (backup_start_date BETWEEN @startdate AND @enddate 
--   OR  backup_finish_date BETWEEN @startdate AND @enddate) 
--AND Type in ('D','I') 
--ORDER BY site desc,server_name, database_name 

--INSERT INTO @backups 
--SELECT ROW_NUMBER() OVER (ORDER BY database_name ASC), 'GSL' site,server_name, database_name, backup_start_date, backup_finish_date,type, name, backup_size, compressed_backup_size, 0 
--FROM GSL_DBSRV6.msdb.dbo.backupset 
--WHERE (backup_start_date BETWEEN @startdate AND @enddate 
--   OR  backup_finish_date BETWEEN @startdate AND @enddate) 
--AND Type in ('D','I') 
--ORDER BY site desc,server_name, database_name 

UPDATE @backups 
SET type='Diff' 
WHERE type='I' 

UPDATE @backups 
SET type='Full' 
WHERE type='D' 

UPDATE @backups 
SET backup_size=backup_size/1024/1024, 
 compressed_backup_size=compressed_backup_size/1024/1024 

UPDATE @backups 
SET length=DATEDIFF(MINUTE,backup_start_date,backup_finish_date) 

/* possible improvement... per server though, so 9 times 
SELECT @type=type from @backups WHERE HERE site='GSL' AND server_name='DBSERVER1' 

IF @type='Diff' 
THEN 
  INSERT diff total 
ELSE 
  INSERT full total 
*/ 

--insert total lines 
INSERT INTO @backups(id,site,server_name, database_name, backup_start_date, backup_finish_date,type, name, backup_size, compressed_backup_size,length) 
VALUES 
((SELECT MAX(id)+1 AS id FROM @backups WHERE site=@dc AND server_name=@dc+'PSQLREP'),@dc,@dc+'PSQLREP','Total=4',GETDATE(),GETDATE(),'Tot','\\\Total Full = 5,Diff = 4///','0','0','0'), 
((SELECT MAX(id)+1 AS id FROM @backups WHERE site=@dc AND server_name=@dc+'PSQLSET'),@dc,@dc+'PSQLSET','Total=5',GETDATE(),GETDATE(),'Tot','\\\Total Full = 6,Diff = 5///','0','0','0'), 
((SELECT MAX(id)+1 AS id FROM @backups WHERE site=@dc AND server_name=@dc+'PSQLACT'),@dc,@dc+'PSQLACT','Total=5',GETDATE(),GETDATE(),'Tot','\\\Total Full = 6,Diff = 5///','0','0','0'), 
((SELECT MAX(id)+1 AS id FROM @backups WHERE site=@dc AND server_name=@dc+'PSQLRPT'),@dc,@dc+'PSQLRPT','Total=4',GETDATE(),GETDATE(),'Tot','\\\Total Full = 5,Diff = 4///','0','0','0'), 
((SELECT MAX(id)+1 AS id FROM @backups WHERE site=@dc AND server_name=@dc+'PSQLWAR'),@dc,@dc+'PSQLWAR','Total=5',GETDATE(),GETDATE(),'Tot','\\\Total Full = 6,Diff = 5///','0','0','0') 

select * from @backups 
order by 2,3,1,4,5 

DECLARE counts_cursor CURSOR FAST_FORWARD FOR 
SELECT '<tr>'+CHAR(13)+ 
   '<td><font face="arial">'+LTRIM(RTRIM(ISNULL(id,0)))+'</font></td>'+CHAR(13)+ 
   '<td><font face="arial"'+ 
   CASE site 
    WHEN 'TCL' THEN 'color="red"' 
    WHEN 'GSL' THEN 'color="blue"' 
    WHEN 'HEX' THEN 'color="green"' 
    ELSE 'color="black"' 
   END+ 
   '>'+LTRIM(RTRIM(ISNULL(site,@dc)))+'</font></td>'+CHAR(13)+ 
   '<td><font face="arial"'+ 
   CASE SUBSTRING(server_name,8,3) 
    WHEN 'SET' THEN 'color="orange"' 
    WHEN 'ACT' THEN 'color="red"' 
    WHEN 'RPT' THEN 'color="green"' 
    WHEN 'WAR' THEN 'color="blue"' 
    WHEN 'REP' THEN 'color="cyan"' 
    ELSE 'color="black"' 
   END+ 
   '>'+LTRIM(RTRIM(ISNULL(server_name,'null')))+'</font></td>'+CHAR(13)+ 
   '<td><font face="arial"'+ 
   CASE database_name 
    WHEN 'master' THEN 'color="gray"' 
    WHEN 'model' THEN 'color="gray"' 
    WHEN 'msdb' THEN 'color="gray"' 
    WHEN 'VSPActive' THEN 'color="black"' 
    WHEN 'VSPReporting' THEN 'color="black"' 
    WHEN 'VSPReplication' THEN 'color="black"' 
    WHEN 'VSPSettlement' THEN 'color="black"' 
    WHEN 'VSPWarehouse' THEN 'color="black"' 
    WHEN 'SQLMonitor' THEN 'color="black"' 
    WHEN 'Sage50' THEN 'color="black"' 
    WHEN 'Total=3' THEN 'color="gray"' 
    WHEN 'Total=4' THEN 'color="gray"' 
    WHEN 'Total=5' THEN 'color="gray"' 
    WHEN 'Total=6' THEN 'color="gray"' 
    ELSE 'color="black"' 
   END+ 
   '>'+LTRIM(RTRIM(ISNULL(database_name,'null')))+'</font></td>'+CHAR(13)+ 
   '<td><font face="arial">'+LTRIM(RTRIM(ISNULL(backup_start_date,'2014-01-01')))+'</font></td>'+CHAR(13)+ 
   '<td><font face="arial">'+LTRIM(RTRIM(ISNULL(backup_finish_date,'2014-01-01')))+'</font></td>'+CHAR(13)+ 
   '<td><font face="arial">'+LTRIM(RTRIM(ISNULL(length,0)))+'</font></td>'+CHAR(13)+ 
   '<td><font face="arial"'+ 
   CASE type 
    WHEN 'Diff' THEN 'color="red"' 
    WHEN 'Full' THEN 'color="blue"' 
    WHEN 'tot' THEN 'color="gray"' 
    ELSE 'color="black"' 
   END+ 
   '>'+LTRIM(RTRIM(ISNULL(type,'null')))+'</font></td>'+CHAR(13)+ 
   '<td><font face="arial">'+LTRIM(RTRIM(ISNULL(name,'unknown')))+'</font></td>'+CHAR(13)+ 
   '<td><font face="arial"><div align="right">'+LTRIM(RTRIM(ISNULL(backup_size,0)))+'</font></td>'+CHAR(13)+ 
   '<td><font face="arial"><div align="right">'+LTRIM(RTRIM(ISNULL(compressed_backup_size,0)))+'</font></td>'+CHAR(13)+ 
  '</tr>'+CHAR(13) 
FROM @backups 
ORDER BY site desc,server_name, id, database_name 

OPEN counts_cursor 
FETCH NEXT 
FROM counts_cursor 
INTO @Message 

WHILE @@FETCH_STATUS=0 
BEGIN 
 SET @EmailBody=@EmailBody+@Message 

 FETCH NEXT 
 FROM counts_cursor 
 INTO @Message 

END 
CLOSE counts_cursor 
DEALLOCATE counts_cursor   

SET @EmailBody= @EmailBody+'</BODY></HTML>'   
PRINT @EmailBody 

EXEC [msdb]..sp_send_dbmail 
 @profile_name = 'DBA Team', 
 @recipients  = @EmailTo, 
 @subject  = @EmailSubject, 
 @body   = @EmailBody, 
 @body_format = 'HTML' 
END 