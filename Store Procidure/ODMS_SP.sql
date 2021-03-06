USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[ApiGetOutlet]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ApiGetOutlet] 
	@Psrid int
AS
BEGIN

SELECT PSR_id      
      ,RouteName
      ,RouteID
      ,OutletId
      ,OutletCode
      ,OutletName      
       ,Address
      ,GpsLocation
      ,OwnerName
      ,ContactNo
      ,Distributorid
      ,HaveVisicooler
      ,parentid     
      ,Latitude
      ,Longitude     
      ,IsActive
      ,channel_name
      ,outlet_category_name
      ,Outlet_grade
  FROM ODMS.dbo.tbld_db_psr_outlet_zone_view 
  where PSR_id=@Psrid and IsActive=1
END

GO
/****** Object:  StoredProcedure [dbo].[ApiGetSku]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
CREATE PROCEDURE [dbo].[ApiGetSku]
	@dbid int
	
AS
BEGIN

 SELECT B.sku_id As SKUId, C.SKUName,C.SKUlpc, B.batch_id,D.qty As PackSize ,B.outlet_lifting_price AS TP, B.mrp AS MRP
FROM     tbld_distribution_house AS A INNER JOIN
                  tbld_bundle_price_details AS B ON A.PriceBuandle_id = B.bundle_price_id INNER JOIN
                  tbld_SKU AS C ON B.sku_id = C.SKU_id INNER JOIN
                  tbld_SKU_unit AS D ON C.SKUUnit = D.id
WHERE  (A.DB_Id = @dbid) and B.status=1 AND (B.end_date='0001-01-01' OR B.end_date>=GETDATE())  ANd C.SKUStatus=1
Order By C.SKUsl
END

GO
/****** Object:  StoredProcedure [dbo].[ApiGetSubRoute]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ApiGetSubRoute]
@psrid int,
@CurrentDate Datetime

AS
BEGIN
	SELECT DISTINCT  A.db_id,A.db_emp_id,A.route_id,C.RouteName,D.planned_visit_date
FROM ODMS.dbo.tbld_Route_Plan_Mapping  As A
Inner join tbld_distributor_Route As C On A.route_id=C.RouteID
LEFT JOIN (SELECT route_id
      ,dbid
      ,db_emp_id
      ,planned_visit_date
     
  FROM ODMS.dbo.tbld_Route_Plan_Detail As B
  where planned_visit_date=@CurrentDate AND B.db_emp_id=@psrid)AS D On A.db_emp_id=D.db_emp_id AND D.route_id=A.route_id
where A.db_emp_id=@psrid
END

GO
/****** Object:  StoredProcedure [dbo].[ApiGetTradePromotion]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ApiGetTradePromotion]
	@dbid int
	As
BEGIN
SELECT A.id, A.name, A.code, A.description, A.TP_type, A.TPOffer_type, A.promotion_unit_id, A.promotion_sub_unit_id, CONVERT(date,A.start_date)AS start_date , CONVERT(date,A.end_date) As end_date
FROM     tblt_TradePromotion AS A INNER JOIN
                  tblt_TradePromotionDBhouseMapping As B ON A.id = B.promo_id
WHERE  (A.start_date <= CAST(GETDATE() AS DATE)) AND (A.end_date >= CAST(GETDATE() AS DATE)) AND (A.is_active = 1) AND B.db_id=@dbid AND B.status=1
END

GO
/****** Object:  StoredProcedure [dbo].[ApiGetTradePromotionDefinition]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ApiGetTradePromotionDefinition]
	@dbid int
AS
BEGIN
	SELECT C.promo_id, C.rule_type, C.promo_line_type, C.condition_type, C.offer_type, C.condition_sku_id, C.condition_sku_Batch, C.condition_sku_pack_size, C.condition_sku_amount, C.offer_sku_id, C.offer_sku_pack_size, C.offer_sku_Batch, 
                  C.offer_sku_amount, C.condition_bundle_qty_CS, C.condition_sku_group
FROM     tblt_TradePromotion AS A INNER JOIN
                  tblt_TradePromotionDBhouseMapping AS B ON A.id = B.promo_id INNER JOIN
                  tblt_TradePromotionDefinition AS C ON A.id = C.promo_id
WHERE  (A.start_date <= CAST(GETDATE() AS DATE)) AND (A.end_date >= CAST(GETDATE() AS DATE)) AND (A.is_active = 1) AND (B.db_id = @dbid) AND (B.status = 1)
END

GO
/****** Object:  StoredProcedure [dbo].[ApiUserLogin]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ApiUserLogin]
	@UserName varchar(50),
	@Password varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;

   SELECT TOP(1) A.id AS PSRid, A.Emp_code, A.Name As PSRName, A.DistributionId AS DBId, A.contact_no AS MobileNo, B.DBName
FROM     tbld_distribution_employee AS A INNER JOIN
                  tbld_distribution_house AS B ON A.DistributionId = B.DB_Id
WHERE  (A.active = 1) AND (A.Emp_Type = 2) AND (A.login_user_id = @UserName) AND (A.login_user_password = @Password) AND (B.Status = 1)
END

GO
/****** Object:  StoredProcedure [dbo].[DailySchedule_OrderDetails]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DailySchedule_OrderDetails]
	@BatchDeliveryDate date
	
AS
BEGIN
DELETE FROM [dbo].[tblr_OrderDetails]  WHERE delivery_Process_Date=@BatchDeliveryDate ;

INSERT INTO [dbo].[tblr_OrderDetails]
           ([db_id]
           ,[psr_id]
           ,[planned_order_date]
           ,[delivery_date]
           ,[delivery_Process_Date]
           ,[Orderid]
           ,[outlet_id]
           ,[Challan_no]
           ,[sku_id]
           ,[Betch_id]
           ,[Pack_size]
           ,[unit_sale_price]
           ,[sku_order_type_id]
           ,[promotion_id]
           ,[quantity_ordered]
           ,[quantity_confirmed]
           ,[quantity_delivered]
           ,[total_sale_price])
SELECT t1.db_id, t1.psr_id, t1.planned_order_date, t1.delivery_date, t1.delivery_Process_Date, t1.Orderid, t1.outlet_id, t1.Challan_no, t2.sku_id, t2.Betch_id, t2.Pack_size, t2.unit_sale_price, 
                  t2.sku_order_type_id, t2.promotion_id, t2.quantity_ordered, t2.quantity_confirmed, t2.quantity_delivered, t2.total_sale_price
FROM     tblt_Order AS t1 INNER JOIN
                  tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
				  Where t1.delivery_Process_Date=@BatchDeliveryDate AND t1.so_status=3
END

GO
/****** Object:  StoredProcedure [dbo].[DayEnd_OutletWiseBuyer]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DayEnd_OutletWiseBuyer]
	@BatchDeliveryDate date,
	@DB_id int
	
AS
BEGIN
DELETE FROM [dbo].[tblr_OutletWiseBuyer]  where [tblr_OutletWiseBuyer].[BatchDeliveryDate]=@BatchDeliveryDate AND [tblr_OutletWiseBuyer].[DB_id]= @Db_id;
	INSERT INTO [dbo].[tblr_OutletWiseBuyer]
           ([BatchDate]
           ,[BatchDeliveryDate]
           ,[DB_id]
           ,[Orderid]
           ,[outlet_id]
           ,[sku_id])
		   SELECT  A.planned_order_date As BatchDate,A.delivery_date As BatchDeliveryDate,A.db_id, A.Orderid,A.outlet_id,B.sku_id 
From tblt_Order As A 
INNER JOIN tblt_Order_line AS B ON A.Orderid = B.Orderid 
where B.sku_order_type_id=1 AND B.lpec=1 AND A.delivery_date=@BatchDeliveryDate AND A.db_id=@DB_id
END

GO
/****** Object:  StoredProcedure [dbo].[DayEnd_OutletWiseSKUWiseDelivery]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DayEnd_OutletWiseSKUWiseDelivery]
	@Db_id int,
	@BatchDate Datetime
	
AS
BEGIN
DELETE FROM [dbo].[tblr_OutletWiseSKUWiseDelivery]  where [tblr_OutletWiseSKUWiseDelivery].BatchDate=@BatchDate AND [tblr_OutletWiseSKUWiseDelivery].Distributorid= @Db_id;
INSERT INTO [dbo].[tblr_OutletWiseSKUWiseDelivery]
           ([BatchDate]
           ,[OutletId]
           ,[OutletCode]
           ,[OutletName]
           ,[Distributorid]
           ,[HaveVisicooler]
           ,[SKUId]
           ,[SKUName]
           ,[PackSize]
           ,[UnitPrice]
           ,[SKUVolume8oz]
           ,[Delivered_Quentity]
           ,[FreeDelivered_Quentity])
SELECT 
@BatchDate                       AS BatchDate
,A.OutletId
      ,A.OutletCode
      ,A.OutletName 
      ,A.Distributorid
      ,A.HaveVisicooler
	  ,B.sku_id AS SKUId
	  ,B.SKUName
	  ,B.PackSize AS PackSize
	  ,Isnull(C.UnitPrice, 0)         AS UnitPrice
	  ,B.SKUVolume_8oz As SKUVolume8oz
	  ,Isnull(C.Delivered_Quentity, 0)         AS Delivered_Quentity,       
       Isnull(D.FreeDelivered_Quentity, 0)     AS FreeDelivered_Quentity
       
  FROM [ODMS].[dbo].[tbld_Outlet] as A

   INNER JOIN (SELECT DISTINCT t1.db_id
		,t1.outlet_id
		,t2.sku_id
		,t3.SKUName
		,t2.Pack_size as PackSize,
		 t3.SKUVolume_8oz
	FROM tblt_Order AS t1
	INNER JOIN tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
	LEFT JOIN tbld_SKU AS t3 ON t2.sku_id = t3.SKU_id
                   WHERE  t1.delivery_date = @BatchDate ) AS B 
               ON A.Distributorid = B.db_id 
                  AND A.OutletId = B.outlet_id

				  Left Join (SELECT t1.db_id, t1.outlet_id, t2.sku_id,t2.unit_sale_price as UnitPrice, sum(t2.quantity_delivered) AS Delivered_Quentity
FROM     tblt_Order as t1 INNER JOIN
                  tblt_Order_line as t2 ON t1.Orderid = t2.Orderid
				  Left Join tbld_SKU as t3 on t2.sku_id=t3.SKU_id
				  where  t1.delivery_date=@BatchDate and  t2.sku_order_type_id=1
				  Group by t1.db_id,t1.outlet_id,t3.SKUName, t2.sku_id,t2.Pack_size,t2.unit_sale_price) As C on A.Distributorid=C.db_id AND A.OutletId=C.outlet_id AND B.sku_id=C.sku_id
				   Left Join (SELECT t1.db_id, t1.outlet_id, t2.sku_id,t3.SKUName,t2.Pack_size,sum(t2.quantity_delivered) AS FreeDelivered_Quentity
FROM     tblt_Order as t1 INNER JOIN
                  tblt_Order_line as t2 ON t1.Orderid = t2.Orderid
				  Left Join tbld_SKU as t3 on t2.sku_id=t3.SKU_id
				  where  t1.delivery_date=@BatchDate and  t2.sku_order_type_id=2
				  Group by t1.db_id,t1.outlet_id,t3.SKUName, t2.sku_id,t2.Pack_size) As D on A.Distributorid=D.db_id AND A.OutletId=D.outlet_id AND B.sku_id=D.sku_id
  where A.Distributorid=@Db_id
  
  

	
END

GO
/****** Object:  StoredProcedure [dbo].[DayEnd_OutletWiseSKUWiseOrder]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DayEnd_OutletWiseSKUWiseOrder]
	@Db_id int,
	@BatchDate Datetime
	
AS
BEGIN
DELETE FROM [dbo].[tblr_OutletWiseSKUWiseOrder]  where [tblr_OutletWiseSKUWiseOrder].BatchDate=@BatchDate AND [tblr_OutletWiseSKUWiseOrder].Distributorid= @Db_id;
INSERT INTO [dbo].[tblr_OutletWiseSKUWiseOrder]
           ([BatchDate]
           ,[OutletId]
           ,[OutletCode]
           ,[OutletName]
           ,[Distributorid]
           ,[HaveVisicooler]
           ,[SKUId]
           ,[SKUName]
           ,[PackSize]
           ,[UnitPrice]
           ,[SKUVolume8oz]
           ,[Order_Quentity]
           ,[Confirmed_Quantity]
           ,[FreeOrder_Quentity]
           ,[FreeConfirmed_Quantity])
SELECT 
@BatchDate                        AS BatchDate
,A.OutletId
      ,A.OutletCode
      ,A.OutletName 
      ,A.Distributorid
      ,A.HaveVisicooler
	  ,B.sku_id AS SKUId
	  ,B.SKUName
	  ,B.PackSize AS PackSize
	  ,Isnull(C.UnitPrice, 0)         AS UnitPrice
	  ,B.SKUVolume_8oz As SKUVolume8oz
	  ,Isnull(C.order_quentity, 0)         AS Order_Quentity,	  
       Isnull(C.confirmed_quantity, 0)     AS Confirmed_Quantity, 
       Isnull(D.FreeOrder_Quentity, 0)     AS FreeOrder_Quentity, 
       Isnull(D.FreeConfirmed_Quantity, 0) AS FreeConfirmed_Quantity
  FROM tbld_Outlet as A

   INNER JOIN (SELECT DISTINCT t1.db_id
		,t1.outlet_id
		,t2.sku_id
		,t3.SKUName
		,t2.Pack_size As PackSize,
		 t3.SKUVolume_8oz
	FROM tblt_Order AS t1
	INNER JOIN tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
	LEFT JOIN tbld_SKU AS t3 ON t2.sku_id = t3.SKU_id
                   WHERE  t1.planned_order_date = @BatchDate) AS B 
               ON A.Distributorid = B.db_id 
                  AND A.OutletId = B.outlet_id

				  Left Join (SELECT t1.db_id, t1.outlet_id, t2.sku_id,t2.unit_sale_price As UnitPrice,sum(t2.quantity_ordered) AS Order_Quentity, sum(t2.quantity_confirmed) AS Confirmed_Quantity
FROM     tblt_Order as t1 INNER JOIN
                  tblt_Order_line as t2 ON t1.Orderid = t2.Orderid
				  Left Join tbld_SKU as t3 on t2.sku_id=t3.SKU_id
				  where  t1.planned_order_date=@BatchDate and  t2.sku_order_type_id=1 and t1.so_status<>9
				  Group by t1.db_id,t1.outlet_id,t3.SKUName, t2.sku_id,t2.Pack_size,t2.unit_sale_price) As C on A.Distributorid=C.db_id AND A.OutletId=C.outlet_id AND B.sku_id=C.sku_id
				   Left Join (SELECT t1.db_id, t1.outlet_id, t2.sku_id,t3.SKUName,t2.Pack_size,sum(t2.quantity_ordered) AS FreeOrder_Quentity, sum(t2.quantity_confirmed) AS FreeConfirmed_Quantity
FROM     tblt_Order as t1 INNER JOIN
                  tblt_Order_line as t2 ON t1.Orderid = t2.Orderid
				  Left Join tbld_SKU as t3 on t2.sku_id=t3.SKU_id
				  where  t1.planned_order_date=@BatchDate and  t2.sku_order_type_id=2 and t1.so_status<>9
				  Group by t1.db_id,t1.outlet_id,t3.SKUName, t2.sku_id,t2.Pack_size) As D on A.Distributorid=D.db_id AND A.OutletId=D.outlet_id AND B.sku_id=D.sku_id
  where A.Distributorid=@Db_id
  

	
END

GO
/****** Object:  StoredProcedure [dbo].[DayEnd_PerformanceKPI]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DayEnd_PerformanceKPI]
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
GO
/****** Object:  StoredProcedure [dbo].[DayEnd_Process]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DayEnd_Process] 
	@Dbid int,
	@BatchDate Datetime
	
AS
BEGIN
declare @KPIorderdate as datetime = dateadd(day,-1, @BatchDate)

INSERT INTO [dbo].[tbll_procedure_log]([dbid],[procedure_name],[start_time],[end_time]) VALUES(@Dbid,'DayEnd_Process',GETDATE(),NULL)

/*Outlet StockMovement*/
EXEC [DayEnd_StockMovement] @Db_id = @Dbid, @BatchDate = @BatchDate;

