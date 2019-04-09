﻿IF NOT EXISTS
(
    SELECT 1
    FROM [INFORMATION_SCHEMA].[SCHEMATA]
    WHERE SCHEMA_NAME = 'analytics'
)
BEGIN
    EXEC sp_executesql N'CREATE SCHEMA [analytics]';
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [INFORMATION_SCHEMA].[SCHEMATA]
    WHERE SCHEMA_NAME = 'analytics_config'
)
BEGIN
    EXEC sp_executesql N'CREATE SCHEMA [analytics_config]';
END;