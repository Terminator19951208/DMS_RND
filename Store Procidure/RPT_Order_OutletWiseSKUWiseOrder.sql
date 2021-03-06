USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[RPT_Order_OutletWiseSKUWiseOrder]    Script Date: 14-Aug-2018 10:45:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[RPT_Order_OutletWiseSKUWiseOrder]
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
