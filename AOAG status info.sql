-- Health and status of WSFC cluster. These two queries work only if the WSFC has quorum
SELECT * FROM sys.dm_hadr_cluster
SELECT * FROM sys.dm_hadr_cluster_members
-- Health of the AGs
SELECT ag.name agname, ags.* FROM sys.dm_hadr_availability_group_states ags INNER JOIN sys.availability_groups ag ON ag.group_id = ags.group_id
-- Health and status of AG replics from the WsFC perspective
SELECT ar.replica_server_name,harc.* FROM sys.dm_hadr_availability_replica_cluster_states harc INNER JOIN sys.availability_replicas ar ON ar.replica_id = harc.replica_id
-- Health and status of AG replicas, run this on the primary replica. 
-- On secondary this will only show info for that instance
SELECT * FROM sys.dm_hadr_availability_replica_states 
-- Health and status of AG databases from the WSFC perspective
SELECT * FROM sys.dm_hadr_database_replica_cluster_states 
-- Health and status of AG databases, run this on the primary replica. 
-- On secondary this will only show info for that instance
SELECT  ag.name ag_name ,
        ar.replica_server_name ,
        adc.database_name ,
        hdrs.database_state_desc ,
        hdrs.synchronization_state_desc ,
        hdrs.synchronization_health_desc ,
        agl.dns_name ,
        agl.port
-- ,*
FROM    sys.dm_hadr_database_replica_states hdrs
        LEFT JOIN sys.availability_groups ag ON hdrs.group_id =ag.group_id
        LEFT  JOIN sys.availability_replicas ar ON ag.group_id = ar.group_id
                                                   AND ar.replica_id = hdrs.replica_id
        LEFT  JOIN sys.availability_databases_cluster adc ON adc.group_id = ag.group_id
                                                             AND adc.group_database_id = hdrs.group_database_id
        LEFT  JOIN sys.availability_group_listeners agl ON agl.group_id = ag.group_id
ORDER BY ag.name , adc.database_name
-- Health and status of AG listeners
SELECT agl.dns_name, agl.port, aglia.* FROM sys.availability_group_listener_ip_addresses aglia INNER JOIN sys.availability_group_listeners agl ON agl.listener_id = aglia.listener_id