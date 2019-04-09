CREATE VIEW [analytics].[StudentProgramEvent]
AS
SELECT [StudentProgramAssociation].[StudentUSI] AS [StudentKey],
       [StudentProgramAssociation].[EducationOrganizationId] AS [LocalEducationAgencyKey],
       CONVERT(VARCHAR, [StudentProgramAssociation].[BeginDate], 112) AS [DateKey],
       [ProgramTypeDescriptorId] AS [ProgramTypeKey],
       'Enter' AS [ProgramEventType]
FROM [edfi].[StudentProgramAssociation];

GO


		