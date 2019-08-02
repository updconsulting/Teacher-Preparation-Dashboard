/****** Object:  View [analytics].[TeacherCandidateGatewayCorurseCompleted]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--Definition of denomiDefinition of denominator -
--Gateway 1: enrollees that have completed course code ‘EDCI3334’ with a grade equal to or greater than a 'B', but not course codes ‘EDTC3310’, ‘ECEC4311’, ‘EDUL6391’, ‘UTCH1101’, ‘EDUC4611’ or ‘UNIV1301’
--Gateway 2: enrollees that have completed course codes ‘EDCI3334’, ‘EDTC3310’, and ‘ECEC4311’ with a grade equal to or greater than a 'B', but not course codes ‘EDUL6391’, ‘UTCH1101’, ‘EDUC4611’ or ‘UNIV1301’
--Gateway 3: enrollees that have completed course codes ‘EDCI3334’, ‘EDTC3310’, ‘ECEC4311’, ‘EDUL6391’, and ‘UTCH1101’, with a grade equal to or greater than a 'B', but not course codes ‘EDUC4611’ or ‘UNIV1301’
--Gateway 4: enrollees that have completed course codes ‘EDCI3334’, ‘EDTC3310’, ‘ECEC4311’, ‘EDUL6391’, ‘UTCH1101’, ‘EDUC4611’ and ‘UNIV1301’ with a grade equal to or greater than a 'B'
--

CREATE   VIEW [analytics].[TeacherCandidateGatewayCorurseCompleted]
AS
/** Gate way one **/
WITH GateWayCoursesTaken
AS (
   SELECT TeacherCandidateIdentifier,
          [EDCI3334],
          [EDTC3310],
          [ECEC4311],
          [EDUL6391],
          [UTCH1101],
          [EDUC4611],
          [UNIV1301]
   FROM
   (
       SELECT DISTINCT
              tcct.TeacherCandidateIdentifier,
              tcct.CourseCode,
              CASE
                  WHEN tcct.FinalLetterGradeEarned IN ( 'A', 'B' ) THEN
                      1
                  ELSE
                      0
              END AS Completed
       FROM tpdm.TeacherCandidateCourseTranscript tcct
       WHERE tcct.CourseCode IN ( 'EDCI3334' )
             AND tcct.SchoolYear <=
             (
                 SELECT SchoolYear FROM edfi.SchoolYearType WHERE CurrentSchoolYear = 1
             )
       UNION ALL
       SELECT DISTINCT
              tcct.TeacherCandidateIdentifier,
              tcct.CourseCode,
              CASE
                  WHEN tcct.FinalLetterGradeEarned IN ( 'A', 'B' ) THEN
                      1
                  ELSE
                      0
              END AS Completed
       FROM tpdm.TeacherCandidateCourseTranscript tcct
       WHERE tcct.CourseCode IN ( 'EDTC3310' )
             AND tcct.SchoolYear <=
             (
                 SELECT SchoolYear FROM edfi.SchoolYearType WHERE CurrentSchoolYear = 1
             )
       UNION ALL
       SELECT DISTINCT
              tcct.TeacherCandidateIdentifier,
              tcct.CourseCode,
              CASE
                  WHEN tcct.FinalLetterGradeEarned IN ( 'A', 'B' ) THEN
                      1
                  ELSE
                      0
              END AS Completed
       FROM tpdm.TeacherCandidateCourseTranscript tcct
       WHERE tcct.CourseCode IN ( 'ECEC4311' )
             AND tcct.SchoolYear <=
             (
                 SELECT SchoolYear FROM edfi.SchoolYearType WHERE CurrentSchoolYear = 1
             )
       UNION ALL
       SELECT DISTINCT
              tcct.TeacherCandidateIdentifier,
              tcct.CourseCode,
              CASE
                  WHEN tcct.FinalLetterGradeEarned IN ( 'A', 'B' ) THEN
                      1
                  ELSE
                      0
              END AS Completed
       FROM tpdm.TeacherCandidateCourseTranscript tcct
       WHERE tcct.CourseCode IN ( 'EDUL6391' )
             AND tcct.SchoolYear <=
             (
                 SELECT SchoolYear FROM edfi.SchoolYearType WHERE CurrentSchoolYear = 1
             )
       UNION ALL
       SELECT DISTINCT
              tcct.TeacherCandidateIdentifier,
              tcct.CourseCode,
              CASE
                  WHEN tcct.FinalLetterGradeEarned IN ( 'A', 'B' ) THEN
                      1
                  ELSE
                      0
              END AS Completed
       FROM tpdm.TeacherCandidateCourseTranscript tcct
       WHERE tcct.CourseCode IN ( 'UTCH1101' )
             AND tcct.SchoolYear <=
             (
                 SELECT SchoolYear FROM edfi.SchoolYearType WHERE CurrentSchoolYear = 1
             )
       UNION ALL
       SELECT tcct.TeacherCandidateIdentifier,
              tcct.CourseCode,
              CASE
                  WHEN tcct.FinalLetterGradeEarned IN ( 'A', 'B' ) THEN
                      1
                  ELSE
                      0
              END AS Completed
       FROM tpdm.TeacherCandidateCourseTranscript tcct
       WHERE tcct.CourseCode IN ( 'EDUC4611' )
             AND tcct.SchoolYear <=
             (
                 SELECT SchoolYear FROM edfi.SchoolYearType WHERE CurrentSchoolYear = 1
             )
       UNION ALL
       SELECT tcct.TeacherCandidateIdentifier,
              tcct.CourseCode,
              CASE
                  WHEN tcct.FinalLetterGradeEarned IN ( 'A', 'B' ) THEN
                      1
                  ELSE
                      0
              END AS Completed
       FROM tpdm.TeacherCandidateCourseTranscript tcct
       WHERE tcct.CourseCode IN ( 'UNIV1301' )
             AND tcct.SchoolYear <=
             (
                 SELECT SchoolYear FROM edfi.SchoolYearType WHERE CurrentSchoolYear = 1
             )
   ) t
   PIVOT
   (
       MAX(t.Completed)
       FOR CourseCode IN ([EDCI3334], [EDTC3310], [ECEC4311], [EDUL6391], [UTCH1101], [EDUC4611], [UNIV1301])
   --‘EDCI3334’, ‘EDTC3310’, ‘ECEC4311’, ‘EDUL6391’, ‘UTCH1101’, ‘EDUC4611’ and ‘UNIV1301’
   ) p),
     TakenCompleted
