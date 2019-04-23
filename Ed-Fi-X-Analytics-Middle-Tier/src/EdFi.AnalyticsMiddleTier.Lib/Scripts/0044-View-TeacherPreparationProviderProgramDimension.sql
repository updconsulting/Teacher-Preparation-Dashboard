/****** Object:  View [analytics].[TeacherPreparationProviderProgramDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [analytics].[TeacherPreparationProviderProgramDimension] AS 
SELECT
  tppp.ProgramId AS ProgramKey,
  tppp.EducationOrganizationId AS [TeacherCandidatePreparationProviderKey],
  tppp.ProgramName AS ProgramName,
  d.CodeValue AS ProgramType
FROM tpdm.TeacherPreparationProviderProgram tppp
INNER JOIN tpdm.TeacherPreparationProgramTypeDescriptor tpptd
  ON tppp.TeacherPreparationProgramTypeDescriptorId = tpptd.TeacherPreparationProgramTypeDescriptorId
INNER JOIN edfi.Descriptor d
  ON d.DescriptorId = tpptd.TeacherPreparationProgramTypeDescriptorId
GO
