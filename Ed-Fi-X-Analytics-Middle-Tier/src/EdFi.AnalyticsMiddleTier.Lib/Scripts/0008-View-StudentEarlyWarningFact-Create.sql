CREATE VIEW [analytics].[StudentEarlyWarningFact]
AS
SELECT [StudentSchoolAssociation].[StudentUSI] AS [StudentKey],
       [StudentSchoolAssociation].[SchoolId] AS [SchoolKey],
       CONVERT(VARCHAR, [CalendarDateCalendarEvent].[Date], 112) AS [DateKey],
       CASE
           WHEN [Descriptor].[CodeValue] IN ( 'Instructional day', 'Make-up day' ) THEN
               1
           ELSE
               0
       END AS [IsInstructionalDay],
       1 AS [IsEnrolled],
       CASE
           WHEN [SchoolAttendance].[InAttendance] > 0 THEN
               1
           ELSE
               0
       END AS [IsPresentSchool],
       CASE
           WHEN [SchoolAttendance].[Excused] > 0 THEN
               1
           ELSE
               0
       END AS [IsAbsentFromSchoolExcused],
       CASE
           WHEN [SchoolAttendance].[Unexcused] > 0 THEN
               1
           ELSE
               0
       END AS [IsAbsentFromSchoolUnexcused],
       CASE
           WHEN [SchoolAttendance].[Tardy] > 0 THEN
               1
           ELSE
               0
       END AS [IsTardyToSchool],
       CASE
           WHEN [HomeRoomAttendance].[InAttendance] > 0 THEN
               1
           ELSE
               0
       END AS [IsPresentHomeroom],
       CASE
           WHEN [HomeRoomAttendance].[Excused] > 0 THEN
               1
           ELSE
               0
       END AS [IsAbsentFromHomeroomExcused],
       CASE
           WHEN [HomeRoomAttendance].[Unexcused] > 0 THEN
               1
           ELSE
               0
       END AS [IsAbsentFromHomeroomUnexcused],
       CASE
           WHEN [HomeRoomAttendance].[Tardy] > 0 THEN
               1
           ELSE
               0
       END AS [IsTardyToHomeroom],
       CASE
           WHEN [HomeRoomAttendance].[InAttendance] > 0 THEN
               1
           ELSE
               0
       END AS [IsPresentAnyClass],
       CASE
           WHEN [AnyClassAttendance].[Excused] > 0 THEN
               1
           ELSE
               0
       END AS [IsAbsentFromAnyClassExcused],
       CASE
           WHEN [AnyClassAttendance].[Unexcused] > 0 THEN
               1
           ELSE
               0
       END AS [IsAbsentFromAnyClassUnexcused],
       CASE
           WHEN [AnyClassAttendance].[Tardy] > 0 THEN
               1
           ELSE
               0
       END AS [IsTardyToAnyClass],
       ISNULL([BehaviorIncidents].[CountByDayOfStateOffenses], 0) AS [CountByDayOfStateOffenses],
       ISNULL([BehaviorIncidents].[CountByDayOfConductOffenses], 0) AS [CountByDayOfConductOffenses]
FROM [edfi].[StudentSchoolAssociation]
    INNER JOIN [edfi].[CalendarDateCalendarEvent]
        ON [CalendarDateCalendarEvent].[SchoolId] = [StudentSchoolAssociation].[SchoolId]
           AND [StudentSchoolAssociation].[EntryDate] <= [CalendarDateCalendarEvent].[Date]
           AND
           (
               [StudentSchoolAssociation].[ExitWithdrawDate] IS NULL
               OR [StudentSchoolAssociation].[ExitWithdrawDate] >= [CalendarDateCalendarEvent].[Date]
           )
    INNER JOIN [edfi].[Descriptor]
        ON [CalendarDateCalendarEvent].[CalendarEventDescriptorId] = [Descriptor].[DescriptorId]
    OUTER APPLY
