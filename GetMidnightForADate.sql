select DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) --midnight


select CAST(CAST(DATEADD(MM, -6, GETDATE()) - DATEPART(DAY, GETDATE()) + 1 AS DATE) AS DATETIME)