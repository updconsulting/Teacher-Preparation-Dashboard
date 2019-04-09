MERGE INTO [analytics_config].[AuthorizationScope] AS [Target]
USING (VALUES ('Section'), ('School'), ('District')) AS [Source] ([AuthorizationScopeName])
ON [Target].[AuthorizationScopeName] = [Source].[AuthorizationScopeName]
WHEN NOT MATCHED BY TARGET THEN
INSERT ([AuthorizationScopeName]) VALUES ([AuthorizationScopeName])
OUTPUT $action, inserted.*;
GO