AS (SELECT TeacherCandidateIdentifier,
           CASE
               WHEN EDCI3334 = 1 THEN
                   'Completed'
               WHEN EDCI3334 = 0 THEN
                   'Not Completed'
               ELSE
                   'Not Taken'
           END AS EDCI3334,
           CASE
               WHEN EDTC3310 = 1 THEN
                   'Completed'
               WHEN EDTC3310 = 0 THEN
                   'Not Completed'
               ELSE
                   'Not Taken'
           END AS EDTC3310,
           CASE
               WHEN ECEC4311 = 1 THEN
                   'Completed'
               WHEN ECEC4311 = 0 THEN
                   'Not Completed'
               ELSE
                   'Not Taken'
           END AS ECEC4311,
           CASE
               WHEN EDUL6391 = 1 THEN
                   'Completed'
               WHEN EDUL6391 = 0 THEN
                   'Not Completed'
               ELSE
                   'Not Taken'
           END AS EDUL6391,
           CASE
               WHEN UTCH1101 = 1 THEN
                   'Completed'
               WHEN UTCH1101 = 0 THEN
                   'Not Completed'
               ELSE
                   'Not Taken'
           END AS UTCH1101,
           CASE
               WHEN EDUC4611 = 1 THEN
                   'Completed'
               WHEN EDUC4611 = 0 THEN
                   'Not Completed'
               ELSE
                   'Not Taken'
           END AS EDUC4611,
           CASE
               WHEN UNIV1301 = 1 THEN
                   'Completed'
               WHEN UNIV1301 = 0 THEN
                   'Not Completed'
               ELSE
                   'Not Taken'
           END AS UNIV1301
    FROM GateWayCoursesTaken)
SELECT [analytics].[EntitySchoolYearInstanceSetKey](   p.TeacherCandidateKey,
       (
           SELECT SchoolYear FROM edfi.SchoolYearType WHERE CurrentSchoolYear = 1
       )
                                                   ) TeacherCandidateSchoolYearInstnceKey,
       TeacherCandidateKey,
       SchoolYear =
       (
           SELECT SchoolYear FROM edfi.SchoolYearType WHERE CurrentSchoolYear = 1
       ),
       CASE
           WHEN GateWayOne IS NULL THEN
               GateWayOne
           ELSE
               CAST(GateWayOne AS BIT)
       END AS GateWayOneCourseComplete,
       CASE
           WHEN GateWayTwo IS NULL THEN
               GateWayTwo
           ELSE
               CAST(GateWayTwo AS BIT)
       END AS GateWayTwoCourseComplete,
       CASE
           WHEN GateWayThree IS NULL THEN
               GateWayThree
           ELSE
               CAST(GateWayThree AS BIT)
       END AS GateWayThreeCourseComplete,
       CASE
           WHEN GateWayFour IS NULL THEN
               GateWayFour
           ELSE
               CAST(GateWayFour AS BIT)
       END AS GateWayFourCourseComplete
