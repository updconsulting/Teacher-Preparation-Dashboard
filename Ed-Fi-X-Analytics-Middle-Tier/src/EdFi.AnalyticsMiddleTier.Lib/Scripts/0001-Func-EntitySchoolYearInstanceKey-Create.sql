
CREATE FUNCTION [analytics].[EntitySchoolYearInstanceSetKey]
(
	@EntityId nvarchar(256),
	@SchoolYearTypeId INT
	
)
RETURNS uniqueidentifier
AS
BEGIN

	RETURN CAST(HASHBYTES('MD5', CONVERT(VARCHAR(MAX), REVERSE(CONVERT(BINARY(4), @SchoolYearTypeId))) + CONVERT(VARCHAR(MAX), REVERSE(CONVERT(VARBINARY(256), @EntityId))) + 'N' + 'N') AS UNIQUEIDENTIFIER)

END
GO


