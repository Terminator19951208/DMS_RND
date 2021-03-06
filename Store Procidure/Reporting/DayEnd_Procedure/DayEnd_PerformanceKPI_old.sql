USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[DayEnd_PerformanceKPI]    Script Date: 11-Aug-2018 10:08:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DayEnd_PerformanceKPI]
	@Db_id int,
	@BatchDate Datetime
	
AS
BEGIN

DELETE [dbo].[tblr_PerformanceKPI] where BatchDate=@BatchDate AND[DB_id]=@Db_id;

--Generate PSR KPI

INSERT INTO [dbo].[tblr_PerformanceKPI]
           ([DB_id]
           ,[BatchDate]
           ,[PerformerId]
           ,[PerformerName]
           ,[PerformerType]
           ,[SalesScheduleCall]
           ,[SalesMemo]
           ,[TotalLineSold]
           ,[TotalSoldInVolume]
           ,[TotalSoldInCase]
           ,[TotalSoldInValue]          
           ,[TotalOrderedInVolume]
           ,[TotalOrderedInCase]
           ,[TotalOrderedInValue])	

SELECT A.distributionid                  AS DB_id, 
       @BatchDate                     AS BatchDate, 
       A.id                              AS PerformerId, 
       A.NAME                            AS PerformerName, 
       A.emp_type                        AS PerformerType, 
       Isnull(B.salesschedulecall, 0)    AS SalesScheduleCall, 
       Isnull(C.salesmemo, 0)            AS SalesMemo, 
       Isnull(D.totallinesold, 0)        AS TotalLineSold, 
       Isnull(D.totalsoldinvolume, 0)    AS TotalSoldInVolume, 
       Isnull(D.totalsoldincase, 0)      AS TotalSoldInCase, 
       Isnull(D.totalsoldinvalue, 0)     AS TotalSoldInValue, 
       Isnull(E.totalorderedinvolume, 0) AS TotalOrderedInVolume, 
       Isnull(E.totalorderedincase, 0)   AS TotalOrderedInCase, 
       Isnull(E.totalorderedinvalue, 0)  AS TotalOrderedInValue 
FROM   tbld_distribution_employee AS A 
       LEFT JOIN (SELECT T1.dbid, 
                         T1.db_emp_id, 
                         Count(T2.outletid) AS SalesScheduleCall 
                  FROM   tbld_route_plan_detail AS T1 
                         INNER JOIN tbld_outlet AS T2 
                                 ON T1.route_id = T2.parentid 
                  WHERE  planned_visit_date = @BatchDate
                         AND isactive = 1 
                  GROUP  BY T1.db_emp_id, 
                            T1.dbid) AS B 
              ON A.distributionid = B.dbid 
                 AND A.id = B.db_emp_id 
       LEFT JOIN (SELECT db_id, 
                         psr_id, 
                         Count(orderid) AS SalesMemo 
                  FROM   tblt_order 
                  WHERE  planned_order_date = @BatchDate
                         AND so_status != 9 AND isProcess=1
                  GROUP  BY db_id, 
                            psr_id) AS C 
              ON A.distributionid = C.db_id 
                 AND A.id = C.psr_id 
       LEFT JOIN (SELECT T1.db_id, 
                         T1.psr_id, 
                         Sum(T2.lpec)AS 
                         TotalLineSold, 
                         Sum(Cast(T2.quantity_delivered AS FLOAT) * Cast( 
                             T3.skuvolume_8oz AS FLOAT))   AS 
                         TotalSoldInVolume, 
                         Sum(Cast(T2.quantity_delivered AS FLOAT) / Cast( 
                             pack_size AS FLOAT)) 
                                                                 AS 
                         TotalSoldInCase, 
                         Sum(Cast(T2.quantity_delivered AS FLOAT) * Cast( 
                             T2.unit_sale_price AS FLOAT)) AS 
                         TotalSoldInValue 
                  FROM   tblt_order AS T1 
                         INNER JOIN tblt_order_line AS T2 
                                 ON T1.orderid = T2.orderid 
                         INNER JOIN tbld_sku AS T3 
                                 ON T2.sku_id = T3.sku_id 
                  WHERE  ( T1.planned_order_date = @BatchDate) 
                         AND ( T1.so_status <> 9 ) AND ( T1.so_status =3 ) AND T1.isProcess=1
                  GROUP  BY T1.db_id, 
                            T1.psr_id)AS D 
              ON A.distributionid = D.db_id 
                 AND A.id = D.psr_id 
       LEFT JOIN (SELECT T1.db_id, 
                         T1.psr_id, 
                         Sum(Cast(T2.quantity_confirmed AS FLOAT) * Cast( 
                             T3.skuvolume_8oz AS FLOAT))   AS 
                         TotalOrderedInVolume, 
                         Sum(Cast(T2.quantity_confirmed AS FLOAT) / Cast( 
                             pack_size AS FLOAT)) 
                                                                 AS 
                         TotalOrderedInCase, 
                         Sum(Cast(T2.quantity_confirmed AS FLOAT) * Cast( 
                             T2.unit_sale_price AS FLOAT)) AS 
                         TotalOrderedInValue 
                  FROM   tblt_order AS T1 
                         INNER JOIN tblt_order_line AS T2 
                                 ON T1.orderid = T2.orderid 
                         INNER JOIN tbld_sku AS T3 
                                 ON T2.sku_id = T3.sku_id 
                  WHERE  ( T1.planned_order_date = @BatchDate) 
                         AND ( T1.so_status <> 9 ) AND T1.isProcess=1
                  GROUP  BY T1.db_id, 
                            T1.psr_id)AS E 
              ON A.distributionid = E.db_id 
                 AND A.id = E.psr_id 
