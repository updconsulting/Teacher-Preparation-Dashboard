CREATE PROC [analytics_config].[MultipleYearSnapShots] (
	@ViewName SYSNAME
) AS
BEGIN

  DECLARE @Stmt NVARCHAR(MAX) =
		N'SET NOCOUNT ON; 
		  SELECT *
		  FROM ' + @ViewName

  IF EXISTS (SELECT
        *
      FROM analytics_config.SchoolYearHistoricalSnapShotDates)
  BEGIN

    DECLARE TableCursor CURSOR FAST_FORWARD FOR SELECT
      SchoolYear
     ,SnapShotDate

    FROM analytics_config.SchoolYearHistoricalSnapShotDates


    DECLARE @SchoolYear INT
           ,@SnapShotDate DATETIME
    OPEN TableCursor

    FETCH NEXT FROM TableCursor INTO @SchoolYear, @SnapShotDate

    WHILE @@FETCH_STATUS = 0
    BEGIN

    SET @Stmt = @Stmt + N'
		UNION
		SELECT *
		FROM ' + @ViewName + '
		FOR SYSTEM_TIME AS OF ''' + CAST(@SnapShotDate AS NVARCHAR(MAX)) + ''''

    FETCH NEXT FROM TableCursor INTO @SchoolYear, @SnapShotDate
    END

    CLOSE TableCursor
    DEALLOCATE TableCursor

  END
 -- PRINT @Stmt
  EXEC (@Stmt)
  RETURN 1 
END
GO


