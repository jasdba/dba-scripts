--Server level Logins and roles 
SELECT sp.name AS LoginName,sp.type_desc AS LoginType, sp.default_database_name AS DefaultDBName,slog.sysadmin AS SysAdmin,slog.securityadmin AS SecurityAdmin,slog.serveradmin AS ServerAdmin, slog.setupadmin AS SetupAdmin, slog.processadmin AS ProcessAdmin, slog.diskadmin AS DiskAdmin, slog.dbcreator AS DBCreator,slog.bulkadmin AS BulkAdmin 
FROM sys.server_principals sp  JOIN master..syslogins slog 
ON sp.sid=slog.sid  
WHERE sp.type  <> 'R' AND sp.name NOT LIKE '##%' 
order by sp.name 
--Databases users and roles 
DECLARE @SQLStatement VARCHAR(4000)  
DECLARE @T_DBuser TABLE (DBName SYSNAME, UserName SYSNAME, AssociatedDBRole NVARCHAR(256))  
SET @SQLStatement=' 
SELECT ''?'' AS DBName,dp.name AS UserName,USER_NAME(drm.role_principal_id) AS AssociatedDBRole  
FROM ?.sys.database_principals dp 
LEFT OUTER JOIN ?.sys.database_role_members drm 
ON dp.principal_id=drm.member_principal_id  
WHERE dp.sid NOT IN (0x01) AND dp.sid IS NOT NULL AND dp.type NOT IN (''C'') AND dp.is_fixed_role <> 1 AND dp.name NOT LIKE ''##%'' AND ''?'' NOT IN (''master'',''msdb'',''model'',''tempdb'') ORDER BY DBName' 
INSERT @T_DBuser 
EXEC sp_MSforeachdb @SQLStatement 
SELECT * FROM @T_DBuser ORDER BY DBName, UserName 
-- Database object permissions 
DECLARE @Obj VARCHAR(4000) 
DECLARE @T_Obj TABLE (DB SYSNAME, UserName SYSNAME, ObjectName SYSNAME, ObjectType SYSNAME NULL, Permission NVARCHAR(128)) 
SET @Obj='USE [?]; 
SELECT ''?'' AS DB, Us.name AS username, Obj.name AS object, case Obj.type  
when ''P'' then ''Stored Procedure'' 
when ''U'' then ''Table (user-defined)'' 
when ''V'' then ''View'' 
when ''TF'' then ''SQL table-valued-function'' 
when ''TR'' then ''SQL DML trigger'' 
when ''X'' then ''Extended stored procedure'' 
when ''FN'' then ''SQL scalar function'' 
end AS ''Object Type'', 
dp.permission_name AS permission  
FROM sys.database_permissions dp 
JOIN sys.sysusers Us  
ON dp.grantee_principal_id = Us.uid  
JOIN sys.objects Obj 
ON dp.major_id = Obj.object_id ' 
INSERT @T_Obj  
EXEC sp_MSforeachdb @Obj 
SELECT * FROM @T_Obj order by DB, UserName, ObjectName
