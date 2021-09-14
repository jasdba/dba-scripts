
-- Identify where the error log file physically is located: 
SELECT SERVERPROPERTY('ErrorLogFileName') AS 'Error log file location'; 

-- Find the sizes of the errorlog files - very handy to know! 
EXEC sys.sp_enumerrorlogs; 

--xp_readerrorlog: 
------------------ 
Exec xp_ReadErrorLog  <LogNumber>, <LogType>, <SearchItem1>, <StartDate>, <EndDate>, <SortOrder>; 
	LogNumber:	It is the log number of the error log. You can see the lognumber in the above screenshot. Zero is always referred to as the current log file 
	LogType:	read SQL Server error log or SQL Agent log: 
				1 – SQL Server error log 
				2- SQL Agent logs 
	SearchItem1: the search term 
	SearchItem2: can use additional search items. Both conditions ( SearchItem1 and SearchItem2) should be satisfied for matches 
	StartDate and EndDate: filter the error log between StartDate and EndDate 
	SortOrder: specify ASC (Ascending) or DSC (descending)  

--e.g.: 
xp_readerrorlog 0, 1, N'Error: 18056, Severity: 20, State: 51.' 
--Read the current SQL errorlog, returning matches for this error term 

*/