/*Outlet Order&Sales*/
EXEC [DayEnd_OutletWiseSKUWiseOrder] @Db_id = @Dbid, @BatchDate = @BatchDate;
EXEC [DayEnd_OutletWiseSKUWiseDelivery] @Db_id = @Dbid, @BatchDate = @BatchDate;

/*PSR Order&Sales*/
EXEC [DayEnd_PSRWiseSKUWiseOrder] @Db_id = @Dbid, @BatchDate = @BatchDate;
EXEC [DayEnd_PSRWiseSKUWiseDelivery] @Db_id = @Dbid, @BatchDate = @BatchDate;

/*Buyer*/
EXEC [DayEnd_OutletWiseBuyer] @Db_id = @Dbid, @BatchDeliveryDate = @BatchDate;

/*KPI*/
EXEC [DayEnd_PerformanceKPI] @Db_id = @Dbid,@BatchDate =@BatchDate;
EXEC [DayEnd_PerformanceKPI] @Db_id = @Dbid,@BatchDate =@KPIorderdate;


/*PSRWiseMonthTGT*/
EXEC [DayEnd_PSRWiseMonthTGT]	@Db_id = @Dbid,@target_id = 3,@BatchDate=@KPIorderdate
	
INSERT INTO [dbo].[tblr_Disributor_Day_End]([Dbid],[BatchDate],[ProcessDate])  VALUES (@Dbid,@BatchDate,GETDATE());

INSERT INTO [dbo].[tbll_procedure_log]([dbid],[procedure_name],[start_time],[end_time]) VALUES(@Dbid,'DayEnd_Process',NULL,GETDATE())

End

