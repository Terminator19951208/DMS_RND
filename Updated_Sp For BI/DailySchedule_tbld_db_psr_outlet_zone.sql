USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[DailySchedule_tbld_db_psr_outlet_zone]    Script Date: 15-Aug-2018 9:16:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DailySchedule_tbld_db_psr_outlet_zone]
AS
	BEGIN
	TRUNCATE TABLE [ODMSBI].[dbo].[tbld_db_psr_outlet_zone];

INSERT INTO [ODMSBI].[dbo].[tbld_db_psr_outlet_zone]
           ([National_id]
           ,[National]
           ,[REGION_id]
           ,[REGION_Name]
           ,[AREA_id]
           ,[AREA_Name]
           ,[CEAREA_id]
           ,[CEAREA_Name]
           ,[DB_Id]
           ,[DB_Name]
           ,[Status]
           ,[Name]
           ,[PSR_id]
           ,[PSR_Code]
           ,[DBCode]
           ,[OfficeAddress]
           ,[cluster]
           ,[RouteName]
           ,[RouteID]
           ,[OutletId]
           ,[OutletCode]
           ,[OutletName]
           ,[OutletName_b]
           ,[Location]
           ,[Address]
           ,[GpsLocation]
           ,[OwnerName]
           ,[ContactNo]
           ,[Distributorid]
           ,[HaveVisicooler]
           ,[parentid]
           ,[outlet_category_id]
           ,[grading]
           ,[channel]
           ,[Latitude]
           ,[Longitude]
           ,[picture]
           ,[IsActive]
           ,[channel_name]
           ,[outlet_category_name]
           ,[Outlet_grade])
SELECT D.[National_id]
           ,D.[National]
           ,D.[REGION_id]
           ,D.[REGION_Name]
           ,D.[AREA_id]
           ,D.[AREA_Name]
           ,D.[CEAREA_id]
           ,D.[CEAREA_Name]
           ,D.[DB_Id]
           ,D.[DB_Name]
           ,D.[Status], D.Name, D.PSR_id, D.PSR_Code, D.DBCode, D.OfficeAddress, 
                  D.cluster, B.RouteName, B.RouteID, A.OutletId, A.OutletCode, A.OutletName, A.OutletName_b, A.Location, A.Address, A.GpsLocation, A.OwnerName, A.ContactNo, A.Distributorid, A.HaveVisicooler, A.parentid, A.outlet_category_id, 
                  A.grading, A.channel, A.Latitude, A.Longitude, A.picture, A.IsActive, dbo.tbld_Outlet_channel.name AS channel_name, dbo.tbld_Outlet_category.outlet_category_name, dbo.tbld_Outlet_grade.name AS Outlet_grade
FROM     dbo.tbld_Outlet AS A INNER JOIN
                  dbo.tbld_distributor_Route AS B ON A.parentid = B.RouteID LEFT OUTER JOIN
                  dbo.tbld_Outlet_channel ON A.channel = dbo.tbld_Outlet_channel.id LEFT OUTER JOIN
                  dbo.tbld_Outlet_category ON A.outlet_category_id = dbo.tbld_Outlet_category.id LEFT OUTER JOIN
                  dbo.tbld_Outlet_grade ON A.grading = dbo.tbld_Outlet_grade.id INNER JOIN
                      (SELECT DISTINCT db_id, db_emp_id, route_plan_id, route_id
                       FROM      dbo.tbld_Route_Plan_Mapping) AS C ON B.RouteID = C.route_id LEFT OUTER JOIN
                  dbo.tbld_db_psr_zone_view AS D ON D.PSR_id = C.db_emp_id
END
