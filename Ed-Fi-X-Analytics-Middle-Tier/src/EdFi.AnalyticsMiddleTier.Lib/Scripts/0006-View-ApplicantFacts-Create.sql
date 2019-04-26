/****** Object:  View [analytics].[ApplicantFacts]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [analytics].[ApplicantFacts]
AS

SELECT
  ApplicantIdentifier AS Applicantkey,
  [College Board examination scores],
  [ACT score],
  [Letter grade/mark]
FROM (SELECT
  asr.ApplicantIdentifier,
  asr.EducationOrganizationId,
  asr.Result,
  d.CodeValue AS AssessmentTitle
FROM tpdm.ApplicantScoreResult asr
INNER JOIN edfi.AssessmentReportingMethodDescriptor armd
  ON asr.AssessmentReportingMethodDescriptorId = armd.AssessmentReportingMethodDescriptorId
INNER JOIN edfi.Descriptor d
  ON armd.AssessmentReportingMethodDescriptorId = d.DescriptorId) t
PIVOT (
MAX(Result)
FOR AssessmentTitle IN ([College Board examination scores], [ACT score], [Letter grade/mark])
) p
GO