GO
/****** Object:  StoredProcedure [dbo].[DayEnd_PSRWiseMonthTGT]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DayEnd_PSRWiseMonthTGT]
	@Db_id int,
	@target_id int,
	@BatchDate Datetime
AS
BEGIN

Delete FROM [dbo].[tblr_PSRWiseMonthTGT]  where [target_id]=@target_id AND db_id=@Db_id;


INSERT INTO [dbo].[tblr_PSRWiseMonthTGT]
           ([target_id]
           ,[db_id]
           ,[psr_id]
           ,[TotalTGTCS]
           ,[TotalTGTVolume8oz]
           ,[TGTOrder]
           ,[TGTConfirmed]
           ,[TGTDelivered])
SELECT a1.target_id, a1.db_id, a1.psr_id, Sum(a1.total_Qty/a1.Pack_size) As TotalTGTCS,  Sum(a1.total_Qty * a2.SKUVolume_8oz) TotalTGTVolume8oz,IsNULL(a3.TGTOrder,0)AS TGTOrder,IsNULL(a3.TGTConfirmed,0)As TGTConfirmed,IsNULL(a3.TGTDelivered,0)AS TGTDelivered
FROM     tbld_Target_PSR_Details AS a1 INNER JOIN
                  tbld_SKU AS a2 ON a1.sku_id = a2.SKU_id
				  Left Join (SELECT t1.db_id,t1.psr_id,Sum(t2.quantity_ordered/t2.Pack_size) AS TGTOrder, 
                  Sum(t2.quantity_confirmed/t2.Pack_size) AS TGTConfirmed, Sum(t2.quantity_delivered/t2.Pack_size) AS TGTDelivered
FROM     tblt_Order AS t1 INNER JOIN
                  tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
				  where datepart(month,t1.planned_order_date)=datepart(month,@BatchDate) AND t1.db_id=@Db_id
				  group by t1.db_id,t1.psr_id) As a3 on a3.db_id=a1.db_id and a3.psr_id=a1.psr_id
				  Where a1.db_id=@Db_id and a1.target_id=@target_id
				  Group by a1.target_id, a1.db_id, a1.psr_id,a3.TGTOrder,a3.TGTConfirmed,a3.TGTDelivered
END

GO
/****** Object:  StoredProcedure [dbo].[DayEnd_PSRWiseSKUWiseDelivery]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DayEnd_PSRWiseSKUWiseDelivery]
	@Db_id int,
	@BatchDate Datetime	
AS
BEGIN

DELETE FROM [dbo].[tblr_PSRWiseSKUWiseDelivery] where [DB_id]=@Db_id  AND[BatchDate]=@BatchDate;

INSERT INTO [dbo].[tblr_PSRWiseSKUWiseDelivery]
           ([DB_id]
           ,[BatchDate]
           ,[PSRId]
           ,[PSRName]
           ,[SKUId]
           ,[SKUName]
           ,[PackSize]
           ,[SKUVolume8oz]
           ,[UnitPrice]
           ,[Delivered_Quentity]
           ,[FreeDelivered_Quentity])
SELECT A.distributionid                    AS DB_id, 
       @BatchDate                         AS BatchDate, 
       A.id                                AS PSRId, 
       A.NAME                              AS PSRName, 
       B.sku_id                            AS SKUId, 
       B.skuname                           AS SKUName, 
       B.pack_size                         AS PackSize, 
       B.skuvolume_8oz                     AS SKUVolume8oz, 
       Isnull(C.unit_sale_price, 0)        AS UnitPrice, 
       Isnull(C.delivered_quentity, 0)     AS Delivered_Quentity, 
       Isnull(D.freedelivered_quentity, 0) AS FreeDelivered_Quentity 
FROM   tbld_distribution_employee AS A 
       INNER JOIN (SELECT DISTINCT t1.db_id, 
                                   t1.psr_id, 
                                   t2.sku_id, 
                                   t3.skuname, 
                                   t2.pack_size, 
                                   t3.skuvolume_8oz 
                   FROM   tblt_order AS t1 
                          INNER JOIN tblt_order_line AS t2 
                                  ON t1.orderid = t2.orderid 
                          LEFT JOIN tbld_sku AS t3 
                                 ON t2.sku_id = t3.sku_id 
                   WHERE  t1.delivery_date = @BatchDate ) AS B 
               ON A.distributionid = B.db_id 
                  AND A.id = B.psr_id 
       LEFT JOIN (SELECT t1.db_id, 
                         t1.psr_id, 
                         t2.sku_id, 
                         t3.skuname, 
                         t2.pack_size, 
                         t2.unit_sale_price, 
                         Sum(t2.quantity_delivered) AS Delivered_Quentity 
                  FROM   tblt_order AS t1 
                         INNER JOIN tblt_order_line AS t2 
                                 ON t1.orderid = t2.orderid 
                         LEFT JOIN tbld_sku AS t3 
                                ON t2.sku_id = t3.sku_id 
                  WHERE  t1.delivery_date = @BatchDate  
                         AND t2.sku_order_type_id = 1 
                  GROUP  BY t1.db_id, 
                            t1.psr_id, 
                            t3.skuname, 
                            t2.sku_id, 
                            t2.pack_size, 
                            t2.unit_sale_price) AS C 
              ON A.distributionid = C.db_id 
                 AND A.id = C.psr_id 
                 AND B.sku_id = C.sku_id 
       LEFT JOIN (SELECT t1.db_id, 
                         t1.psr_id, 
                         t2.sku_id, 
                         t3.skuname, 
                         t2.pack_size, 
                         Sum(t2.quantity_delivered) AS FreeDelivered_Quentity 
                  FROM   tblt_order AS t1 
                         INNER JOIN tblt_order_line AS t2 
                                 ON t1.orderid = t2.orderid 
                         LEFT JOIN tbld_sku AS t3 
                                ON t2.sku_id = t3.sku_id 
                  WHERE  t1.delivery_date = @BatchDate  
                         AND t2.sku_order_type_id = 2 
                  GROUP  BY t1.db_id, 
                            t1.psr_id, 
                            t3.skuname, 
                            t2.sku_id, 
                            t2.pack_size) AS D 
              ON A.distributionid = D.db_id 
                 AND A.id = D.psr_id 
                 AND B.sku_id = D.sku_id 
WHERE  A.active = 1 
       AND A.emp_type = 2 
       AND A.distributionid = @Db_id 
	
END

GO
/****** Object:  StoredProcedure [dbo].[DayEnd_PSRWiseSKUWiseOrder]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DayEnd_PSRWiseSKUWiseOrder]
	@Db_id int,
	@BatchDate Datetime	
AS
BEGIN
DELETE FROM [dbo].[tblr_PSRWiseSKUWiseOrder] where [dbo].[tblr_PSRWiseSKUWiseOrder].[BatchDate]=@BatchDate AND [dbo].[tblr_PSRWiseSKUWiseOrder].[DB_id]=@Db_id;
INSERT INTO [dbo].[tblr_PSRWiseSKUWiseOrder]
           ([DB_id]
           ,[BatchDate]
           ,[PSRId]
           ,[PSRName]
           ,[SKUId]
           ,[SKUName]
           ,[PackSize]
           ,[SKUVolume8oz]
           ,[UnitPrice]
           ,[Order_Quentity]
           ,[Confirmed_Quantity]
           ,[FreeOrder_Quentity]
           ,[FreeConfirmed_Quantity])
SELECT A.distributionid                    AS DB_id, 
       @BatchDate                         AS BatchDate, 
       A.id                                AS PSRId, 
       A.NAME                              AS PSRName, 
       B.sku_id                            AS SKUId, 
       B.skuname                           AS SKUName, 
       B.pack_size                         AS PackSize, 
       B.skuvolume_8oz                     AS SKUVolume8oz, 
	   Isnull(C.unit_sale_price, 0)        AS UnitPrice
	,Isnull(C.Order_Quentity, 0) AS Order_Quentity
	,Isnull(C.Confirmed_Quantity, 0) AS Confirmed_Quantity
	,Isnull(D.FreeOrder_Quentity, 0) AS FreeOrder_Quentity
	,Isnull(D.FreeConfirmed_Quantity, 0) AS FreeConfirmed_Quantity
FROM tbld_distribution_employee AS A
INNER JOIN (
	SELECT DISTINCT t1.db_id
		,t1.psr_id
		,t2.sku_id
		,t3.SKUName
		,t2.Pack_size,
		 t3.SKUVolume_8oz
	FROM tblt_Order AS t1
	INNER JOIN tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
	LEFT JOIN tbld_SKU AS t3 ON t2.sku_id = t3.SKU_id
	WHERE t1.planned_order_date = @BatchDate 
	) AS B ON A.DistributionId = B.db_id
	AND A.id = B.psr_id
LEFT JOIN (
	SELECT t1.db_id
		,t1.psr_id
		,t2.sku_id
		,t3.SKUName
		,t2.Pack_size
		,t2.unit_sale_price
		,sum(t2.quantity_ordered) AS Order_Quentity
		,sum(t2.quantity_confirmed) AS Confirmed_Quantity
	FROM tblt_Order AS t1
	INNER JOIN tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
	LEFT JOIN tbld_SKU AS t3 ON t2.sku_id = t3.SKU_id
	WHERE t1.planned_order_date = @BatchDate 
		AND t2.sku_order_type_id = 1
	GROUP BY t1.db_id
		,t1.psr_id
		,t3.SKUName
		,t2.sku_id
		,t2.Pack_size
		,t2.unit_sale_price
	) AS C ON A.DistributionId = C.db_id
	AND A.id = C.psr_id
	AND B.sku_id = C.sku_id
LEFT JOIN (
	SELECT t1.db_id
		,t1.psr_id
		,t2.sku_id
		,t3.SKUName
		,t2.Pack_size
		,sum(t2.quantity_ordered) AS FreeOrder_Quentity
		,sum(t2.quantity_confirmed) AS FreeConfirmed_Quantity
	FROM tblt_Order AS t1
	INNER JOIN tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
	LEFT JOIN tbld_SKU AS t3 ON t2.sku_id = t3.SKU_id
	WHERE t1.planned_order_date = @BatchDate 
		AND t2.sku_order_type_id = 2
	GROUP BY t1.db_id
		,t1.psr_id
		,t3.SKUName
		,t2.sku_id
		,t2.Pack_size
	) AS D ON A.DistributionId = D.db_id
	AND A.id = D.psr_id
	AND B.sku_id = D.sku_id
WHERE A.active = 1	AND A.emp_type = 2	AND A.distributionid = @Db_id
	
END

GO
/****** Object:  StoredProcedure [dbo].[DayEnd_StockMovement]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DayEnd_StockMovement]
	@Db_id int,
	@BatchDate Datetime
	
AS
BEGIN
DELETE FROM [dbo].[tblr_StockMovement]  where [tblr_StockMovement].[BatchDate]=@BatchDate AND [tblr_StockMovement].[dbId]= @Db_id;
	INSERT INTO [dbo].[tblr_StockMovement]
           ([BatchDate]
           ,[dbId]
           ,[SKUid]
           ,[BatchNo]
           ,[PackSize]
           ,[db_lifting_price]
           ,[outlet_lifting_price]
           ,[mrp]
           ,[ClosingSoundStockQty]
           ,[ClosingBookedStockQty]
           ,[PrimaryChallanQty]
           ,[PrimaryQty]
           ,[SalesQty]
           ,[FreeSalesQty])

		  SELECT  @BatchDate,C.dbId, A.sku_id As SKUid, A.batch_id As BatchNo , C.packSize As PackSize , A.db_lifting_price, A.outlet_lifting_price, A.mrp, C.qtyPs AS ClosingSoundStock, ISNULL(D.BookedStock, 0) AS ClosingBookedStock, 
                  ISNULL(E.ChallanQty,0) AS PrimaryChallanQty, ISNULL(E.ReciveQty,0) As PrimaryQty,ISNULL(F.Sales, 0) AS Sales,ISNULL(F.FreeSales, 0) AS FreeSales
FROM     tbld_bundle_price_details AS A INNER JOIN
                  tbld_distribution_house AS B ON A.bundle_price_id = B.PriceBuandle_id INNER JOIN
                  tblt_inventory AS C ON A.sku_id = C.skuId AND A.batch_id = C.batchNo LEFT OUTER JOIN
                      (SELECT t1.db_id, t2.sku_id, t2.batch_id, SUM(t2.Total_qty) AS BookedStock
                       FROM      tblt_Challan AS t1 INNER JOIN
                                         tblt_Challan_line AS t2 ON t1.id = t2.challan_id
                       WHERE   (t1.db_id = @Db_id) AND (t1.challan_status = 1)
                       GROUP BY t1.db_id, t2.sku_id, t2.batch_id) AS D ON D.db_id = C.dbId AND D.sku_id = A.sku_id AND D.batch_id = C.batchNo LEFT OUTER JOIN
                      (SELECT a1.DbId, a1.ReceivedDate, a2.sku_id, a2.BatchId, SUM(a2.ChallanQty) AS ChallanQty, SUM(a2.ReciveQty) AS ReciveQty
                       FROM      tblt_PurchaseOrder AS a1 INNER JOIN
                                         tblt_PurchaseOrderLine AS a2 ON a1.Id = a2.POId
                       WHERE   (a1.ReceivedDate = @BatchDate) AND a1.DbId=@Db_id
                       GROUP BY a1.DbId, a1.ReceivedDate, a2.sku_id, a2.BatchId) AS E ON E.DbId = C.dbId AND E.sku_id = A.sku_id AND E.BatchId = C.batchNo
					   LEFT OUTER JOIN
                      (SELECT t1.db_id, t2.sku_id, t2.batch_id, SUM(t2.Confirm_qty) AS Sales,SUM(t2.Confirm_Free_qty) AS FreeSales
                       FROM      tblt_Challan AS t1 INNER JOIN
                                         tblt_Challan_line AS t2 ON t1.id = t2.challan_id
                       WHERE   (t1.db_id = @Db_id) AND (t1.challan_status = 2) AND  t1.delivery_date=@BatchDate
                       GROUP BY t1.db_id, t2.sku_id, t2.batch_id) AS F ON F.db_id = C.dbId AND F.sku_id = A.sku_id AND F.batch_id = C.batchNo 
WHERE  (B.DB_Id = @Db_id)
END


GO
/****** Object:  StoredProcedure [dbo].[DB_User_check]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[DB_User_check]
	@UserName varchar(50),
	@Password varchar(50)
AS
	SELECT A.id, A.Name, A.User_role_id, A.DistributionId, A.login_user_id, A.active, B.user_role_code, tbld_distribution_house.Zone_id, tbld_business_zone.biz_zone_category_id
FROM     tbld_distribution_employee AS A INNER JOIN
                  user_role AS B ON A.User_role_id = B.user_role_id INNER JOIN
                  tbld_distribution_house ON A.DistributionId = tbld_distribution_house.DB_Id INNER JOIN
                  tbld_business_zone ON tbld_distribution_house.Zone_id = tbld_business_zone.id INNER JOIN
                  tbld_business_zone_hierarchy ON tbld_business_zone.biz_zone_category_id = tbld_business_zone_hierarchy.id
WHERE  (A.login_user_id = @UserName) AND (A.login_user_password = @Password) AND B.isOnlineLogin=1
GO
/****** Object:  StoredProcedure [dbo].[DBidbyASM]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DBidbyASM]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [DB_Id],[AREA_id]
       FROM [MSTORE].[dbo].[tbld_db_zone_view] where [Status]=1
END

GO
/****** Object:  StoredProcedure [dbo].[DBidbyCE]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DBidbyCE]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [DB_Id],[CEAREA_id]
       FROM [MSTORE].[dbo].[tbld_db_zone_view] where [Status]=1
END

GO
/****** Object:  StoredProcedure [dbo].[DBidbyNSM]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DBidbyNSM]
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [DB_Id]
       FROM [MSTORE].[dbo].[tbld_db_zone_view] where [Status]=1
END

GO
/****** Object:  StoredProcedure [dbo].[DBidbyRSM]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DBidbyRSM]

AS
BEGIN
	
	SELECT [DB_Id],[REGION_id]
       FROM [MSTORE].[dbo].[tbld_db_zone_view] where   [Status]=1
END

GO
/****** Object:  StoredProcedure [dbo].[DBWisezone]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DBWisezone]

AS
BEGIN
SELECT dbo.tbld_distribution_house.DB_Id, dbo.tbld_distribution_house.DBName AS DB_Name, dbo.tbld_distribution_house.Zone_id AS CEAREA_id, CEAREA.biz_zone_name AS CEAREA_Name, AREA.id AS AREA_id, 
                  AREA.biz_zone_name AS AREA_Name, REGION.id AS REGION_id, REGION.biz_zone_name AS REGION_Name, dbo.tbld_business_zone.id AS National_id, dbo.tbld_business_zone.biz_zone_name AS [National], 
                  dbo.tbld_distribution_house.Status
FROM     dbo.tbld_distribution_house INNER JOIN
                  dbo.tbld_business_zone AS CEAREA ON dbo.tbld_distribution_house.Zone_id = CEAREA.id INNER JOIN
                  dbo.tbld_business_zone AS AREA ON CEAREA.parent_biz_zone_id = AREA.id INNER JOIN
                  dbo.tbld_business_zone AS REGION ON AREA.parent_biz_zone_id = REGION.id INNER JOIN
                  dbo.tbld_business_zone ON REGION.parent_biz_zone_id = dbo.tbld_business_zone.id
END

GO
/****** Object:  StoredProcedure [dbo].[GetOutletList]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetOutletList]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT t1.DB_Id, t1.DB_Name, t1.CEAREA_id, t1.CEAREA_Name, t1.AREA_id, t1.AREA_Name, t1.REGION_id, t1.REGION_Name, t1.National_id, t1.[National], t1.Status, t2.Name, t4.RouteName, t5.OutletCode, t5.OutletName, t5.Address, 
                  t5.OwnerName, t5.ContactNo, t5.HaveVisicooler, t5.IsActive
FROM     tbld_db_zone_view AS t1 INNER JOIN
                  tbld_distribution_employee AS t2 ON t2.DistributionId = t1.DB_Id INNER JOIN
                  tbld_Route_plan_Current_Route AS t3 ON t2.id = t3.db_emp_id INNER JOIN
                  tbld_distributor_Route AS t4 ON t3.route_id = t4.RouteID INNER JOIN
                  tbld_Outlet AS t5 ON t4.RouteID = t5.parentid
END

GO
/****** Object:  StoredProcedure [dbo].[RPT_ChallanVsDelivery]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RPT_ChallanVsDelivery]
	-- Add the parameters for the stored procedure here
	@Challan_no int
AS
BEGIN
SELECT t4.SKUName,t1.sku_id, t1.batch_id,t1.Pack_size, t1.Total_qty AS Total_qty,ISNULL(A.Total_delivered,0) AS Total_delivered, t2.outlet_id,t6.OutletName,ISNULL(B.Total_delivered,0) As Delivery,ISNULL(C.Total_delivered,0) As FreeDelivery
FROM     tblt_Challan_line AS t1 
INNER JOIN tblt_Order AS t2 ON t2.Challan_no= t1.challan_id
INNER JOIN tbld_Outlet AS t6 on t2.outlet_id=t6.OutletId 
Right JOIN tbld_SKU AS t4 ON t1.sku_id = t4.SKU_id 

LEFT JOIN (SELECT y1.outlet_id,y2.sku_id ,SUM(y2.quantity_delivered) AS Total_delivered 
FROM  tblt_Order AS y1
INNER JOIN tblt_Order_line AS y2 ON y2.Orderid = y1.Orderid 
WHERE y1.Challan_no=@Challan_no AND y1.so_status!=9 AND y2.sku_order_type_id=1
GROUP BY y1.outlet_id, y2.sku_id		  
			) as B  ON t1.sku_id= B.sku_id AND B.outlet_id=t2.outlet_id

LEFT JOIN (SELECT y1.outlet_id,y2.sku_id ,SUM(y2.quantity_delivered) AS Total_delivered 
FROM  tblt_Order AS y1
INNER JOIN tblt_Order_line AS y2 ON y2.Orderid = y1.Orderid 
WHERE y1.Challan_no=@Challan_no AND y1.so_status!=9 AND y2.sku_order_type_id=2
GROUP BY y1.outlet_id,y2.sku_id		  
			) as C  ON t1.sku_id= C.sku_id AND C.outlet_id=t2.outlet_id

LEFT JOIN ( SELECT x2.sku_id, x2.Betch_id,SUM(x2.quantity_delivered) AS Total_delivered 
			FROM  tblt_Order AS x1
			INNER JOIN tblt_Order_line AS x2 ON x2.Orderid = x1.Orderid 
			WHERE x1.Challan_no=@Challan_no AND x1.so_status!=9
			GROUP BY x1.db_id, x2.sku_id, x2.Betch_id				  			  
			) as A  ON t1.sku_id= A.sku_id 
						

WHERE  (t1.challan_id = @Challan_no) 
group by t1.sku_id,t2.outlet_id, t1.batch_id,t1.Pack_size, t1.Total_qty ,t6.OutletName,t4.SKUName,A.Total_delivered,B.Total_delivered,C.Total_delivered
order by t1.sku_id,t2.outlet_id
END

GO
/****** Object:  StoredProcedure [dbo].[RPT_CurrentStock]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[RPT_CurrentStock]
	@dbids varchar(Max)
AS
BEGIN
	
                 
SELECT t1.REGION_Name,t1.AREA_Name,t1.CEAREA_Name,t1.DB_Name,t1.Status, t1.DB_Id AS dbId, t5.SKUName, t2.sku_id, t2.batch_id, t2.db_lifting_price, 
                  t2.outlet_lifting_price, t2.mrp, t4.packSize, t4.qtyPs, ISNULL(A.bookedqty, 0) AS bookedqty, t4.qtyPs + ISNULL(A.bookedqty, 0) AS totalqty
FROM     tbld_db_zone_view AS t1 
INNER JOIN
                                   tbld_bundle_price_details AS t2 ON t1.PriceBuandle_id = t2.bundle_price_id INNER JOIN
                  tblt_inventory AS t4 ON t2.sku_id = t4.skuId AND t4.batchNo=t2.batch_id AND t1.DB_Id = t4.dbId INNER JOIN
                  tbld_SKU AS t5 ON t2.sku_id = t5.SKU_id LEFT OUTER JOIN
                      (SELECT t6.db_id, t7.sku_id, t7.batch_id, t7.Pack_size, SUM(t7.Total_qty) AS bookedqty
                       FROM      tblt_Challan AS t6 INNER JOIN
                                         tblt_Challan_line AS t7 ON t6.id = t7.challan_id
                       WHERE   (t6.challan_status = 1)
                       GROUP BY t6.db_id, t7.sku_id, t7.batch_id, t7.Pack_size) AS A ON A.sku_id = t2.sku_id AND A.db_id = t1.DB_Id AND A.batch_id = t2.batch_id
WHERE  t2.status = 1 AND t5.SKUStatus=1  And t1.DB_Id in  (select Value FROM dbo.FunctionStringtoIntlist(@dbids,','))

order by  t5.SKUsl

END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_BuyerByDBDetails]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Delivery_BuyerByDBDetails]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN


SELECT A.DB_Id, A.DB_Name, A.CEAREA_Name, A.AREA_Name, A.REGION_Name, A.Status, A.Cluster, A.DBCode, A.OfficeAddress, C.SKU_id, C.SKUName, ISNULL(D.TotalOutlet, 0) AS TotalOutlet, ISNULL(E.BuyerOutlet, 0) AS BuyerOutlet, 
                  ISNULL(D.TotalOutlet, 0) - ISNULL(E.BuyerOutlet, 0) AS NonBuyer
FROM     tbld_db_zone_view AS A INNER JOIN
                      (SELECT DISTINCT sku_id AS skuid, bundle_price_id
                       FROM      tbld_bundle_price_details AS t1) AS B ON A.PriceBuandle_id = B.bundle_price_id INNER JOIN
                  tbld_SKU AS C ON B.skuid = C.SKU_id LEFT OUTER JOIN
                      (SELECT Distributorid, COUNT(DISTINCT OutletId) AS TotalOutlet
                       FROM      tbld_Outlet AS a1
                       WHERE   (IsActive = 1)
                       GROUP BY Distributorid) AS D ON A.DB_Id = D.Distributorid LEFT OUTER JOIN
                      (SELECT t2.DB_id, t2.sku_id, COUNT(DISTINCT t1.OutletId) AS BuyerOutlet
                       FROM      tbld_Outlet AS t1 INNER JOIN
                                         tblr_OutletWiseBuyer AS t2 ON t1.OutletId = t2.outlet_id INNER JOIN
                                         tbld_Route_Plan_Mapping AS t3 ON t1.parentid = t3.route_id
                       WHERE   (t2.BatchDate BETWEEN @Start_Date AND @End_Date)
                       GROUP BY t2.DB_id, t2.sku_id) AS E ON A.DB_Id = E.DB_id AND B.skuid = E.sku_id
WHERE  (A.DB_Id IN (select Value FROM dbo.FunctionStringtoIntlist(@dbids,','))) AND (B.skuid IN (select Value FROM dbo.FunctionStringtoIntlist(@skuids,',')))
ORDER BY A.REGION_id, A.AREA_id, A.CEAREA_id, A.DB_Id, B.skuid

	

END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_BuyerByDBsOutletList]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Delivery_BuyerByDBsOutletList]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT  A.REGION_Name, A.AREA_Name,A.CEAREA_Name, A.DB_Name,  A.DBCode,A.cluster,  A.Name As PSR_Name, A.PSR_Code,
                  A.RouteName,A.OutletCode, A.OutletName, A.Address,A.OwnerName, A.ContactNo, IIF(A.HaveVisicooler = 1,'Yes','No') AS HaveVisicooler, ISNULL(A.channel_name,'') As Channel, ISNULL(A.outlet_category_name,'') As Category, ISNULL(A.Outlet_grade,'') As Grade
FROM     tbld_db_psr_outlet_zone_view AS A 
where A.OutletId in (SELECT DISTINCT outlet_id AS OutletId
                       FROM      tblr_OutletWiseBuyer AS t2
                       WHERE   (BatchDate BETWEEN @Start_Date AND @End_Date) AND (sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))))  AND  (A.DB_Id IN(SELECT Value FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (A.IsActive = 1)
ORDER BY A.REGION_id, A.AREA_id, A.CEAREA_id, A.DB_Id,A.PSR_id,A.RouteID
END
GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_BuyerByDBSummary]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Delivery_BuyerByDBSummary]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
Select A.DB_Id, A.DB_Name, A.CEAREA_Name, A.AREA_Name,A.REGION_Name,A.Status, A.cluster, A.DBCode, A.OfficeAddress, ISNULL(D.TotalOutlet,0) As TotalOutlet ,ISNULL(E.BuyerOutlet,0) As BuyerOutlet,(ISNULL(D.TotalOutlet,0)-ISNULL(E.BuyerOutlet,0)) AS NonBuyer
FROM     tbld_db_zone_view AS A
				  Left Join ( 
				  select a1.Distributorid, COUNT(DISTINCT a1.OutletId) AS TotalOutlet from tbld_Outlet As a1				 
				  where a1.IsActive=1
				  Group by  a1.Distributorid
				  ) As D On A.DB_Id=D.Distributorid 
				  Left Join ( 
				  select  t2.DB_id,COUNT(DISTINCT t1.OutletId) AS BuyerOutlet from tbld_Outlet As t1
				  Inner join tblr_OutletWiseBuyer As t2 on t1.OutletId =t2.outlet_id
				  Inner join tbld_Route_Plan_Mapping As t3 on t1.parentid=t3.route_id
				  Where t2.BatchDate between @Start_Date AND @End_Date And t2.sku_id In (select Value FROM dbo.FunctionStringtoIntlist(@skuids,','))
				  Group by  t2.DB_id
				  ) As E On A.DB_Id=E.DB_id
				  where A.DB_Id IN (select Value FROM dbo.FunctionStringtoIntlist(@dbids,',')) 
				  order by A.REGION_id,A.AREA_id,A.CEAREA_id, A.DB_Id

END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_BuyerByPSRDetails]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Delivery_BuyerByPSRDetails]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN


SELECT A.DB_Name, A.CEAREA_Name, A.AREA_Name,A.REGION_Name,A.PSR_id, A.PSR_Code, A.name As PSR_Name,A.cluster, A.DBCode, A.OfficeAddress, C.SKU_id, C.SKUName, ISNULL(D.TotalOutlet, 0) AS TotalOutlet, ISNULL(E.BuyerOutlet, 0) AS BuyerOutlet, 
                  ISNULL(D.TotalOutlet, 0) - ISNULL(E.BuyerOutlet, 0) AS NonBuyer
FROM     tbld_db_psr_zone_view AS A INNER JOIN
                      (SELECT DISTINCT sku_id AS skuid, bundle_price_id
                       FROM      tbld_bundle_price_details AS t1) AS B ON A.PriceBuandle_id = B.bundle_price_id INNER JOIN
                  tbld_SKU AS C ON B.skuid = C.SKU_id  Left Join ( 
				  select a1.Distributorid,a2.db_emp_id As psr_id, COUNT(DISTINCT a1.OutletId) AS TotalOutlet from tbld_Outlet As a1
				  Inner join tbld_Route_Plan_Mapping As a2 on a1.parentid=a2.route_id				   
				  where a1.IsActive=1
				  Group by  a1.Distributorid,a2.db_emp_id
				  ) As D On A.DB_Id=D.Distributorid AND A.PSR_id=D.psr_id Left Join ( 
				  select  t2.DB_id,t3.db_emp_id As psr_id,t2.sku_id,COUNT(DISTINCT t1.OutletId) AS BuyerOutlet from tbld_Outlet As t1
				  Inner join tblr_OutletWiseBuyer As t2 on t1.OutletId =t2.outlet_id
				  Inner join tbld_Route_Plan_Mapping As t3 on t1.parentid=t3.route_id
				  Where t2.BatchDate between @Start_Date and @End_Date And t2.sku_id In (select Value FROM dbo.FunctionStringtoIntlist(@skuids,','))
				  Group by  t2.DB_id,t3.db_emp_id,t2.sku_id
				  ) As E On A.DB_Id=E.DB_id And A.PSR_id=E.psr_id AND B.skuid = E.sku_id
WHERE  (A.DB_Id IN (select Value FROM dbo.FunctionStringtoIntlist(@dbids,','))) AND (B.skuid IN (select Value FROM dbo.FunctionStringtoIntlist(@skuids,',')))
ORDER BY A.REGION_id, A.AREA_id, A.CEAREA_id, A.DB_Id,A.PSR_id, B.skuid

	

END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_BuyerByPSRsOutletList]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[RPT_Delivery_BuyerByPSRsOutletList]
	@Start_Date Datetime,
	@End_Date Datetime,
	@Psrids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT  A.REGION_Name, A.AREA_Name,A.CEAREA_Name, A.DB_Name,  A.DBCode,A.cluster,  A.Name As PSR_Name, A.PSR_Code,
                  A.RouteName,A.OutletCode, A.OutletName, A.Address,A.OwnerName, A.ContactNo, IIF(A.HaveVisicooler = 1,'Yes','No') AS HaveVisicooler, ISNULL(A.channel_name,'') As Channel, ISNULL(A.outlet_category_name,'') As Category, ISNULL(A.Outlet_grade,'') As Grade
FROM     tbld_db_psr_outlet_zone_view AS A 
where A.OutletId in (SELECT DISTINCT outlet_id AS OutletId
                       FROM      tblr_OutletWiseBuyer AS t2
                       WHERE   (BatchDate BETWEEN @Start_Date AND @End_Date) AND (sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))))  AND  (A.PSR_id IN(SELECT Value FROM      dbo.FunctionStringtoIntlist(@Psrids, ','))) AND (A.IsActive = 1)
ORDER BY A.REGION_id, A.AREA_id, A.CEAREA_id, A.DB_Id,A.PSR_id,A.RouteID
END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_BuyerByPSRSummary]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Delivery_BuyerByPSRSummary]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT A.DB_Name, A.CEAREA_Name, A.AREA_Name,A.REGION_Name,A.PSR_id, A.PSR_Code, A.name As PSR_Name,A.cluster, A.DBCode, A.OfficeAddress, ISNULL(D.TotalOutlet,0) As TotalOutlet ,ISNULL(E.BuyerOutlet,0) As BuyerOutlet,(ISNULL(D.TotalOutlet,0)-ISNULL(E.BuyerOutlet,0)) AS NonBuyer
FROM     tbld_db_psr_zone_view AS A
				  Left Join ( 
				  select a1.Distributorid,a2.db_emp_id As psr_id, COUNT(DISTINCT a1.OutletId) AS TotalOutlet from tbld_Outlet As a1
				  Inner join tbld_Route_Plan_Mapping As a2 on a1.parentid=a2.route_id				   
				  where a1.IsActive=1
				  Group by  a1.Distributorid,a2.db_emp_id
				  ) As D On A.DB_Id=D.Distributorid AND A.PSR_id=D.psr_id
				  Left Join ( 
				  select  t2.DB_id,t3.db_emp_id As psr_id,COUNT(DISTINCT t1.OutletId) AS BuyerOutlet from tbld_Outlet As t1
				  Inner join tblr_OutletWiseBuyer As t2 on t1.OutletId =t2.outlet_id
				  Inner join tbld_Route_Plan_Mapping As t3 on t1.parentid=t3.route_id
				  Where t2.BatchDate between @Start_Date and @End_Date And t2.sku_id In (select Value FROM dbo.FunctionStringtoIntlist(@skuids,','))
				  Group by  t2.DB_id,t3.db_emp_id
				  ) As E On A.DB_Id=E.DB_id And A.PSR_id=E.psr_id
				  where A.DB_Id IN (select Value FROM dbo.FunctionStringtoIntlist(@dbids,','))
				  Order by A.REGION_id,A.AREA_id,A.CEAREA_id,A.DB_Id,A.PSR_id

END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_DBPerformanceKPISummary]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE  [dbo].[RPT_Delivery_DBPerformanceKPISummary]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX)
AS
BEGIN
	SELECT A.DB_Id, A.DB_Name, A.CEAREA_Name, A.AREA_Name, A.REGION_Name, A.DBCode, A.OfficeAddress, B.PerformerId,A.DB_Name AS PerformerName, 
                  C.TotalTGTCS, C.TotalTGTVolume8oz, SUM(B.SalesScheduleCall) AS SalesScheduleCall, SUM(B.SalesMemo) AS SalesMemo, SUM(B.TotalLineSold) AS TotalLineSold, SUM(B.TotalSoldInVolume) AS TotalSoldInVolume8oZ, 
                  SUM(B.TotalSoldInCase) AS TotalSoldInCase, SUM(B.TotalSoldInValue) AS TotalSoldInValue, SUM(B.TotalOrderedInVolume) AS TotalOrderedInVolume8oZ, SUM(B.TotalOrderedInCase) AS TotalOrderedInCase, 
                  SUM(B.TotalOrderedInValue) AS TotalOrderedInValue
FROM     tbld_db_zone_view AS A INNER JOIN tblr_PerformanceKPI AS B ON A.DB_Id = B.DB_id
LEFT JOIN (SELECT db_id,sum(TotalTGTCS) AS TotalTGTCS,Sum(TotalTGTVolume8oz) AS TotalTGTVolume8oz
FROM     tblr_PSRWiseMonthTGT
WHERE  target_id IN (SELECT DISTINCT t1.id FROM      tbld_Target AS t1 INNER JOIN
                                         tbl_calendar AS t2 ON t1.MonthNo = t2.MonthNo AND t1.Year=t2.Year
										 Where t2.Date between @Start_Date AND @End_Date)
GROUP BY db_id)AS C on C.db_id=A.DB_Id
Where B.BatchDate between @Start_Date AND @End_Date AND B.PerformerType=1 AND A.DB_Id IN (select Value FROM dbo.FunctionStringtoIntlist(@dbids,','))
GROUP BY A.REGION_Name, A.AREA_Name, A.CEAREA_Name, A.DB_Id, A.DB_Name, A.DBCode,A.OfficeAddress, B.PerformerId, B.PerformerName, C.TotalTGTCS, C.TotalTGTVolume8oz

END


GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_NonBuyerByDBsOutletList]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Delivery_NonBuyerByDBsOutletList]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT  A.REGION_Name, A.AREA_Name,A.CEAREA_Name, A.DB_Name,  A.DBCode,A.cluster,  A.Name As PSR_Name, A.PSR_Code,
                  A.RouteName,A.OutletCode, A.OutletName, A.Address,A.OwnerName, A.ContactNo, IIF(A.HaveVisicooler = 1,'Yes','No') AS HaveVisicooler, ISNULL(A.channel_name,'') As Channel, ISNULL(A.outlet_category_name,'') As Category, ISNULL(A.Outlet_grade,'') As Grade
FROM     tbld_db_psr_outlet_zone_view AS A 
where A.OutletId Not in (SELECT DISTINCT outlet_id AS OutletId
                       FROM      tblr_OutletWiseBuyer AS t2
                       WHERE   (BatchDate BETWEEN @Start_Date AND @End_Date) AND (sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))))  AND  (A.DB_Id IN(SELECT Value FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (A.IsActive = 1)
ORDER BY A.REGION_id, A.AREA_id, A.CEAREA_id, A.DB_Id,A.PSR_id,A.RouteID
END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_NonBuyerByPSRsOutletList]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[RPT_Delivery_NonBuyerByPSRsOutletList]
	@Start_Date Datetime,
	@End_Date Datetime,
	@Psrids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT  A.REGION_Name, A.AREA_Name,A.CEAREA_Name, A.DB_Name,  A.DBCode,A.cluster,  A.Name As PSR_Name, A.PSR_Code,
                  A.RouteName,A.OutletCode, A.OutletName, A.Address,A.OwnerName, A.ContactNo, IIF(A.HaveVisicooler = 1,'Yes','No') AS HaveVisicooler, ISNULL(A.channel_name,'') As Channel, ISNULL(A.outlet_category_name,'') As Category, ISNULL(A.Outlet_grade,'') As Grade
FROM     tbld_db_psr_outlet_zone_view AS A 
where A.OutletId Not in (SELECT DISTINCT outlet_id AS OutletId
                       FROM      tblr_OutletWiseBuyer AS t2
                       WHERE   (BatchDate BETWEEN @Start_Date AND @End_Date) AND (sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))))  AND  (A.PSR_id IN(SELECT Value FROM      dbo.FunctionStringtoIntlist(@Psrids, ','))) AND (A.IsActive = 1)
ORDER BY A.REGION_id, A.AREA_id, A.CEAREA_id, A.DB_Id,A.PSR_id,A.RouteID
END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_OutletWiseSKUWiseDelivery]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Delivery_OutletWiseSKUWiseDelivery]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, A.National_id, A.[National], A.Status, A.Name, A.PSR_id, A.PSR_Code, A.DBCode, A.OfficeAddress, A.cluster, 
                  A.RouteName, A.RouteID, A.OutletId, A.OutletCode, A.OutletName, A.OutletName_b, A.Address, A.OwnerName, A.ContactNo, A.HaveVisicooler,A.IsActive, A.channel_name, A.outlet_category_name, A.Outlet_grade, B.Distributorid,B.SKUId,B.SKUName,B.PackSize,SUM(B.Delivered_Quentity) AS Delivered_Quentity,SUM(B.Delivered_Quentity* B.UnitPrice) AS Value,
                   SUM(B.FreeDelivered_Quentity) AS FreeDelivered_Quentity
FROM     tbld_db_psr_outlet_zone_view AS A INNER JOIN
                  tblr_OutletWiseSKUWiseDelivery AS B ON A.OutletId = B.OutletId
				    where   B.BatchDate between @Start_Date AND @End_Date AND A.DB_Id IN (select Value FROM dbo.FunctionStringtoIntlist(@dbids,',')) AND B.SKUId IN (select Value FROM dbo.FunctionStringtoIntlist(@skuids,','))
				  Group by A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, A.National_id, A.[National], A.Status, A.Name, A.PSR_id, A.PSR_Code, A.DBCode, A.OfficeAddress, A.cluster, 
                  A.RouteName, A.RouteID, A.OutletId, A.OutletCode, A.OutletName, A.OutletName_b, A.Address, A.OwnerName, A.ContactNo, A.HaveVisicooler,A.IsActive, A.channel_name, A.outlet_category_name, A.Outlet_grade, B.Distributorid,B.SKUId,B.SKUName,B.PackSize

				
END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_OutletWiseSummary]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[RPT_Delivery_OutletWiseSummary]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, A.Status, A.Name, A.PSR_id, A.PSR_Code, A.DBCode, A.OfficeAddress,
                  A.RouteName, A.RouteID, A.OutletId, A.OutletCode, A.OutletName, A.OutletName_b, A.Address, A.OwnerName, A.ContactNo, A.HaveVisicooler,A.IsActive, A.channel_name, A.outlet_category_name, A.Outlet_grade, SUM(B.Delivered_Quentity/B.PackSize) AS Delivered_Quentity,SUM(B.Delivered_Quentity* B.UnitPrice) AS Value,
                   SUM(B.FreeDelivered_Quentity/B.PackSize) AS FreeDelivered_Quentity
FROM     ODMS.dbo.tbld_db_psr_outlet_zone_view AS A INNER JOIN
                  tblr_OutletWiseSKUWiseDelivery AS B ON A.OutletId = B.OutletId
				   where   B.BatchDate between @Start_Date AND @End_Date AND A.DB_Id IN (select Value FROM dbo.FunctionStringtoIntlist(@dbids,',')) AND B.SKUId IN (select Value FROM dbo.FunctionStringtoIntlist(@skuids,','))
				  Group by A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, A.Status, A.Name, A.PSR_id, A.PSR_Code, A.DBCode, A.OfficeAddress,
                  A.RouteName, A.RouteID, A.OutletId, A.OutletCode, A.OutletName, A.OutletName_b, A.Address, A.OwnerName, A.ContactNo, A.HaveVisicooler,A.IsActive, A.channel_name, A.outlet_category_name, A.Outlet_grade



				
END
GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_PSRPerformanceKPISummary]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [dbo].[RPT_Delivery_PSRPerformanceKPISummary]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX)
AS
BEGIN
	SELECT A.DB_Id, A.DB_Name, A.CEAREA_Name, A.AREA_Name, A.REGION_Name, A.DBCode, A.OfficeAddress,A.cluster,A.PSR_Code, B.PerformerId, A.Name As PerformerName, 
                  C.TotalTGTCS, C.TotalTGTVolume8oz, SUM(B.SalesScheduleCall) AS SalesScheduleCall, SUM(B.SalesMemo) AS SalesMemo, SUM(B.TotalLineSold) AS TotalLineSold, SUM(B.TotalSoldInVolume) AS TotalSoldInVolume8oZ, 
                  SUM(B.TotalSoldInCase) AS TotalSoldInCase, SUM(B.TotalSoldInValue) AS TotalSoldInValue, SUM(B.TotalOrderedInVolume) AS TotalOrderedInVolume8oZ, SUM(B.TotalOrderedInCase) AS TotalOrderedInCase, 
                  SUM(B.TotalOrderedInValue) AS TotalOrderedInValue
FROM     tbld_db_psr_zone_view AS A INNER JOIN tblr_PerformanceKPI AS B ON A.DB_Id = B.DB_id AND A.PSR_id=B.PerformerId
LEFT JOIN (SELECT db_id, psr_id, sum(TotalTGTCS) AS TotalTGTCS,Sum(TotalTGTVolume8oz) AS TotalTGTVolume8oz
FROM     tblr_PSRWiseMonthTGT
WHERE  target_id IN (SELECT DISTINCT t1.id FROM      tbld_Target AS t1 INNER JOIN
                                         tbl_calendar AS t2 ON t1.MonthNo = t2.MonthNo AND t1.Year=t2.Year
										 Where t2.Date between @Start_Date AND @End_Date)
GROUP BY db_id, psr_id)AS C on C.db_id=A.DB_Id AND C.psr_id=B.PerformerId 
Where B.BatchDate between @Start_Date AND @End_Date AND A.DB_Id IN (select Value FROM dbo.FunctionStringtoIntlist(@dbids,','))
GROUP BY A.REGION_Name, A.AREA_Name, A.CEAREA_Name, A.DB_Id, A.DB_Name, A.DBCode,A.OfficeAddress,A.cluster,A.PSR_Code, B.PerformerId, A.Name, C.TotalTGTCS, C.TotalTGTVolume8oz

END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_PSRWiseSKUWiseDelivery]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Delivery_PSRWiseSKUWiseDelivery]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
	SELECT A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, B.PSRId, B.PSRName, B.SKUId, B.SKUName, B.PackSize, 
                  B.SKUVolume8oz, B.UnitPrice, SUM(B.Delivered_Quentity)AS Delivered_Quentity, SUM(B.FreeDelivered_Quentity)AS FreeDelivered_Quentity
FROM     tbld_db_zone_view AS A INNER JOIN
                  tblr_PSRWiseSKUWiseDelivery AS B ON A.DB_Id = B.DB_id
				  where A.Status=1 and  (B.BatchDate between @Start_Date AND @End_Date) AND A.DB_Id IN (select Value FROM dbo.FunctionStringtoIntlist(@dbids,',')) AND B.SKUId IN (select Value FROM dbo.FunctionStringtoIntlist(@skuids,','))
				  GROUP BY A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name,B.PSRId, B.PSRName, B.SKUId, B.SKUName, B.PackSize, 
                  B.SKUVolume8oz, B.UnitPrice

END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Order_OutletWiseSKUWiseOrder]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Order_OutletWiseSKUWiseOrder]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids varchar(100),
	@skuids varchar(100)
AS
BEGIN
	SELECT A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, A.National_id, A.[National], A.Status, A.Name, A.PSR_id, A.PSR_Code, A.DBCode, A.OfficeAddress, A.cluster, 
                  A.RouteName, A.RouteID, A.OutletId, A.OutletCode, A.OutletName, A.OutletName_b, A.Address, A.OwnerName, A.ContactNo, A.HaveVisicooler,A.IsActive, A.channel_name, A.outlet_category_name, A.Outlet_grade, B.Distributorid,B.SKUId,B.SKUName,B.PackSize,SUM(B.Order_Quentity) AS Order_Quentity,SUM(B.Order_Quentity* B.UnitPrice) AS Value,
                   SUM(B.FreeOrder_Quentity) AS FreeOrder_Quentity
FROM     tbld_db_psr_outlet_zone_view AS A INNER JOIN
                  tblr_OutletWiseSKUWiseOrder AS B  ON A.OutletId = B.OutletId
WHERE  (B.BatchDate BETWEEN @Start_Date AND @End_Date)  AND A.DB_Id IN (select Value FROM dbo.FunctionStringtoIntlist(@dbids,',')) AND B.SKUId IN (select Value FROM dbo.FunctionStringtoIntlist(@skuids,','))
Group by A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, A.National_id, A.[National], A.Status, A.Name, A.PSR_id, A.PSR_Code, A.DBCode, A.OfficeAddress, A.cluster, 
                  A.RouteName, A.RouteID, A.OutletId, A.OutletCode, A.OutletName, A.OutletName_b, A.Address, A.OwnerName, A.ContactNo, A.HaveVisicooler,A.IsActive, A.channel_name, A.outlet_category_name, A.Outlet_grade, B.Distributorid,B.SKUId,B.SKUName,B.PackSize				

				
END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Order_PSRWiseSKUWiseOrder]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Order_PSRWiseSKUWiseOrder]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
	SELECT A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, B.PSRId, B.PSRName, B.SKUId, B.SKUName, B.PackSize, 
                  B.SKUVolume8oz, B.UnitPrice,SUM( B.Order_Quentity) AS Order_Quentity, SUM(B.Confirmed_Quantity)AS Confirmed_Quantity, SUM(B.FreeOrder_Quentity)AS FreeOrder_Quentity, SUM(B.FreeConfirmed_Quantity) AS FreeConfirmed_Quantity
FROM     tbld_db_zone_view AS A INNER JOIN
                  tblr_PSRWiseSKUWiseOrder AS B ON A.DB_Id = B.DB_id
				  where A.Status=1 and  (B.BatchDate between @Start_Date AND @End_Date) AND A.DB_Id IN (select Value FROM dbo.FunctionStringtoIntlist(@dbids,',')) AND B.SKUId IN (select Value FROM dbo.FunctionStringtoIntlist(@skuids,','))
				  GROUP BY A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name,B.PSRId, B.PSRName, B.SKUId, B.SKUName, B.PackSize, 
                  B.SKUVolume8oz, B.UnitPrice
END

GO
/****** Object:  StoredProcedure [dbo].[RPT_OrderVsStock]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_OrderVsStock] 	
	@DBID int
AS
BEGIN
	SELECT t2.db_id,t2.psr_id,t7.Name as PsrName,t5.skuId,t5.qtyPs As stockQty,A.quantity_ordered as orderQty,t4.SKUName, t1.sku_id, t1.Betch_id,t1.Pack_size,t6.OutletId,t6.OutletName,SUM(t1.quantity_ordered) AS quantity_ordered
FROM     tblt_Order AS t2 
INNER JOIN tblt_Order_line AS t1 ON t2.Orderid = t1.Orderid 
INNER JOIN tbld_Outlet AS t6 on t2.Orderid=t6.OutletId 
INNER JOIN tbld_SKU AS t4 ON t1.sku_id = t4.SKU_id 
INNER JOIN tbld_distribution_employee AS t7 ON t7.id=t2.psr_id
LEFT JOIN ( SELECT x1.db_id, x2.sku_id, x2.Betch_id,SUM(x2.quantity_ordered) AS quantity_ordered 
			FROM  tblt_Order AS x1
			INNER JOIN tblt_Order_line AS x2 ON x2.Orderid = x1.Orderid 
			WHERE x1.db_id=@DBID AND x1.so_status=1
			GROUP BY x1.db_id, x2.sku_id, x2.Betch_id				  			  
			) as A  ON t1.sku_id= A.sku_id AND t2.db_id=A.db_id AND A.Betch_id=t1.Betch_id
LEFT JOIN tblt_inventory as t5 ON t1.sku_id= t5.skuId AND t2.db_id=t5.dbId AND t1.Betch_id=t5.batchNo 
WHERE t2.db_id=@DBID AND t2.so_status=1
GROUP BY t2.db_id,t2.psr_id,t7.Name,t1.sku_id, t1.Betch_id,  t1.Pack_size, t4.SKUName,t5.skuId,t5.qtyPs,t6.OutletId,t6.OutletName,A.quantity_ordered
ORDER BY t2.db_id,t1.sku_id, t1.Betch_id
END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Realtime_OrderVsdeliveredDBDetails]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Realtime_OrderVsdeliveredDBDetails]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT A.DB_Id, A.DB_Name, A.CEAREA_Name, A.AREA_Name, A.REGION_Name, A.DBCode, A.cluster, G.SKU_id, G.SKUName, ISNULL(B.quantity_ordered, 0) AS quantity_ordered, ISNULL(B.quantity_confirmed, 
                  0) AS quantity_confirmed, ISNULL(B.quantity_ordered_value, 0) AS quantity_ordered_value, ISNULL(B.quantity_confirmed_value, 0) AS quantity_confirmed_value, ISNULL(C.Freequantity_ordered, 0) AS Freequantity_ordered, 
                  ISNULL(C.Freequantity_confirmed, 0) AS Freequantity_confirmed, ISNULL(D.quantity_delivered, 0) AS quantity_delivered, ISNULL(D.quantity_delivered_value, 0) AS quantity_delivered_value, ISNULL(E.Freequantity_delivered, 0) 
                  AS Freequantity_delivered
FROM     tbld_db_zone_view AS A INNER JOIN
                      (SELECT DISTINCT sku_id AS skuid, bundle_price_id
                       FROM      tbld_bundle_price_details AS t1
					   where t1.SKU_id IN                      (SELECT Value
                       FROM      dbo.FunctionStringtoIntlist(@skuids, ',')
					   )) AS F ON A.PriceBuandle_id = F.bundle_price_id INNER JOIN
                  tbld_SKU AS G ON F.skuid = G.SKU_id LEFT OUTER JOIN
                      (SELECT t1.db_id, t2.sku_id, SUM(t2.quantity_ordered / t2.Pack_size) AS quantity_ordered, SUM(t2.quantity_confirmed / t2.Pack_size) AS quantity_confirmed, SUM(t2.quantity_ordered * t2.unit_sale_price) 
                                         AS quantity_ordered_value, SUM(t2.quantity_confirmed * t2.unit_sale_price) AS quantity_confirmed_value
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status <> 9) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 1)
                       GROUP BY t1.db_id, t2.sku_id) AS B ON A.DB_Id = B.db_id AND B.sku_id = G.SKU_id LEFT OUTER JOIN
                      (SELECT t1.db_id, t2.sku_id, SUM(t2.quantity_ordered / t2.Pack_size) AS Freequantity_ordered, SUM(t2.quantity_confirmed / t2.Pack_size) AS Freequantity_confirmed
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status <> 9) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 2)
                       GROUP BY t1.db_id,t2.sku_id) AS C ON A.DB_Id = C.db_id AND C.sku_id = G.SKU_id LEFT OUTER JOIN
                      (SELECT t1.db_id,  t2.sku_id,SUM(t2.quantity_delivered / t2.Pack_size) AS quantity_delivered, SUM(t2.quantity_delivered * t2.unit_sale_price) AS quantity_delivered_value
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status = 3) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 1)
                       GROUP BY t1.db_id,t2.sku_id) AS D ON A.DB_Id = D.db_id AND D.sku_id = G.SKU_id LEFT OUTER JOIN
                      (SELECT t1.db_id, t2.sku_id, SUM(t2.quantity_delivered / t2.Pack_size) AS Freequantity_delivered
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status = 3) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id  IN (SELECT Value
                       FROM      dbo.FunctionStringtoIntlist(@dbids, ',')) ) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 2)
                       GROUP BY t1.db_id, t2.sku_id) AS E ON A.DB_Id = E.db_id AND E.sku_id = G.SKU_id
WHERE  (A.DB_Id IN
                      (SELECT Value
                       FROM      dbo.FunctionStringtoIntlist(@dbids, ',')))
ORDER BY A.REGION_id, A.AREA_id, A.CEAREA_id, A.DB_Id,G.SKU_id

END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Realtime_OrderVsdeliveredDBSummary]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Realtime_OrderVsdeliveredDBSummary]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT A.DB_Id, A.DB_Name, A.CEAREA_Name, A.AREA_Name,A.REGION_Name, A.DBCode,  A.cluster, ISNULL(B.quantity_ordered, 0) 
                  AS quantity_ordered, ISNULL(B.quantity_confirmed, 0) AS quantity_confirmed, ISNULL(B.quantity_ordered_value, 0) AS quantity_ordered_value, ISNULL(B.quantity_confirmed_value, 0) AS quantity_confirmed_value, 
                  ISNULL(C.Freequantity_ordered, 0) AS Freequantity_ordered, ISNULL(C.Freequantity_confirmed, 0) AS Freequantity_confirmed, ISNULL(D.quantity_delivered, 0) AS quantity_delivered, ISNULL(D.quantity_delivered_value, 0) 
                  AS quantity_delivered_value, ISNULL(E.Freequantity_delivered, 0) AS Freequantity_delivered
FROM     tbld_db_zone_view AS A LEFT OUTER JOIN
                      (SELECT t1.db_id, SUM(t2.quantity_ordered / t2.Pack_size) AS quantity_ordered, SUM(t2.quantity_confirmed / t2.Pack_size) AS quantity_confirmed, SUM(t2.quantity_ordered * t2.unit_sale_price) AS quantity_ordered_value, 
                                         SUM(t2.quantity_confirmed * t2.unit_sale_price) AS quantity_confirmed_value
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status <> 9) AND (t2.sku_id IN
                                             (SELECT Value FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id IN
                                             (SELECT Value  FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 1)
                       GROUP BY t1.db_id) AS B ON A.DB_Id = B.db_id LEFT OUTER JOIN
                      (SELECT t1.db_id,SUM(t2.quantity_ordered / t2.Pack_size) AS Freequantity_ordered, SUM(t2.quantity_confirmed / t2.Pack_size) AS Freequantity_confirmed
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status <> 9) AND (t2.sku_id IN
                                             (SELECT Value FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id IN
                                             (SELECT Value FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 2)
                       GROUP BY t1.db_id) AS C ON  A.DB_Id = C.db_id LEFT OUTER JOIN
                      (SELECT t1.db_id, SUM(t2.quantity_delivered / t2.Pack_size) AS quantity_delivered, SUM(t2.quantity_delivered * t2.unit_sale_price) AS quantity_delivered_value
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status = 3) AND (t2.sku_id IN
                                             (SELECT Value FROM      dbo.FunctionStringtoIntlist(@skuids, ',')))AND (t1.db_id IN
                                             (SELECT Value FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 1)
                       GROUP BY t1.db_id) AS D ON A.DB_Id = D.db_id LEFT OUTER JOIN
                      (SELECT t1.db_id, SUM(t2.quantity_delivered / t2.Pack_size) AS Freequantity_delivered
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status = 3) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id = 15) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 2)
                       GROUP BY t1.db_id) AS E ON  A.DB_Id = C.db_id
WHERE  (A.DB_Id IN
                      (SELECT Value FROM      dbo.FunctionStringtoIntlist(@dbids, ',')))
ORDER BY A.REGION_id, A.AREA_id, A.CEAREA_id, A.DB_Id

END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Realtime_OrderVsdeliveredDetails]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Realtime_OrderVsdeliveredDetails]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT A.DB_Id, A.DB_Name, A.CEAREA_Name, A.AREA_Name, A.REGION_Name, A.Name, A.PSR_id, A.PSR_Code, A.DBCode, A.cluster, G.SKU_id, G.SKUName, ISNULL(B.quantity_ordered, 0) AS quantity_ordered, ISNULL(B.quantity_confirmed, 
                  0) AS quantity_confirmed, ISNULL(B.quantity_ordered_value, 0) AS quantity_ordered_value, ISNULL(B.quantity_confirmed_value, 0) AS quantity_confirmed_value, ISNULL(C.Freequantity_ordered, 0) AS Freequantity_ordered, 
                  ISNULL(C.Freequantity_confirmed, 0) AS Freequantity_confirmed, ISNULL(D.quantity_delivered, 0) AS quantity_delivered, ISNULL(D.quantity_delivered_value, 0) AS quantity_delivered_value, ISNULL(E.Freequantity_delivered, 0) 
                  AS Freequantity_delivered
FROM     tbld_db_psr_zone_view AS A INNER JOIN
                      (SELECT DISTINCT sku_id AS skuid, bundle_price_id
                       FROM      tbld_bundle_price_details AS t1
					   where t1.SKU_id IN                      (SELECT Value
                       FROM      dbo.FunctionStringtoIntlist(@skuids, ',')
					   )) AS F ON A.PriceBuandle_id = F.bundle_price_id INNER JOIN
                  tbld_SKU AS G ON F.skuid = G.SKU_id LEFT OUTER JOIN
                      (SELECT t1.db_id, t1.psr_id, t2.sku_id, SUM(t2.quantity_ordered / t2.Pack_size) AS quantity_ordered, SUM(t2.quantity_confirmed / t2.Pack_size) AS quantity_confirmed, SUM(t2.quantity_ordered * t2.unit_sale_price) 
                                         AS quantity_ordered_value, SUM(t2.quantity_confirmed * t2.unit_sale_price) AS quantity_confirmed_value
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status <> 9) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 1)
                       GROUP BY t1.db_id, t1.psr_id, t2.sku_id) AS B ON A.PSR_id = B.psr_id AND B.sku_id = G.SKU_id LEFT OUTER JOIN
                      (SELECT t1.db_id, t1.psr_id, t2.sku_id, SUM(t2.quantity_ordered / t2.Pack_size) AS Freequantity_ordered, SUM(t2.quantity_confirmed / t2.Pack_size) AS Freequantity_confirmed
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status <> 9) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 2)
                       GROUP BY t1.db_id, t1.psr_id,t2.sku_id) AS C ON A.PSR_id = C.psr_id AND C.sku_id = G.SKU_id LEFT OUTER JOIN
                      (SELECT t1.db_id, t1.psr_id,  t2.sku_id,SUM(t2.quantity_delivered / t2.Pack_size) AS quantity_delivered, SUM(t2.quantity_delivered * t2.unit_sale_price) AS quantity_delivered_value
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status = 3) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 1)
                       GROUP BY t1.db_id, t1.psr_id,t2.sku_id) AS D ON A.PSR_id = D.psr_id AND D.sku_id = G.SKU_id LEFT OUTER JOIN
                      (SELECT t1.db_id, t1.psr_id, t2.sku_id, SUM(t2.quantity_delivered / t2.Pack_size) AS Freequantity_delivered
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status = 3) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 2)
                       GROUP BY t1.db_id, t1.psr_id ,t2.sku_id) AS E ON A.PSR_id = E.psr_id AND E.sku_id = G.SKU_id
WHERE  (A.DB_Id IN
                      (SELECT Value
                       FROM      dbo.FunctionStringtoIntlist(@dbids, ',')))
ORDER BY A.REGION_id, A.AREA_id, A.CEAREA_id, A.DB_Id,A.PSR_id,G.SKU_id

END

GO
/****** Object:  StoredProcedure [dbo].[RPT_Realtime_OrderVsdeliveredSummary]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_Realtime_OrderVsdeliveredSummary]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT A.DB_Id, A.DB_Name, A.CEAREA_Name, A.AREA_Name,A.REGION_Name, A.Name, A.PSR_id, A.PSR_Code, A.DBCode,  A.cluster, ISNULL(B.quantity_ordered, 0) 
                  AS quantity_ordered, ISNULL(B.quantity_confirmed, 0) AS quantity_confirmed, ISNULL(B.quantity_ordered_value, 0) AS quantity_ordered_value, ISNULL(B.quantity_confirmed_value, 0) AS quantity_confirmed_value, 
                  ISNULL(C.Freequantity_ordered, 0) AS Freequantity_ordered, ISNULL(C.Freequantity_confirmed, 0) AS Freequantity_confirmed, ISNULL(D.quantity_delivered, 0) AS quantity_delivered, ISNULL(D.quantity_delivered_value, 0) 
                  AS quantity_delivered_value, ISNULL(E.Freequantity_delivered, 0) AS Freequantity_delivered
FROM     tbld_db_psr_zone_view AS A LEFT OUTER JOIN
                      (SELECT t1.db_id, t1.psr_id, SUM(t2.quantity_ordered / t2.Pack_size) AS quantity_ordered, SUM(t2.quantity_confirmed / t2.Pack_size) AS quantity_confirmed, SUM(t2.quantity_ordered * t2.unit_sale_price) AS quantity_ordered_value, 
                                         SUM(t2.quantity_confirmed * t2.unit_sale_price) AS quantity_confirmed_value
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status <> 9) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 1)
                       GROUP BY t1.db_id, t1.psr_id) AS B ON A.PSR_id = B.psr_id LEFT OUTER JOIN
                      (SELECT t1.db_id, t1.psr_id, SUM(t2.quantity_ordered / t2.Pack_size) AS Freequantity_ordered, SUM(t2.quantity_confirmed / t2.Pack_size) AS Freequantity_confirmed
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status <> 9) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 2)
                       GROUP BY t1.db_id, t1.psr_id) AS C ON A.PSR_id = C.psr_id LEFT OUTER JOIN
                      (SELECT t1.db_id, t1.psr_id, SUM(t2.quantity_delivered / t2.Pack_size) AS quantity_delivered, SUM(t2.quantity_delivered * t2.unit_sale_price) AS quantity_delivered_value
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status = 3) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ',')))AND (t1.db_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 1)
                       GROUP BY t1.db_id, t1.psr_id) AS D ON A.PSR_id = D.psr_id LEFT OUTER JOIN
                      (SELECT t1.db_id, t1.psr_id, SUM(t2.quantity_delivered / t2.Pack_size) AS Freequantity_delivered
                       FROM      tblt_Order AS t1 INNER JOIN
                                         tblt_Order_line AS t2 ON t1.Orderid = t2.Orderid
                       WHERE   (t1.so_status = 3) AND (t2.sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ','))) AND (t1.db_id = 15) AND (t1.planned_order_date BETWEEN @Start_Date AND @End_Date) AND (t2.sku_order_type_id = 2)
                       GROUP BY t1.db_id, t1.psr_id) AS E ON A.PSR_id = E.psr_id
WHERE  (A.DB_Id IN
                      (SELECT Value
                       FROM      dbo.FunctionStringtoIntlist(@dbids, ',')))
ORDER BY A.REGION_id, A.AREA_id, A.CEAREA_id, A.DB_Id

END

GO
/****** Object:  StoredProcedure [dbo].[RPT_RoutePlan]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[RPT_RoutePlan] 
	
AS
BEGIN
	SELECT t6.DB_Id, t6.DB_Name, t6.CEAREA_id, t6.CEAREA_Name, t6.AREA_id, t6.AREA_Name, t6.REGION_id, t6.REGION_Name, t6.Status, t2.Name, t3.RouteName, t1.db_emp_id, t1.route_plan_id, t1.route_id, COUNT(t5.OutletId) AS NoOfOutlet, 
                  t1.day
FROM     tbld_Route_Plan_Mapping AS t1 INNER JOIN
                  tbld_distribution_employee AS t2 ON t1.db_emp_id = t2.id INNER JOIN
                  tbld_distributor_Route AS t3 ON t1.route_id = t3.RouteID INNER JOIN
                  tbld_Outlet AS t5 ON t1.route_id = t5.parentid INNER JOIN
                  tbld_db_zone_view AS t6 ON t1.db_id = t6.DB_Id
WHERE  (t5.IsActive = 1)
GROUP BY t1.id, t1.db_emp_id, t1.route_plan_id, t1.route_id, t1.day, t3.RouteName, t2.Name, t6.DB_Id, t6.DB_Name, t6.CEAREA_id, t6.CEAREA_Name, t6.AREA_id, t6.AREA_Name, t6.REGION_id, t6.REGION_Name, t6.Status
ORDER BY t1.db_emp_id
END

GO
/****** Object:  StoredProcedure [dbo].[RPT_StockMovement]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RPT_StockMovement] 	
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbid int
AS
BEGIN
	SELECT B.db_id, 
       A.sku_id, 
       E.skuname, 
       F.qty 
       AS PackSize, 
       A.batch_id, 
       A.db_lifting_price, 
       A.outlet_lifting_price, 
       A.mrp, 
       Isnull(C.openingsoundstockqty, 0) 
       AS OpeningSoundStockQty, 
       Isnull(C.openingbookedstockqty, 0) 
       AS OpeningBookedStockQty, 
       Isnull(D.primarychallanqty, 0) 
       AS PrimaryChallanQty, 
       Isnull(D.primaryqty, 0) 
       AS PrimaryQty, 
       Isnull(D.salesqty, 0) 
       AS SalesQty, 
       Isnull(D.freesalesqty, 0) 
       AS FreeSalesQty,
	   Isnull(( (Isnull(openingsoundstockqty,0) + Isnull(openingbookedstockqty,0) + Isnull(primaryqty,0)) - (Isnull(salesqty,0) + Isnull(freesalesqty,0)) ) 
       , 0)AS 
       ClosingStockQty
FROM   tbld_bundle_price_details AS A 
       INNER JOIN tbld_distribution_house AS B 
               ON A.bundle_price_id = B.pricebuandle_id 
       LEFT OUTER JOIN (SELECT dbid, 
                               skuid, 
                               batchno, 
                               closingsoundstockqty  AS OpeningSoundStockQty, 
                               closingbookedstockqty AS OpeningBookedStockQty 
                        FROM   tblr_stockmovement 
                        WHERE  ( batchdate = dateadd(day,-1, @Start_Date) )) AS C 
                    ON C.dbid = B.db_id 
                       AND C.skuid = A.sku_id 
                       AND C.batchno = A.batch_id 
       LEFT OUTER JOIN (SELECT dbid, 
                               skuid, 
                               batchno, 
                               Sum(primarychallanqty) AS PrimaryChallanQty, 
                               Sum(primaryqty)        AS PrimaryQty, 
                               Sum(salesqty)          AS SalesQty, 
                               Sum(freesalesqty)      AS FreeSalesQty 
                        FROM   tblr_stockmovement 
                        WHERE  ( batchdate BETWEEN @Start_Date AND @End_Date
                               ) 
                        GROUP  BY dbid, 
                                  skuid, 
                                  batchno) AS D 
                    ON D.dbid = B.db_id 
                       AND D.skuid = A.sku_id 
                       AND D.batchno = A.batch_id 
       INNER JOIN tbld_sku AS E 
               ON A.sku_id = E.sku_id 
       LEFT JOIN tbld_sku_unit AS F 
              ON E.skuunit = F.id 
			  Where B.DB_Id =@dbid
END

GO
/****** Object:  StoredProcedure [dbo].[User_check]    Script Date: 15-Aug-2018 8:28:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[User_check]
	@UserName varchar(50),
	@Password varchar(50)
AS
	SELECT A.*,B.user_role_code,C.first_name,C.biz_zone_id FROM user_info AS A
	INNER JOIN user_role AS B ON A.User_role_id=b.user_role_id
	INNER JOIN tbld_management_employee AS C ON C.login_user_id=A.User_id
	WHERE A.User_Name=@UserName AND A.User_Password=@Password AND B.isOnlineLogin=1
GO
