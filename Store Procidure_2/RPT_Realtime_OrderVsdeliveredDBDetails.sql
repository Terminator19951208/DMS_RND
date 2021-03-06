USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[RPT_Realtime_OrderVsdeliveredDBDetails]    Script Date: 14-Aug-2018 12:38:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[RPT_Realtime_OrderVsdeliveredDBDetails]
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
