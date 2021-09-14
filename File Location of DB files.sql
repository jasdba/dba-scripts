SELECT d.name, m.name 'Logical Name', m.physical_name 'File Location'  
FROM sys.master_files m JOIN sys.databases d on m.database_id=d.database_id 
where LEFT(m.physical_name,1) IN ('i', 'k') 
--and d.recovery_model = 1 
order by m.name
