--ALREADY:

/*
----------------------------------------------------------------------
--DBA = 
	just COPY|PASTE into new query sesison and run.
		- by default ONLY <Agent Job Name>  LIKE 'DBA_%'   are listed.
			- commentout line [STATE__JOB_NAME__FILTER] to list ALL jobs

-- THREE scripts in this file:
	--	a = 	--List Jobs, Schedules(sched name + freq), and Next Scheduled Run Datetimes:
	--	b = 	--get_jobs_LastRan_and_status = DURATION
	--  c = 	--confirm JOBS are ENABLED:
 ----------------------------------------------------------------------
*/

--SELECT convert(varchar(40), @@servername) as 'Instance';


--already:

--List Jobs, Schedules(sched name + freq), and Next Scheduled Run Datetimes:
  select 
       --convert(varchar(40), @@servername) as 'Instance',
       convert(varchar(50), S.name) AS JobName
	   ,case when S.enabled = 1 then 'Y' else 'no' end as 'Enabled'
       ,convert(varchar(50), SS.name) AS ScheduleName
       ,CASE(SS.freq_type)
            WHEN 1  THEN 'Once'
            WHEN 4  THEN 'Daily'
            WHEN 8  THEN (case when (SS.freq_recurrence_factor > 1) then  'Every ' + convert(varchar(3),SS.freq_recurrence_factor) + ' Weeks'  else 'Weekly'  end)
            WHEN 16 THEN (case when (SS.freq_recurrence_factor > 1) then  'Every ' + convert(varchar(3),SS.freq_recurrence_factor) + ' Months' else 'Monthly' end)
            WHEN 32 THEN 'Every ' + convert(varchar(3),SS.freq_recurrence_factor) + ' Months' -- RELATIVE
            WHEN 64 THEN 'SQL Startup'
            WHEN 128 THEN 'SQL Idle'
            ELSE '??'
        END AS Frequency,  
       CASE
            WHEN (freq_type = 1)                       then 'One time only'
            WHEN (freq_type = 4 and freq_interval = 1) then 'Every Day'
            WHEN (freq_type = 4 and freq_interval > 1) then 'Every ' + convert(varchar(10),freq_interval) + ' Days'
            WHEN (freq_type = 8) then (select 'Weekly Schedule' = MIN(D1+ D2+D3+D4+D5+D6+D7 )
                                        from (select SS.schedule_id,
                                                        freq_interval, 
                                                        'D1' = CASE WHEN (freq_interval & 1  <> 0) then 'Sun ' ELSE '' END,
                                                        'D2' = CASE WHEN (freq_interval & 2  <> 0) then 'Mon '  ELSE '' END,
                                                        'D3' = CASE WHEN (freq_interval & 4  <> 0) then 'Tue '  ELSE '' END,
                                                        'D4' = CASE WHEN (freq_interval & 8  <> 0) then 'Wed '  ELSE '' END,
														'D5' = CASE WHEN (freq_interval & 16 <> 0) then 'Thu '  ELSE '' END,
                                                        'D6' = CASE WHEN (freq_interval & 32 <> 0) then 'Fri '  ELSE '' END,
                                                        'D7' = CASE WHEN (freq_interval & 64 <> 0) then 'Sat '  ELSE '' END
                                                    from msdb..sysschedules ss
                                                where freq_type = 8
                                            ) as F
                                        where schedule_id = SJ.schedule_id
                                    )
            WHEN (freq_type = 16) then 'Day ' + convert(varchar(2),freq_interval) 
            WHEN (freq_type = 32) then (select  freq_rel + WDAY 
                                        from (select SS.schedule_id,
                                                        'freq_rel' = CASE(freq_relative_interval)
                                                                    WHEN 1 then 'First'
                                                                    WHEN 2 then 'Second'
                                                                    WHEN 4 then 'Third'
                                                                    WHEN 8 then 'Fourth'
                                                                    WHEN 16 then 'Last'
                                                                    ELSE '??'
                                                                    END,
                                                    'WDAY'     = CASE (freq_interval)
                                                                    WHEN 1 then ' Sun'
                                                                    WHEN 2 then ' Mon'
                                                                    WHEN 3 then ' Tue'
                                                                    WHEN 4 then ' Wed'
                                                                    WHEN 5 then ' Thu'
                                                                    WHEN 6 then ' Fri'
                                                                    WHEN 7 then ' Sat'
                                                                    WHEN 8 then ' Day'
                                                                    WHEN 9 then ' Weekday'
                                                                    WHEN 10 then ' Weekend'
                                                                    ELSE '??'
                                                                    END
                                                from msdb..sysschedules SS
                                                where SS.freq_type = 32
                                                ) as WS 
                                        where WS.schedule_id = SS.schedule_id
                                        ) 
        END AS Interval,
        CASE (freq_subday_type)
            WHEN 1 then   left(stuff((stuff((replicate('0', 6 - len(active_start_time)))+ convert(varchar(6),active_start_time),3,0,':')),6,0,':'),8)
            WHEN 2 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' seconds'
            WHEN 4 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' minutes'
            WHEN 8 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' hours'
            ELSE '??'
        END AS [Time],
        CASE SJ.next_run_date
            WHEN 0 THEN cast('n/a' as char(10))
            ELSE convert(char(10), convert(datetime, convert(char(8),SJ.next_run_date)),120)  + ' ' + left(stuff((stuff((replicate('0', 6 - len(next_run_time)))+ convert(varchar(6),next_run_time),3,0,':')),6,0,':'),8)
        END AS NextRunTime
		,S.date_created as 'date_jobCreated'
