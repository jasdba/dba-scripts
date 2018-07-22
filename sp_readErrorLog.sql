---http://www.mssqltips.com/sqlservertip/1476/reading-the-sql-server-log-files-using-tsql/
 
sp_readerrorlog ACCEPTS up ot 4 parameters , xp_readerrrorlog takes 7 (see below)
start time, end time, search string, sort order
 
---sp_readerrorlog
This procedure takes four parameters:
1.Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc...
2.Log file type: 1 or NULL = error log, 2 = SQL Agent log
3.Search string 1: String one you want to search for
4.Search string 2: String two you want to search for to further refine the results
 
If you do not pass any parameters this will return the contents of the current error log.
 
sp_readerrorlog @p1 = 0,
@p2 = 1 ,
@p3 = N'Login failed for user ''SSA'''
 
sp_readerrorlog @p1 = 3,
@p2 = 1 ,
@p3 = N'823'
 
sp_readerrorlog @p1 = 0,
@p2 = 1 ,
@p3 = N'Licensing'
 
--check when Agent startup happened
sp_readerrorlog @p1 = 0,
@p2 = 2 ,
@p3 = N'SQLSERVERAGENT starting'
