USE [ODMS]
GO
/****** Object:  StoredProcedure [dbo].[ApiUserLogin]    Script Date: 31-Jul-2018 12:23:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ApiUserLogin]
	@UserName varchar(50),
	@Password varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;

   SELECT TOP(1) A.id AS PSRid, A.Emp_code, A.Name As PSRName, A.DistributionId AS DBId, A.contact_no AS MobileNo, B.DBName
FROM     tbld_distribution_employee AS A INNER JOIN
                  tbld_distribution_house AS B ON A.DistributionId = B.DB_Id
WHERE  (A.active = 1) AND (A.Emp_Type = 2) AND (A.login_user_id = @UserName) AND (A.login_user_password = @Password) AND (B.Status = 1)
END
