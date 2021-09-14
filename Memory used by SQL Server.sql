
-- Currently allocated memory:
SELECT
(total_physical_memory_kb/1024) AS Total_OS_Memory_MB,
(available_physical_memory_kb/1024)  AS Available_OS_Memory_MB
FROM sys.dm_os_sys_memory;

SELECT  
(physical_memory_in_use_kb/1024) AS Memory_used_by_Sqlserver_MB,  
(locked_page_allocations_kb/1024) AS Locked_pages_used_by_Sqlserver_MB,  
(total_virtual_address_space_kb/1024) AS Total_VAS_in_MB,
process_physical_memory_low,  
process_virtual_memory_low  
FROM sys.dm_os_process_memory;

-- SQL Server Memory utilization
SELECT
sqlserver_start_time,
(committed_kb/1024) AS Total_Server_Memory_MB,
(committed_target_kb/1024)  AS Target_Server_Memory_MB
FROM sys.dm_os_sys_info;

select
    available_physical_memory_kb / 1024 AS available_physical_memory_MB,
    total_physical_memory_kb / 1024 AS total_physical_memory_MB,
    total_page_file_kb / 1024 AS total_page_file_MB,
    available_page_file_kb / 1024 AS available_page_file_MB,
    system_cache_kb / 1024 AS system_cache_MB
from sys.dm_os_sys_memory;
