-- check free space on each database & drive by physical files
USE MASTER
GO
CREATE TABLE #TMPFIXEDDRIVES1 (DRIVE  CHAR(1), MBFREE INT)
INSERT INTO #TMPFIXEDDRIVES1 EXEC xp_FIXEDDRIVES
CREATE TABLE #TMPSPACEUSED1 (DBNAME    VARCHAR(150), FILENME   VARCHAR(150), SPACEUSED FLOAT)
INSERT INTO #TMPSPACEUSED1
EXEC sp_msforeachdb ' USE [?]
--IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
Select ''?'' DBName, Name FileNme, fileproperty(Name,''SpaceUsed'') SpaceUsed from sysfiles'
SELECT   C.DRIVE,
               CASE
           WHEN (C.MBFREE) > 1000 THEN CAST(CAST(((C.MBFREE) / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' GB'
           ELSE CAST(CAST((C.MBFREE) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' MB'
         END AS DISKSPACEFREE,
         A.NAME AS DATABASENAME, B.NAME AS FILENAME,
         CASE B.TYPE
           WHEN 0 THEN 'DATA'
           ELSE TYPE_DESC
         END AS FILETYPE,
         CASE
           WHEN (B.SIZE * 8 / 1024.0) > 1000
           THEN CAST(CAST(((B.SIZE * 8 / 1024) / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' GB'
           ELSE CAST(CAST((B.SIZE * 8 / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' MB'
         END AS FILESIZE,
         CAST((B.SIZE * 8 / 1024.0 ) - (D.SPACEUSED / 128.0) AS DECIMAL(15,0)) SPACEFREE_MB,
         B.PHYSICAL_NAME
FROM     SYS.DATABASES A
         JOIN SYS.MASTER_FILES B
           ON A.DATABASE_ID = B.DATABASE_ID
         JOIN #TMPFIXEDDRIVES1 C
           ON LEFT(B.PHYSICAL_NAME,1) = C.DRIVE
         JOIN #TMPSPACEUSED1 D
           ON A.NAME = D.DBNAME
              AND B.NAME = D.FILENME
-- WHERE C.DRIVE = 'M'
ORDER BY SPACEFREE_MB DESC ,DISKSPACEFREE
DROP TABLE #TMPFIXEDDRIVES1
DROP TABLE #TMPSPACEUSED1
