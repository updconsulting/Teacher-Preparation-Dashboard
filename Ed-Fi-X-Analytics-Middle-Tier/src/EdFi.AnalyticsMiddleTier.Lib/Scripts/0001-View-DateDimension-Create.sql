CREATE VIEW [analytics].[DateDimension]
AS
WITH dates
AS (
   SELECT DISTINCT
          [Date]
   FROM [edfi].[CalendarDateCalendarEvent])
SELECT CONVERT(VARCHAR, [Date], 112) AS [DateKey],
       CAST(CONVERT(VARCHAR, [Date], 1) AS DATETIME) AS [Date],
       DAY([Date]) AS [Day],
       MONTH([Date]) AS [Month],
       DATENAME(MONTH, [Date]) AS [MonthName],
       CASE
           WHEN MONTH([Date])
                BETWEEN 1 AND 3 THEN
               1
           WHEN MONTH([Date])
                BETWEEN 4 AND 6 THEN
               2
           WHEN MONTH([Date])
                BETWEEN 7 AND 9 THEN
               3
           WHEN MONTH([Date])
                BETWEEN 10 AND 12 THEN
               4
       END AS [CalendarQuarter],
       CASE
           WHEN MONTH([Date])
                BETWEEN 1 AND 3 THEN
               'First'
           WHEN MONTH([Date])
                BETWEEN 4 AND 6 THEN
               'Second'
           WHEN MONTH([Date])
                BETWEEN 7 AND 9 THEN
               'Third'
           WHEN MONTH([Date])
                BETWEEN 10 AND 12 THEN
               'Fourth'
       END AS [CalendarQuarterName],
       YEAR([Date]) AS [CalendarYear]
FROM dates;
GO
