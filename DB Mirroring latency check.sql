-- before: SQL 2014
--PRIMARY - check Latency to mirror - ALL mirr db;s 
--check DB MIRRORING Latency -  SCRIPT:
--@ principle:
-- Get and store DB MIRRORING Latency stats for mirrored db;s only.                 
            -- RUN script as is @ principle:                
            -- stores to a temp table.   --table can be deleted at end (IF U WISH ?).
            -- each time you run this script, 1 row for each mirrored db is added to the temp table.
            -- temp table allows to see/confirm if latency is going UP / DOWN ?,  plus at what rate.

use master;
set nocount on;

--BUILD cmd STATS cmds to run for EACH db-mirrored db:
    declare @get_mirror_status_of_all_dbs varchar(max)
    set @get_mirror_status_of_all_dbs = ''

    select  @get_mirror_status_of_all_dbs = @get_mirror_status_of_all_dbs + 'exec msdb..sp_dbmmonitorresults ''' + sd.name + ''';' + CHAR(10)
            from sys.databases sd inner join sys.database_mirroring sdm on sd.database_id = sdm.database_id where    sd.database_id > 4 and sdm.mirroring_guid is not null order by name asc

    --print @get_mirror_status_of_all_dbs    --check cmd output

--create temp table:
    If NOT EXISTS (select * from tempdb.sys.all_objects where name like '#dba_get_mirror_stats%' ) 
            BEGIN
                    create table #dba_get_mirror_stats ( 
                            [stat_id] int identity(1,1),[database_name] sysname,[role] int,[mirroring_state] int,[witness_status] int,[log_generation_rate] int,[unsent_log] int,[send_rate] int
                            ,[unrestored_log] int,[recovery_rate] int,[transaction_delay] int,[transactions_per_sec] int,[average_delay] int,[time_recorded] datetime,[time_behind] datetime,[local_time] datetime
                    )
            END

--SAVE into Table:
    insert into #dba_get_mirror_stats 
            ([database_name],[role],[mirroring_state],[witness_status],[log_generation_rate],[unsent_log],[send_rate],[unrestored_log],[recovery_rate],[transaction_delay],[transactions_per_sec],[average_delay],[time_recorded],[time_behind],[local_time] )
    EXEC 
            (@get_mirror_status_of_all_dbs)          --cmd built above.  Checks ALL db mirrored db;s
            -- msdb..sp_dbmmonitorresults xxx_ckdb_xxx              -- IF, to just this db to get

--DISPLAY data:                   
            --note:    col [unsent_log]       =  send queue(kb) on the principal yet to send to the mirror.
    select unsent_log /1024/1024 as 'GB_toSend', unsent_log /1024 as 'MB_toSend', * from #dba_get_mirror_stats 
        order by [stat_id] desc   --by rows added order, latest @ top

--TIDYUP: 

DROP TABLE #dba_get_mirror_stats; -- if you wish, or leave until next time