WHERE  A.active = 1 
       AND A.emp_type = 2 
       AND A.distributionid =@Db_id

--Generate DB KPI 

INSERT INTO [dbo].[tblr_PerformanceKPI]
           ([DB_id]
           ,[BatchDate]
           ,[PerformerId]
           ,[PerformerName]
           ,[PerformerType]
           ,[SalesScheduleCall]
           ,[SalesMemo]
           ,[TotalLineSold]
           ,[TotalSoldInVolume]
           ,[TotalSoldInCase]
           ,[TotalSoldInValue]          
           ,[TotalOrderedInVolume]
           ,[TotalOrderedInCase]
           ,[TotalOrderedInValue])

SELECT A.DB_Id                  AS DB_id, 
       @BatchDate                      AS BatchDate, 
       A.DB_Id                              AS PerformerId, 
       A.DBName                            AS PerformerName, 
       1							      AS PerformerType, 
       Isnull(B.salesschedulecall, 0)    AS SalesScheduleCall, 
       Isnull(C.salesmemo, 0)            AS SalesMemo, 
       Isnull(D.totallinesold, 0)        AS TotalLineSold, 
       Isnull(D.totalsoldinvolume, 0)    AS TotalSoldInVolume, 
       Isnull(D.totalsoldincase, 0)      AS TotalSoldInCase, 
       Isnull(D.totalsoldinvalue, 0)     AS TotalSoldInValue, 
       Isnull(E.totalorderedinvolume, 0) AS TotalOrderedInVolume, 
       Isnull(E.totalorderedincase, 0)   AS TotalOrderedInCase, 
       Isnull(E.totalorderedinvalue, 0)  AS TotalOrderedInValue 
FROM   tbld_distribution_house AS A 
       LEFT JOIN (SELECT t1.dbid, 
                         Count(t2.outletid) AS SalesScheduleCall 
                  FROM   tbld_route_plan_detail AS t1 
                         INNER JOIN tbld_outlet AS t2 
                                 ON t1.route_id = t2.parentid 
                  WHERE  planned_visit_date = @BatchDate 
                         AND isactive = 1 
                  GROUP  BY  t1.dbid) AS B 
              ON A.DB_Id = B.dbid 
       LEFT JOIN (SELECT db_id, 
                         Count(orderid) AS SalesMemo 
                  FROM   tblt_order 
                  WHERE  planned_order_date = @BatchDate 
                         AND so_status != 9 
                  GROUP  BY db_id) AS C 
              ON A.DB_Id = C.db_id
       LEFT JOIN (SELECT t1.db_id ,
                         Sum(t2.lpec) AS TotalLineSold , 
                         Sum(Cast(t2.quantity_delivered AS FLOAT) * Cast( 
                             t3.skuvolume_8oz AS FLOAT)) AS 
                         TotalSoldInVolume ,
						  Sum(Cast(t2.quantity_delivered AS FLOAT) / Cast( 
                             pack_size AS FLOAT)) AS 
                         TotalSoldInCase 						 ,
                         Sum(Cast(t2.quantity_delivered AS FLOAT) * Cast( 
                             t2.unit_sale_price AS FLOAT)) AS 
                         TotalSoldInValue 
                  FROM   tblt_order AS t1 
                         INNER JOIN tblt_order_line AS t2 
                                 ON t1.orderid = t2.orderid 
                         INNER JOIN tbld_sku AS t3 
                                 ON t2.sku_id = t3.sku_id 
                  WHERE  ( t1.planned_order_date = @BatchDate ) 
                          
                         AND ( T1.so_status <> 9 ) AND ( T1.so_status =3 ) AND T1.isProcess=1
                  GROUP  BY t1.db_id)AS D 
              ON A.DB_Id = D.db_id 
       
       LEFT JOIN (SELECT t1.db_id ,
                         Sum(Cast(t2.quantity_delivered AS FLOAT) * Cast( 
                             t2.unit_sale_price AS FLOAT)) AS 
                         TotalSoldInValue , 
                         Sum(Cast(t2.quantity_confirmed AS FLOAT) * Cast( 
                             t3.skuvolume_8oz AS FLOAT)) AS 
                         TotalOrderedInVolume ,Sum(Cast(t2.quantity_confirmed AS FLOAT) / Cast( 
                             pack_size AS FLOAT)) AS 
                         TotalOrderedInCase ,
						 
                         Sum(Cast(t2.quantity_confirmed AS FLOAT) * Cast( 
                             t2.unit_sale_price AS FLOAT)) AS 
                         TotalOrderedInValue 
                  FROM   tblt_order AS t1 
                         INNER JOIN tblt_order_line AS t2 
                                 ON t1.orderid = t2.orderid 
                         INNER JOIN tbld_sku AS t3 
                                 ON t2.sku_id = t3.sku_id 
                  WHERE  ( t1.planned_order_date = @BatchDate ) 
                         AND ( t1.so_status <> 9 ) AND T1.isProcess=1
                  GROUP  BY t1.db_id)AS E 
              ON A.DB_Id = E.db_id     
           
WHERE  A.DB_Id =@Db_id
END