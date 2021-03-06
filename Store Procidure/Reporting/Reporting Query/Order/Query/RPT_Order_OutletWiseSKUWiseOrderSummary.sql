USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[RPT_Order_OutletWiseSKUWiseOrderSummary]    Script Date: 15-Jul-18 10:12:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[RPT_Order_OutletWiseSKUWiseOrderSummary]
	@Start_Date Datetime,
	@End_Date Datetime
AS
BEGIN
SELECT A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, B.OutletId, B.OutletCode, B.OutletName,
                  C.Address, C.ContactNo, E.RouteName, D.name As Channel,B.Distributorid, B.HaveVisicooler,  SUM(B.Confirmed_Quantity /B.PackSize) AS Confirmed_Quantity, SUM(B.Confirmed_Quantity * NULLIF(B.UnitPrice,0)) AS Value, SUM(B.FreeConfirmed_Quantity/B.PackSize) AS FreeConfirmed_Quantity
FROM     tbld_db_zone_view AS A INNER JOIN
 tbld_Outlet AS C ON C.Distributorid = A.DB_Id INNER  JOIN

                  tblr_OutletWiseSKUWiseOrder AS B ON B.OutletId = c.OutletId INNER JOIN
                 
                  tbld_Outlet_channel AS D ON C.channel = D.id LEFT JOIN
                  tbld_distributor_Route AS E ON C.parentid = E.RouteID
				  where   B.BatchDate between @Start_Date AND @End_Date 
GROUP BY A.DB_Id, A.DB_Name, A.CEAREA_id, A.CEAREA_Name, A.AREA_id, A.AREA_Name, A.REGION_id, A.REGION_Name, B.OutletId, B.OutletCode, B.OutletName,
                  C.Address, C.ContactNo, E.RouteName, D.name,B.Distributorid, B.HaveVisicooler
				

				
END
