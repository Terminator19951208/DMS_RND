USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[DayEnd_OutletWiseBuyer]    Script Date: 15-Aug-2018 8:30:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DayEnd_OutletWiseBuyer]
	@BatchDeliveryDate date,
	@DB_id int
	
AS
BEGIN
DELETE FROM [ODMSBI].[dbo].[tblr_OutletWiseBuyer]  where [tblr_OutletWiseBuyer].[BatchDeliveryDate]=@BatchDeliveryDate AND [tblr_OutletWiseBuyer].[DB_id]= @Db_id;
	INSERT INTO [ODMSBI].[dbo].[tblr_OutletWiseBuyer]
           ([BatchDate]
           ,[BatchDeliveryDate]
           ,[DB_id]
           ,[Orderid]
           ,[outlet_id]
           ,[sku_id])
		   SELECT  A.planned_order_date As BatchDate,A.delivery_date As BatchDeliveryDate,A.db_id, A.Orderid,A.outlet_id,B.sku_id 
From [ODMS].[dbo].tblt_Order As A 
INNER JOIN [ODMS].[dbo].tblt_Order_line AS B ON A.Orderid = B.Orderid 
where B.sku_order_type_id=1 AND B.lpec=1 AND A.delivery_date=@BatchDeliveryDate AND A.db_id=@DB_id
END
