USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_BuyerByDBDetails]    Script Date: 13-Aug-2018 3:26:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[RPT_Delivery_BuyerByPSRDetails]
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
