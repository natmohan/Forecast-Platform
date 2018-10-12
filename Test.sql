/****** Object:  StoredProcedure [dbo].[UspAssumptionLibrary]    Script Date: 10/12/2018 5:19:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[UspAssumptionLibrary] (@Operation Varchar(4000), @SCENARIONAME Nvarchar(400))
/***************************************************************************
Purpose:	
Inputs:		
Author:		
Created: 	
Copyright:
Change History:04/12/2018
***************************************************************************/
 


AS
BEGIN
	SET NOCOUNT ON 
	SET XACT_ABORT ON
	BEGIN TRY

	IF (@Operation = 'Library')

		BEGIN 
			
			BEGIN TRAN

			DECLARE @ScenarioID INT
			SET @ScenarioID=(SELECT ScenarioID FROM tblScenarioDESC WHERE ScenarioName= @ScenarioName)



			INSERT INTO [dbo].[tblAssumptionLibrary]
			SELECT     [ScenarioID]
					  ,[Country]
					  ,[Genotype]
					  ,[AgeGroup]
					  ,[Product]
					  ,[MetricCategory]
					  ,[MetricName]
					  ,[InputType]
					  ,[Value]
					  ,[ValueDate]
					  ,[RefScenario]
					  ,[RefInstance]
					  ,[CurveID]
					  ,[InsertDate]
					  ,[UserID]
					  ,Getdate()
					  ,0
			FROM [dbo].[tblAssumption] WITH (NOLOCK)
			WHERE ScenarioID=@ScenarioID

			UNION ALL


			SELECT     [ScenarioID]
					  ,[Country]
					  ,[Genotype]
					  ,[AgeGroup]
					  ,[Product]
					  ,[MetricCategory]
					  ,[MetricName]
					  ,[InputType]
					  ,[Value]
					  ,[ValueDate]
					  ,[RefScenario]
					  ,[RefInstance]
					  ,[CurveID]
					  ,[InsertDate]
					  ,[UserID]
					  ,Getdate()
					  ,1
			FROM [dbo].[tblAssumptionIL_Trinity] WITH (NOLOCK)
			WHERE ScenarioID=@ScenarioID



			DELETE FROM [dbo].[tblAssumption] WHERE ScenarioID=@ScenarioID
			DELETE FROM [dbo].[tblAssumptionIL_Trinity] WHERE ScenarioID=@ScenarioID


			DELETE FROM tblScenarioLibrary WHERE ScenarioID=@ScenarioID AND ScenarioName=@ScenarioName

			INSERT INTO tblScenarioLibrary
			SELECT @ScenarioID,@ScenarioName,'tblAssumptionLibrary',Getdate()

			COMMIT TRAN

		END


	
	IF (@Operation = 'Live')

		BEGIN 

			BEGIN TRAN

			DECLARE @ScenarioIDAssp INT
			SET @ScenarioIDAssp=(SELECT ScenarioID FROM tblScenarioDESC WHERE ScenarioName= @ScenarioName)


			INSERT INTO [dbo].[tblAssumption]
			SELECT     [ScenarioID]
					  ,[Country]
					  ,[Genotype]
					  ,[AgeGroup]
					  ,[Product]
					  ,[MetricCategory]
					  ,[MetricName]
					  ,[InputType]
					  ,[Value]
					  ,[ValueDate]
					  ,[RefScenario]
					  ,[RefInstance]
					  ,[CurveID]
					  ,[InsertDate]
					  ,[UserID]
			FROM [dbo].[tblAssumptionLibrary] WITH (NOLOCK)
			WHERE ScenarioID=@ScenarioIDAssp AND [IL]=0



			INSERT INTO [dbo].[tblAssumptionIL_Trinity]
			SELECT     [ScenarioID]
					  ,[Country]
					  ,[Genotype]
					  ,[AgeGroup]
					  ,[Product]
					  ,[MetricCategory]
					  ,[MetricName]
					  ,[InputType]
					  ,[Value]
					  ,[ValueDate]
					  ,[RefScenario]
					  ,[RefInstance]
					  ,[CurveID]
					  ,[InsertDate]
					  ,[UserID]
			FROM [dbo].[tblAssumptionLibrary] WITH (NOLOCK)
			WHERE ScenarioID=@ScenarioIDAssp AND [IL]=1


			DELETE	FROM [dbo].[tblAssumptionLibrary] WHERE ScenarioID=@ScenarioIDAssp

			DELETE FROM tblScenarioLibrary WHERE ScenarioID=@ScenarioIDAssp AND ScenarioName=@ScenarioName

			INSERT INTO tblScenarioLibrary
			SELECT @ScenarioIDAssp,@ScenarioName,'tblAssumption',Getdate()

			COMMIT TRAN

		END

	------------------	
	END TRY

	BEGIN CATCH

		DECLARE   @vchErrorMessage varchar(4000)
				, @intErrorSeverity int
				, @intErrorState int

		SELECT 
			  @vchErrorMessage = ERROR_MESSAGE()
			, @intErrorSeverity = ERROR_SEVERITY()
			, @intErrorState = ERROR_STATE();

				ROLLBACK

		RAISERROR (	 @VchErrorMessage -- Message text.
					, @IntErrorSeverity -- Severity.
					, @IntErrorState -- State.
					);
	END CATCH

END


