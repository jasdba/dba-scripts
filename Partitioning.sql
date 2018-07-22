1. create partition function to define the boundaries for the partitions. 
[FACT: There should be 1 less PF than filegroups.] 
 
2. create partition scheme to map the part funct to the FGps. 
3. create the table on the partition scheme. 
 
1.  
CREATE PARTITION FUNCTION [MonthlyPF](datetime) AS RANGE RIGHT FOR VALUES ( 
N'2008-04-01',  
N'2008-05-01',  
N'2008-06-01',  
 
'Range Right' means the boundary value falls in the right partition. 
 
means 
 
< or 
>= 
 
Range Left means the boundary value falls in the left partition. 
 
i.e. 
in first partition: 
all values < '2008-04-01' - all values less but not equal to 1stApril2008. 
 
 
in second partition: 
all values >= '2008-04-01' and < '2008-05-01' 
 
in third partition: 
all values >= '2008-05-01' and < '2008-06-01' 
 
in fourth partition: 
all values >= '2008-06-01' and so on. 
 
 
2.  
CREATE PARTITION SCHEME [MonthlyPS] AS PARTITION [MonthlyPF] 
TO  
( 
[FGMonth01], 
[FGMonth02], 
[FGMonth03], 
[FGMonth04], 
 
This maps the partition function to the filegroups. 
 
 