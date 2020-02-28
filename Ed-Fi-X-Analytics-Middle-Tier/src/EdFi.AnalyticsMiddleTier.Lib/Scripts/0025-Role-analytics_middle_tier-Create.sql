IF NOT EXISTS(SELECT 1
FROM sys.database_principals
WHERE [type] = 'R' AND [name] = 'analytics_middle_tier')
BEGIN
	CREATE ROLE [analytics_middle_tier]
END
GO

GRANT SELECT ON SCHEMA::analytics TO [analytics_middle_tier]
