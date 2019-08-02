/****** Object:  View [analytics].[ApplicantFacts]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [analytics].[ApplicantFacts]
AS
SELECT [analytics].[EntitySchoolYearInstanceSetKey](p.ApplicantIdentifier, p.SchoolYear) AS ApplicantSchoolyearInstanceKey,
       ApplicantIdentifier AS Applicantkey,
       p.SchoolYear,
       [College Board examination scores],
       [ACT score],
       [Letter grade/mark]
FROM
(
    SELECT asr.ApplicantIdentifier,
           s.SchoolYear,
           asr.EducationOrganizationId,
           asr.Result,
           d.CodeValue AS AssessmentTitle
    FROM tpdm.ApplicantScoreResult asr
        INNER JOIN tpdm.Application ap
            ON ap.ApplicantIdentifier = asr.ApplicantIdentifier
               AND ap.EducationOrganizationId = asr.EducationOrganizationId
        INNER JOIN edfi.AssessmentReportingMethodDescriptor armd
            ON asr.AssessmentReportingMethodDescriptorId = armd.AssessmentReportingMethodDescriptorId
        INNER JOIN edfi.Descriptor d
            ON armd.AssessmentReportingMethodDescriptorId = d.DescriptorId
        INNER JOIN edfi.Session s
            ON ap.ApplicationDate
               BETWEEN s.BeginDate AND s.EndDate
        INNER JOIN edfi.SchoolYearType syt
            ON syt.SchoolYear = s.SchoolYear
               AND syt.CurrentSchoolYear = 1
) t
PIVOT
(
    MAX(Result)
    FOR AssessmentTitle IN ([College Board examination scores], [ACT score], [Letter grade/mark])
) p;
GO

GO
