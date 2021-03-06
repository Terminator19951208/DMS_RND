USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[ApiGetTradePromotionDefinition]    Script Date: 31-Jul-2018 5:44:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ApiGetTradePromotionDefinition]
	@dbid int
AS
BEGIN
	SELECT C.promo_id, C.rule_type, C.promo_line_type, C.condition_type, C.offer_type, C.condition_sku_id, C.condition_sku_Batch, C.condition_sku_pack_size, C.condition_sku_amount, C.offer_sku_id, C.offer_sku_pack_size, C.offer_sku_Batch, 
                  C.offer_sku_amount, C.condition_bundle_qty_CS, C.condition_sku_group
FROM     tblt_TradePromotion AS A INNER JOIN
                  tblt_TradePromotionDBhouseMapping AS B ON A.id = B.promo_id INNER JOIN
                  tblt_TradePromotionDefinition AS C ON A.id = C.promo_id
WHERE  (A.start_date <= CAST(GETDATE() AS DATE)) AND (A.end_date >= CAST(GETDATE() AS DATE)) AND (A.is_active = 1) AND (B.db_id = @dbid) AND (B.status = 1)
END