(
    SELECT SUM(   CASE
                      WHEN [SchoolAttendanceDescriptor].[CodeValue] = 'Excused Absence' THEN
                          1
                      ELSE
                          0
                  END
              ) AS Excused,
           SUM(   CASE
                      WHEN [SchoolAttendanceDescriptor].[CodeValue] = 'Unexcused Absence' THEN
                          1
                      ELSE
                          0
                  END
              ) AS Unexcused,
           SUM(   CASE
                      WHEN [SchoolAttendanceDescriptor].[CodeValue] = 'Tardy' THEN
                          1
                      ELSE
                          0
                  END
              ) AS Tardy,
           SUM(   CASE
                      WHEN [SchoolAttendanceDescriptor].[CodeValue] NOT IN ( 'Excused Absence', 'Unexcused Absence',
                                                                             'Tardy'
                                                                           ) THEN
                          1
                      ELSE
                          0
                  END
              ) AS [InAttendance]
    FROM [edfi].[StudentSchoolAttendanceEvent]
        LEFT OUTER JOIN [edfi].[Descriptor] AS [SchoolAttendanceDescriptor]
            ON [StudentSchoolAttendanceEvent].[AttendanceEventCategoryDescriptorId] = [SchoolAttendanceDescriptor].[DescriptorId]
    WHERE [StudentSchoolAssociation].[StudentUSI] = [StudentSchoolAttendanceEvent].[StudentUSI]
          AND [StudentSchoolAssociation].[SchoolId] = [StudentSchoolAttendanceEvent].[SchoolId]
          -- [StudentSchoolAssociation].[SchoolYear] is nullable in this table
          AND
          (
              [StudentSchoolAssociation].[SchoolYear] IS NULL
              OR [StudentSchoolAssociation].[SchoolYear] = [StudentSchoolAttendanceEvent].[SchoolYear]
          )
          AND [CalendarDateCalendarEvent].[Date] = [StudentSchoolAttendanceEvent].[EventDate]
) AS [SchoolAttendance]

    -- Home room attendance
    OUTER APPLY
(
    SELECT SUM(   CASE
                      WHEN [CodeValue] = 'Excused Absence' THEN
                          1
                      ELSE
                          0
                  END
              ) AS Excused,
           SUM(   CASE
                      WHEN [CodeValue] = 'Unexcused Absence' THEN
                          1
                      ELSE
                          0
                  END
              ) AS Unexcused,
           SUM(   CASE
                      WHEN [CodeValue] = 'Tardy' THEN
                          1
                      ELSE
                          0
                  END
              ) AS Tardy,
           SUM(   CASE
                      WHEN [CodeValue] NOT IN ( 'Excused Absence', 'Unexcused Absence', 'Tardy' ) THEN
                          1
                      ELSE
                          0
                  END
              ) AS [InAttendance]
    FROM [edfi].[StudentSectionAttendanceEvent]
        INNER JOIN [edfi].[Descriptor]
            ON [StudentSectionAttendanceEvent].[AttendanceEventCategoryDescriptorId] = [Descriptor].[DescriptorId]
        INNER JOIN [edfi].[StudentSectionAssociation]
            ON [StudentSectionAttendanceEvent].[StudentUSI] = [StudentSectionAssociation].[StudentUSI]
               AND [StudentSectionAttendanceEvent].[SchoolId] = [StudentSectionAssociation].[SchoolId]
               AND [StudentSectionAttendanceEvent].[SectionIdentifier] = [StudentSectionAssociation].[SectionIdentifier]
               AND [StudentSectionAttendanceEvent].[LocalCourseCode] = [StudentSectionAssociation].[LocalCourseCode]
               AND [StudentSectionAttendanceEvent].[SessionName] = [StudentSectionAssociation].[SessionName]
               AND [StudentSectionAttendanceEvent].[SchoolYear] = [StudentSectionAssociation].[SchoolYear]
    WHERE [StudentSectionAssociation].[HomeroomIndicator] = 1
          AND [Descriptor].[CodeValue] IN ( 'Excused Absence', 'Unexcused Absence', 'Tardy' )
          AND [CalendarDateCalendarEvent].[Date] = [StudentSectionAttendanceEvent].[EventDate]
          AND [StudentSchoolAssociation].[StudentUSI] = [StudentSectionAttendanceEvent].[StudentUSI]
          AND [StudentSchoolAssociation].[SchoolId] = [StudentSectionAttendanceEvent].[SchoolId]
          -- [StudentSchoolAssociation].[SchoolYear] is nullable
          AND
          (
              [StudentSchoolAssociation].[SchoolYear] IS NULL
              OR [StudentSchoolAssociation].[SchoolYear] = [StudentSectionAttendanceEvent].[SchoolYear]
          )
) AS [HomeRoomAttendance]

    -- All classes attendance
    OUTER APPLY
