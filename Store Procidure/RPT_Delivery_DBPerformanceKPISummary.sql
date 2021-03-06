USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[RPT_Delivery_DBPerformanceKPISummary]    Script Date: 13-Aug-2018 6:21:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE  [dbo].[RPT_Delivery_DBPerformanceKPISummary]
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

