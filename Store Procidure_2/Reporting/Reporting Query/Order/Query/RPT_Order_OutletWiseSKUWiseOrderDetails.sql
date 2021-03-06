USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[RPT_Order_OutletWiseSKUWiseOrderDetails]    Script Date: 15-Jul-18 9:44:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[RPT_Order_OutletWiseSKUWiseOrderDetails]
	@Start_Date Datetime,
	@End_Date Datetime
AS
BEGIN
	SELECT A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name,B.OutletId, B.OutletCode, B.OutletName,
                  C.Address, C.ContactNo, E.RouteName, D.name As Channel,B.Distributorid, B.HaveVisicooler, B.SKUId, B.SKUName, 
                  B.PackSize, SUM(B.Confirmed_Quantity/B.PackSize) AS Confirmed_Quantity, SUM(B.Confirmed_Quantity*NULLIF(B.UnitPrice,0)) AS Value, SUM(B.FreeConfirmed_Quantity/B.PackSize) AS FreeConfirmed_Quantity
FROM     tbld_db_zone_view AS A INNER JOIN
                  tblr_OutletWiseSKUWiseOrder AS B ON A.DB_Id = B.Distributorid INNER JOIN
                  tbld_Outlet AS C ON C.OutletId = B.OutletId LEFT  JOIN
                  tbld_Outlet_channel AS D ON C.channel = D.id LEFT JOIN
                  tbld_distributor_Route AS E ON C.parentid = E.RouteID
				  where   B.BatchDate between @Start_Date AND @End_Date
GROUP BY A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, B.OutletId, B.OutletCode, B.OutletName,
                  C.Address, C.ContactNo, E.RouteName, D.name,B.Distributorid, B.HaveVisicooler, B.SKUId, B.SKUName,B.PackSize
				  order by B.OutletId

				
END
