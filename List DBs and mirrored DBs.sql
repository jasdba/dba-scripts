SELECT d.[name], DB_NAME(m.database_id) AS Mirrored_Database_Name
FROM sys.databases d left outer join sys.database_mirroring m
on d.[name] = DB_NAME(m.database_id)
WHERE mirroring_state IS NOT NULL
ORDER BY Mirrored_Database_Name;