CREATE PROC [analytics_config].[InsertStaffClassificationDescriptorScope] (
	@StaffDescriptor NVARCHAR(50) = NULL,
	@StaffDescriptorId INT = NULL,
	@Scope VARCHAR(50) = NULL,
	@ScopeID INT = NULL
) AS
BEGIN 

	SET NOCOUNT ON

	--
	-- Missing argument error handling
	--
	DECLARE @StaffDescriptorIsSet BIT, @ScopeIsSet BIT
	SELECT @StaffDescriptorIsSet = CASE WHEN @StaffDescriptor IS NULL AND @StaffDescriptorId IS NULL THEN 0 ELSE 1 END
	SELECT @ScopeIsSet = CASE WHEN @Scope IS NULL AND @ScopeID IS NULL THEN 0 ELSE 1 END

	IF (@StaffDescriptorIsSet = 0)
	BEGIN;
		THROW 51000, 'Must pass in a value for either @StaffDescriptor or @StaffDescriptorId', 1
	END

	IF (@ScopeIsSet = 0)
	BEGIN;
		THROW 51001, 'Must pass in a value for either @Scope or @ScopeID', 1
	END

	--
	-- Invalid argument error handling
	--
	IF NOT EXISTS(
		SELECT 1 
		FROM 
			[edfi].[StaffClassificationDescriptor]
		INNER JOIN
			[edfi].[Descriptor] ON 
				[StaffClassificationDescriptor].[StaffClassificationDescriptorId] = [Descriptor].[DescriptorId]
		WHERE
			[Descriptor].[CodeValue] = @StaffDescriptor
		OR	[Descriptor].[DescriptorId] = @StaffDescriptorId
	)
	BEGIN

		DECLARE @descriptors as NVARCHAR(MAX) = 'Invalid staff classification descriptor. Valid values are (Id, Value):'
 
		SELECT 
			@descriptors = @descriptors 
				+ CHAR(10) 
				+ CAST([Descriptor].[DescriptorId]  as NVARCHAR)
				+ ', ' + [Descriptor].[CodeValue]
		FROM 
			[edfi].[StaffClassificationDescriptor]
		INNER JOIN
			[edfi].[Descriptor] ON 
				[StaffClassificationDescriptor].[StaffClassificationDescriptorId] = [Descriptor].[DescriptorId];
			 
		THROW 51002, @descriptors, 1
	END


	IF NOT EXISTS(
		SELECT 1 
		FROM 
			[analytics_config].[AuthorizationScope]
		WHERE
			[AuthorizationScopeName] = @Scope
		OR	[AuthorizationScopeId] = @ScopeId
	)
	BEGIN

		DECLARE @scopes as NVARCHAR(MAX) = 'Invalid authorization scope. Valid values are (Id, Value):'
 
		SELECT 
			@scopes = @scopes 
				+ CHAR(10) 
				+ CAST([AuthorizationScopeId]  as NVARCHAR)
				+ ', ' + [AuthorizationScopeName]
		FROM 
			[analytics_config].[AuthorizationScope];
			 
		THROW 51003, @scopes, 1
	END


	--
	-- Set ID variables if input parameters were provided instead of IDs
	--
	IF (@ScopeID IS NULL)
	BEGIN
		SELECT 
			@ScopeID = [AuthorizationScopeId] 
		FROM 
			[analytics_config].[AuthorizationScope] 
		WHERE
			[AuthorizationScopeName] = @Scope
	END

	IF (@StaffDescriptorId IS NULL)
	BEGIN
		SELECT
			@StaffDescriptorId = [DescriptorId]
		FROM 
			[edfi].[StaffClassificationDescriptor]
		INNER JOIN
			[edfi].[Descriptor] ON 
				[StaffClassificationDescriptor].[StaffClassificationDescriptorId] = [Descriptor].[DescriptorId]
		WHERE
			[CodeValue] = @StaffDescriptor
	END

	--
	-- Merge the new values into the destination table, so we don't risk getting duplicates.
	-- Restore row count so the user will get feedback.
	--

	SET NOCOUNT OFF

	MERGE INTO [analytics_config].[StaffClassificationDescriptorScope] AS [Target]
	USING (
		VALUES ( @ScopeID, @StaffDescriptorId)
	) AS [Source] ([AuthorizationScopeId], [DescriptorId])
	ON 
			[Target].[AuthorizationScopeId] = [Source].[AuthorizationScopeId]
		AND	[Target].[StaffClassificationDescriptorId] = [Source].[DescriptorId]
	WHEN NOT MATCHED BY TARGET THEN
	INSERT ([AuthorizationScopeId], [StaffClassificationDescriptorId]) VALUES ([AuthorizationScopeId], [DescriptorId]);


END