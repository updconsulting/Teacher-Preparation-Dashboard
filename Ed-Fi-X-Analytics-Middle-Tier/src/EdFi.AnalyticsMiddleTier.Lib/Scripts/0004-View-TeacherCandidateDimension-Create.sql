CREATE     VIEW analytics.TeacherCandidateDimension
AS
    WITH
        TeacherCandidateRaces
        AS
        (
            SELECT tc.TeacherCandidateIdentifier,
                COUNT(DISTINCT tcr.RaceDescriptorId) AS RaceCount,
                MAX(tcr.RaceDescriptorId) AS RaceDescriptorId
            FROM tpdm.TeacherCandidate tc
                INNER JOIN tpdm.TeacherCandidateRace tcr
                ON tc.TeacherCandidateIdentifier = tcr.TeacherCandidateIdentifier
            GROUP BY tc.TeacherCandidateIdentifier
        )
    SELECT [analytics].[EntitySchoolYearInstanceSetKey](tc.TeacherCandidateIdentifier, tctppa.SchoolYear) TeacherCandidateSchoolYearInstanceKey,
        tc.TeacherCandidateIdentifier TeacherCandidateKey,
        [tc].[StudentUSI] AS [StudentKey],
        [tctppa].TeacherPreparationProviderId AS [TeacherPreparationProviderKey],
        tctppa.SchoolYear,
        tc.[FirstName] AS [TeacherCandidateFirstName],
        ISNULL(tc.[MiddleName], '') AS [TeacherCandidateMiddleName],
        ISNULL(tc.[LastSurname], '') AS [TeacherCandidateLastName],
        [tctppa].[EntryDate] AS [EnrollmentDate],
        d1.[CodeValue] AS [Sex],
        CASE
           WHEN TeacherCandidateRaces.RaceCount > 1 THEN
               'Two or more'
           ELSE
               d3.CodeValue
       END AS RaceDescriptor,
        [PrimaryContact].[TeacherCandidateName],
        [PrimaryContact].[TeacherCandidateAddress],
        [PrimaryContact].[TeacherCandidateMobilePhoneNumber],
        [PrimaryContact].[TeacherCandidateWorkPhoneNumber],
        [PrimaryContact].[ContactEmailAddress],
        d.CodeValue AS TPPDegreeType,
        d2.[CodeValue] AS [GradeLevel],
        stuff( (SELECT ','+ tcsd.MajorSpecialization
        FROM tpdm.TeacherCandidateDegreeSpecialization tcsd
        WHERE tc.TeacherCandidateIdentifier= tcsd.TeacherCandidateIdentifier
        ORDER BY tcsd.MajorSpecialization
        FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
            ,1,1,'') as  MajorSpecialization,
        stuff( (SELECT ','+ tcsd.MinorSpecialization
        FROM tpdm.TeacherCandidateDegreeSpecialization tcsd
        WHERE tc.TeacherCandidateIdentifier= tcsd.TeacherCandidateIdentifier
        ORDER BY tcsd.MajorSpecialization
        FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
            ,1,1,'') MinorSpecialization,
        tc.ProgramComplete AS ProgramComplete,
        tccy.SchoolYear AS CohortYear,
        tc.EconomicDisadvantaged,
        tc.FirstGenerationStudent,
        (
           SELECT MAX([LastModifiedDate])
        FROM
            (
               VALUES
                ([tc].[LastModifiedDate])
           ) AS value ([LastModifiedDate])
       ) AS [LastModifiedDate]
    FROM tpdm.TeacherCandidate tc
        LEFT JOIN tpdm.TeacherCandidateCohortYear tccy
        ON tc.TeacherCandidateIdentifier = tccy.TeacherCandidateIdentifier
        INNER JOIN tpdm.TeacherCandidateTPPProgramDegree tctd
        ON tc.TeacherCandidateIdentifier = tctd.TeacherCandidateIdentifier
        INNER JOIN edfi.GradeLevelDescriptor gld
        ON tctd.GradeLevelDescriptorId = gld.GradeLevelDescriptorId
        INNER JOIN edfi.Descriptor d2
        ON gld.GradeLevelDescriptorId = d2.DescriptorId

        INNER JOIN tpdm.TPPDegreeTypeDescriptor ttd
        ON tctd.TPPDegreeTypeDescriptorId = ttd.TPPDegreeTypeDescriptorId
        INNER JOIN edfi.Descriptor d
        ON ttd.TPPDegreeTypeDescriptorId = d.DescriptorId
        LEFT JOIN edfi.Descriptor d1
        ON tc.BirthSexDescriptorId = d1.DescriptorId
        INNER JOIN tpdm.TeacherCandidateTeacherPreparationProviderAssociation tctppa
        ON tc.TeacherCandidateIdentifier = tctppa.TeacherCandidateIdentifier
        INNER JOIN tpdm.TeacherPreparationProvider tpp
        ON tctppa.TeacherPreparationProviderId = tpp.TeacherPreparationProviderId
        INNER JOIN edfi.EducationOrganization eo
        ON tpp.TeacherPreparationProviderId = eo.EducationOrganizationId
        LEFT JOIN TeacherCandidateRaces
        ON tc.TeacherCandidateIdentifier = TeacherCandidateRaces.TeacherCandidateIdentifier
        LEFT JOIN edfi.Descriptor d3
        ON d3.DescriptorId = TeacherCandidateRaces.RaceDescriptorId
    OUTER APPLY
(
    -- It is possible for more than one person to be marked as primary contact, therefore 
    -- we have to carefully restrict to just one record.
    SELECT TOP 1
            [FirstName] + ' ' + [LastName] AS [TeacherCandidateName],
            COALESCE(
                       NULLIF([HomeAddress], ''),
                       NULLIF([PhysicalAddress], ''),
                       NULLIF([MailingAddress], ''),
                       NULLIF([WorkAddress], ''),
                       NULLIF([TemporaryAddress], '')
                   ) AS [TeacherCandidateAddress],
            [WorkPhoneNumber] AS [TeacherCandidateWorkPhoneNumber],
            [MobilePhoneNumber] AS [TeacherCandidateMobilePhoneNumber],
            CASE
               WHEN [PrimaryEmailAddress] = 'Work' THEN
                   [WorkEmailAddress]
               ELSE
                   [PersonalEmailAddress]
           END AS [ContactEmailAddress]
        FROM [analytics].[TeacherCandidateContactDimension] tccd
        WHERE tc.TeacherCandidateIdentifier = tccd.TeacherCandidateKey
) AS [PrimaryContact]
    WHERE tctppa.[ExitWithdrawDate] IS NULL;
GO


