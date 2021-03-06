USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_BuyerByDBsOutletList]    Script Date: 13-Aug-2018 12:47:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[RPT_Delivery_BuyerByDBsOutletList]
	@Start_Date Datetime,
	@End_Date Datetime,
	@dbids Varchar(MAX),
	@skuids Varchar(MAX)
AS
BEGIN
SELECT A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, A.National_id, A.[National], A.Status, A.Name, A.PSR_id, A.PSR_Code, A.DBCode, A.OfficeAddress, A.cluster, 
                  A.RouteName, A.RouteID, A.OutletId, A.OutletCode, A.OutletName, A.OutletName_b, A.Location, A.Address, A.GpsLocation, A.OwnerName, A.ContactNo, A.Distributorid, A.HaveVisicooler, A.parentid, A.outlet_category_id, A.grading, 
                  A.channel, A.Latitude, A.Longitude, A.picture, A.IsActive, A.channel_name, A.outlet_category_name, A.Outlet_grade
FROM     tbld_db_psr_outlet_zone_view AS A INNER JOIN
                      (SELECT DISTINCT outlet_id AS OutletId
                       FROM      tblr_OutletWiseBuyer AS t2
                       WHERE   (BatchDate BETWEEN @Start_Date AND @End_Date) AND (sku_id IN
                                             (SELECT Value
                                              FROM      dbo.FunctionStringtoIntlist(@skuids, ',')))) AS C ON A.OutletId = C.OutletId
WHERE  (A.DB_Id IN
                      (SELECT Value
                       FROM      dbo.FunctionStringtoIntlist(@dbids, ','))) AND (A.IsActive = 1)
ORDER BY A.REGION_id, A.AREA_id, A.CEAREA_id, A.DB_Id,A.RouteID,A.PSR_id
END