FROM
(
    SELECT TeacherCandidateIdentifier AS TeacherCandidateKey, --‘EDCI3334’ 
           CASE
               WHEN EDCI3334 = 'Completed' THEN
                   1
               WHEN EDCI3334 = 'Not Completed' THEN
                   0
               ELSE
                   NULL
           END AS MeetsCriteria,
           'GateWayOne' AS GateWay
    FROM TakenCompleted
    WHERE EDTC3310 = 'Not Taken'
          AND ECEC4311 = 'Not Taken'
          AND EDUL6391 = 'Not Taken'
          AND UTCH1101 = 'Not Taken'
          AND EDUC4611 = 'Not Taken'
          AND UNIV1301 = 'Not Taken'
    UNION
    SELECT TeacherCandidateIdentifier, --‘EDCI3334’, ‘EDTC3310’, and ‘ECEC4311’
           CASE
               WHEN EDCI3334 = 'Completed'
                    AND EDTC3310 = 'Completed'
                    AND ECEC4311 = 'Completed' THEN
                   1
               WHEN EDCI3334 IN ( 'Completed', 'Not Completed' )
                    AND EDTC3310 IN ( 'Completed', 'Not Completed' )
                    AND ECEC4311 IN ( 'Completed', 'Not Completed' ) THEN
                   0
               ELSE
                   NULL
           END AS MeetsCriteria,
           'GateWayTwo' AS Gateway
    FROM TakenCompleted
    WHERE EDUL6391 = 'Not Taken'
          AND UTCH1101 = 'Not Taken'
          AND EDUC4611 = 'Not Taken'
          AND UNIV1301 = 'Not Taken'
    UNION
    SELECT TeacherCandidateIdentifier, --‘EDCI3334’, ‘EDTC3310’, ‘ECEC4311’, ‘EDUL6391’, and ‘UTCH1101’,
           CASE
               WHEN EDCI3334 = 'Completed'
                    AND EDTC3310 = 'Completed'
                    AND ECEC4311 = 'Completed'
                    AND EDUL6391 = 'Completed'
                    AND UTCH1101 = 'Completed' THEN
                   1
               WHEN EDCI3334 = 'Completed'
                    AND EDTC3310 IN ( 'Completed', 'Not Completed' )
                    AND ECEC4311 IN ( 'Completed', 'Not Completed' )
                    AND EDUL6391 IN ( 'Completed', 'Not Completed' )
                    AND UTCH1101 IN ( 'Completed', 'Not Completed' ) THEN
                   0
               ELSE
                   NULL
           END AS MeetsCriteria,
           'GateWayThree' AS GateWay
    FROM TakenCompleted
    WHERE EDUC4611 = 'Not Taken'
          AND UNIV1301 = 'Not Taken'
    UNION
    SELECT TeacherCandidateIdentifier, -- ‘EDCI3334’, ‘EDTC3310’, ‘ECEC4311’, ‘EDUL6391’, ‘UTCH1101’, ‘EDUC4611’ and ‘UNIV1301’ 
           CASE
               WHEN EDCI3334 = 'Completed'
                    AND EDTC3310 = 'Completed'
                    AND ECEC4311 = 'Completed'
                    AND EDUL6391 = 'Completed'
                    AND UTCH1101 = 'Completed'
                    AND EDUC4611 = 'Completed'
                    AND UNIV1301 = 'Completed' THEN
                   1
               WHEN EDCI3334 = 'Completed'
                    AND EDTC3310 IN ( 'Completed', 'Not Completed' )
                    AND ECEC4311 IN ( 'Completed', 'Not Completed' )
                    AND EDUL6391 IN ( 'Completed', 'Not Completed' )
                    AND UTCH1101 IN ( 'Completed', 'Not Completed' )
                    AND EDUC4611 IN ( 'Completed', 'Not Completed' )
                    AND UNIV1301 IN ( 'Completed', 'Not Completed' ) THEN
                   0
               ELSE
                   NULL
           END AS MeetsCriteria,
           'GateWayFour' AS GateWay
    FROM TakenCompleted
) t
PIVOT
(
    MAX(MeetsCriteria)
    FOR GateWay IN ([GateWayOne], [GateWayTwo], [GateWayThree], [GateWayFour])
) p;
GO

