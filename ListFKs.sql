-- Query to list any foreign keys referencing a particular given table.

select t2.name as 'Referenced Table', f.name as 'Foreign Key', t.name as 'Referenced By Table'
from sys.foreign_keys f
    left join sys.tables t
    on f.parent_object_id = t.object_id
    left join sys.tables t2
    on f.referenced_object_id = t2.object_id

where t2.name = 'tblVendor'

order by t.name, f.name
go