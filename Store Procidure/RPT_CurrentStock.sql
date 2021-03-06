USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[RPT_CurrentStock]    Script Date: 11-Aug-2018 4:03:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE  [dbo].[RPT_CurrentStock]
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