from msdb.dbo.sysjobs S
left join msdb.dbo.sysjobschedules SJ on S.job_id = SJ.job_id  
left join msdb.dbo.sysschedules SS on SS.schedule_id = SJ.schedule_id

--*****  STATE__JOB_NAME__FILTER   ***
	WHERE S.name LIKE 'DBA_%'

order by S.name


----------------------------------------------------------------------

--already:


--get_jobs_LastRan_and_status

	--for EACH job, get LAST run status + duration (hhMMss).    ONE row returned /per db
	--works as long as NO jobs is runs longer than 999 hours
	--eg:  start = 	2018-05-25 14:46:00.000
	--eg:  duration = 	000:24:15
	SELECT
		 --getdate() as [CollectionDate] ,SERVERPROPERTY('servername') as [SQL_Instance],
		 j.name,	h.run_status
		,CASE 
			WHEN h.run_status = 0 THEN 'FAILED' 
			WHEN h.run_status = 1 THEN 'Success' 
			WHEN h.run_status = 2 THEN 'Retry' 
			WHEN h.run_status = 3 THEN 'Cancelled' 
			ELSE '???' 
		END as run_status_desc
		,[start_date] = CONVERT(DATETIME, RTRIM(run_date) + ' ' + STUFF(STUFF(REPLACE(STR(RTRIM(h.run_time),6,0),' ','0'),3,0,':'),6,0,':'))
		,durationHHMMSS = STUFF(STUFF(REPLACE(STR(h.run_duration,7,0), ' ','0'),4,0,':'),7,0,':')
		,case 
			WHEN j.name like '%backup%' THEN 'backup' 
			WHEN j.name like '%delete%' THEN 'delete' 
			WHEN j.name like '%index%' 	THEN 'index' 
			WHEN j.name like '%stat%'  	THEN 'stats' 
			WHEN j.name like '%clean%'  THEN 'cleanup' 
			WHEN j.name like '%check%'  THEN 'check' 
			WHEN j.name like '%purge%'  THEN 'purge' 
			WHEN j.name like '%mirror%' THEN 'mirror' 
			WHEN j.name like '%reorg%' OR  j.name like '%re-org%' THEN 'reorg' 
		 end as [action]
	FROM
		msdb.dbo.sysjobs AS j
		INNER JOIN	(
			SELECT job_id, instance_id = MAX(instance_id) 
			FROM msdb.dbo.sysjobhistory
			GROUP BY job_id
			) AS l		
			ON j.job_id = l.job_id
		INNER JOIN	msdb.dbo.sysjobhistory AS h	ON h.job_id = l.job_id
		AND h.instance_id = l.instance_id
	WHERE 
		j.name LIKE 'DBA%'			/*  FILTER:  jobname */
		--AND h.run_status <> 1		/*  FILTER:  NON-SU jobs, ie: FAILED jobs */
	ORDER BY
		--CONVERT(INT, h.run_duration) DESC,    [start_date] DESC		--by:  dur, then StartDate
		--[start_date] DESC		--by: starting order: last run @ top
		j.name asc			--by:  jobname



----------------------------------------------------------------------

--already:

/*
-- generate ENABLE cmds 	(- if needed)
	select 'EXEC msdb.dbo.sp_update_job @job_name = ''' + name + ''', @enabled=1;' from msdb..sysjobs where name like 'DBA_%'		--enable jobs
	

--  enable jobs:

EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Cleanup_CommandLog', @enabled=1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Cleanup_History(job+bkup)', @enabled=1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Cleanup_OutputFile', @enabled=1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_CHECKDB', @enabled=1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_BACKUP_DB_FULL', @enabled=1;
--EXEC msdb.dbo.sp_update_job @job_name = 'DBA_BACKUP_DB_DIFF', @enabled=1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_BACKUP_DB_LOG', @enabled=1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_INDEX_REBUILD', @enabled=1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_INDEX_REORG', @enabled=1;



*/


----------------------------------------------------------------------

GO