(
    SELECT SUM(   CASE
                      WHEN [CodeValue] = 'Excused Absence' THEN
                          1
                      ELSE
                          0
                  END
              ) AS Excused,
           SUM(   CASE
                      WHEN [CodeValue] = 'Unexcused Absence' THEN
                          1
                      ELSE
                          0
                  END
              ) AS Unexcused,
           SUM(   CASE
                      WHEN [CodeValue] = 'Tardy' THEN
                          1
                      ELSE
                          0
                  END
              ) AS Tardy,
           SUM(   CASE
                      WHEN [CodeValue] NOT IN ( 'Excused Absence', 'Unexcused Absence', 'Tardy' ) THEN
                          1
                      ELSE
                          0
                  END
              ) AS [InAttendance]
    FROM [edfi].[StudentSectionAttendanceEvent]
        INNER JOIN [edfi].[Descriptor]
            ON [StudentSectionAttendanceEvent].[AttendanceEventCategoryDescriptorId] = [Descriptor].[DescriptorId]
        INNER JOIN [edfi].[StudentSectionAssociation]
            ON [StudentSectionAttendanceEvent].[StudentUSI] = [StudentSectionAssociation].[StudentUSI]
               AND [StudentSectionAttendanceEvent].[SchoolId] = [StudentSectionAssociation].[SchoolId]
               AND [StudentSectionAttendanceEvent].[SectionIdentifier] = [StudentSectionAssociation].[SectionIdentifier]
               AND [StudentSectionAttendanceEvent].[LocalCourseCode] = [StudentSectionAssociation].[LocalCourseCode]
               AND [StudentSectionAttendanceEvent].[SessionName] = [StudentSectionAssociation].[SessionName]
               AND [StudentSectionAttendanceEvent].[SchoolYear] = [StudentSectionAssociation].[SchoolYear]
    WHERE [Descriptor].[CodeValue] IN ( 'Excused Absence', 'Unexcused Absence', 'Tardy' )
          AND [CalendarDateCalendarEvent].[Date] = [StudentSectionAttendanceEvent].[EventDate]
          AND [StudentSchoolAssociation].[StudentUSI] = [StudentSectionAttendanceEvent].[StudentUSI]
          AND [StudentSchoolAssociation].[SchoolId] = [StudentSectionAttendanceEvent].[SchoolId]
          -- [StudentSchoolAssociation].[SchoolYear] is nullable
          AND
          (
              [StudentSchoolAssociation].[SchoolYear] IS NULL
              OR [StudentSchoolAssociation].[SchoolYear] = [StudentSectionAttendanceEvent].[SchoolYear]
          )
) AS [AnyClassAttendance]

    -- Offenses
    OUTER APPLY
(
    SELECT SUM(   CASE
                      WHEN [Descriptor].[ShortDescription] = 'State Offense' THEN
                          1
                      ELSE
                          0
                  END
              ) AS CountByDayOfStateOffenses,
           SUM(   CASE
                      WHEN [Descriptor].[ShortDescription] = 'School Code of Conduct' THEN
                          1
                      ELSE
                          0
                  END
              ) AS CountByDayOfConductOffenses
    FROM [edfi].[StudentDisciplineIncidentAssociation]
        INNER JOIN [edfi].[DisciplineIncidentBehavior]
            ON [DisciplineIncidentBehavior].[IncidentIdentifier] = [StudentDisciplineIncidentAssociation].[IncidentIdentifier]
               AND [DisciplineIncidentBehavior].[SchoolId] = [StudentDisciplineIncidentAssociation].[SchoolId]
        INNER JOIN [edfi].[Descriptor]
            ON [DisciplineIncidentBehavior].[BehaviorDescriptorId] = [Descriptor].[DescriptorId]
        INNER JOIN [edfi].[DisciplineIncident]
            ON [DisciplineIncidentBehavior].[IncidentIdentifier] = [DisciplineIncident].[IncidentIdentifier]
               AND [DisciplineIncidentBehavior].[SchoolId] = [DisciplineIncident].[SchoolId]
    WHERE [StudentSchoolAssociation].[StudentUSI] = [StudentDisciplineIncidentAssociation].[StudentUSI]
          AND [StudentSchoolAssociation].[SchoolId] = [StudentDisciplineIncidentAssociation].[SchoolId]
          AND [CalendarDateCalendarEvent].[Date] = [DisciplineIncident].[IncidentDate]
) AS [BehaviorIncidents];
GO

