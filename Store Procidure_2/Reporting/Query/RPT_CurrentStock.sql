USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[RPT_CurrentStock]    Script Date: 26-Jul-18 4:20:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE  [dbo].[RPT_CurrentStock]
	@DBId INT
AS
BEGIN
	
                 
SELECT t8.REGION_Name,t8.AREA_Name,t8.CEAREA_Name,t8.DB_Name,t8.Status, t1.DB_Id AS dbId, t5.SKUName, t3.sku_id, t3.batch_id, t3.db_lifting_price, 
                  t3.outlet_lifting_price, t3.mrp, t4.packSize, t4.qtyPs, ISNULL(A.bookedqty, 0) AS bookedqty, t4.qtyPs + ISNULL(A.bookedqty, 0) AS totalqty
FROM     tbld_distribution_house AS t1 INNER JOIN
                                   tbld_bundle_price_details AS t3 ON t1.PriceBuandle_id = t3.bundle_price_id INNER JOIN
                  tblt_inventory AS t4 ON t3.sku_id = t4.skuId AND t4.batchNo=t3.batch_id AND t1.DB_Id = t4.dbId LEFT OUTER JOIN
                  tbld_db_zone_view AS t8 ON t8.DB_Id = t1.DB_Id INNER JOIN
                  tbld_SKU AS t5 ON t3.sku_id = t5.SKU_id LEFT OUTER JOIN
                      (SELECT t6.db_id, t7.sku_id, t7.batch_id, t7.Pack_size, SUM(t7.Total_qty) AS bookedqty
                       FROM      tblt_Challan AS t6 INNER JOIN
                                         tblt_Challan_line AS t7 ON t6.id = t7.challan_id
                       WHERE   (t6.challan_status = 1)
                       GROUP BY t6.db_id, t7.sku_id, t7.batch_id, t7.Pack_size) AS A ON A.sku_id = t3.sku_id AND A.db_id = t1.DB_Id AND A.batch_id = t3.batch_id
WHERE  t3.status = 1 AND t5.SKUStatus=1 AND t1.DB_Id=@DBId
order by t5.SKUsl

END
