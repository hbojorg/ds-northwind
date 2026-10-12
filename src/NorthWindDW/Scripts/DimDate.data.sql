-- =============================================================================
-- Poblado de DimDate (1996-01-01 .. 2030-12-31) de forma SET-BASED (sin WHILE).
-- Los nombres de dia/mes se resuelven con CASE para no depender del idioma
-- de la sesion (DATENAME cambia segun SET LANGUAGE).
-- Idempotente: solo inserta fechas que aun no existen.
-- =============================================================================
DECLARE @StartDate DATE = '1996-01-01',
        @EndDate   DATE = '2030-12-31';

;WITH N1 AS (SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS v(n)),
      N2 AS (SELECT a.n * 10 + b.n AS n FROM N1 AS a CROSS JOIN N1 AS b),          -- 0..99
      N4 AS (SELECT a.n * 100 + b.n AS n FROM N2 AS a CROSS JOIN N2 AS b),         -- 0..9999
      N5 AS (SELECT a.n * 10000 + b.n AS n FROM N1 AS a CROSS JOIN N4 AS b),       -- 0..99999
      Dates AS
      (
          SELECT FullDate = DATEADD(DAY, n, @StartDate)
          FROM   N5
          WHERE  n <= DATEDIFF(DAY, @StartDate, @EndDate)
      ),
      Calc AS
      (
          SELECT d.FullDate,
                 IsoDow  = ((DATEPART(WEEKDAY, d.FullDate) + @@DATEFIRST - 2) % 7) + 1,   -- 1 = lunes
                 MonthNo = DATEPART(MONTH, d.FullDate),
                 Yr      = DATEPART(YEAR, d.FullDate),
                 Qtr     = DATEPART(QUARTER, d.FullDate)
          FROM   Dates AS d
      )
INSERT INTO [dbo].[DimDate]
       (DateKey, FullDate, DayNumberOfWeek, DayNameOfWeek, DayNameOfWeekES, DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear,
        [MonthName], MonthNameES, MonthNumberOfYear, YearMonth, YearMonthName, CalendarQuarter, CalendarQuarterName, CalendarSemester,
        CalendarYear, IsWeekend, IsLastDayOfMonth)
SELECT DateKey            = CONVERT(INT, CONVERT(CHAR(8), c.FullDate, 112)),
       FullDate           = c.FullDate,
       DayNumberOfWeek    = c.IsoDow,
       DayNameOfWeek      = CASE c.IsoDow WHEN 1 THEN N'Monday' WHEN 2 THEN N'Tuesday' WHEN 3 THEN N'Wednesday' WHEN 4 THEN N'Thursday'
                                          WHEN 5 THEN N'Friday' WHEN 6 THEN N'Saturday' ELSE N'Sunday' END,
       DayNameOfWeekES    = CASE c.IsoDow WHEN 1 THEN N'Lunes' WHEN 2 THEN N'Martes' WHEN 3 THEN N'Miércoles' WHEN 4 THEN N'Jueves'
                                          WHEN 5 THEN N'Viernes' WHEN 6 THEN N'Sábado' ELSE N'Domingo' END,
       DayNumberOfMonth   = DATEPART(DAY, c.FullDate),
       DayNumberOfYear    = DATEPART(DAYOFYEAR, c.FullDate),
       WeekNumberOfYear   = DATEPART(ISO_WEEK, c.FullDate),
       [MonthName]        = CASE c.MonthNo WHEN 1 THEN N'January' WHEN 2 THEN N'February' WHEN 3 THEN N'March' WHEN 4 THEN N'April'
                                           WHEN 5 THEN N'May' WHEN 6 THEN N'June' WHEN 7 THEN N'July' WHEN 8 THEN N'August'
                                           WHEN 9 THEN N'September' WHEN 10 THEN N'October' WHEN 11 THEN N'November' ELSE N'December' END,
       MonthNameES        = CASE c.MonthNo WHEN 1 THEN N'Enero' WHEN 2 THEN N'Febrero' WHEN 3 THEN N'Marzo' WHEN 4 THEN N'Abril'
                                           WHEN 5 THEN N'Mayo' WHEN 6 THEN N'Junio' WHEN 7 THEN N'Julio' WHEN 8 THEN N'Agosto'
                                           WHEN 9 THEN N'Septiembre' WHEN 10 THEN N'Octubre' WHEN 11 THEN N'Noviembre' ELSE N'Diciembre' END,
       MonthNumberOfYear  = c.MonthNo,
       YearMonth          = c.Yr * 100 + c.MonthNo,
       YearMonthName      = CONVERT(NVARCHAR(4), c.Yr) + N'-' + RIGHT(N'0' + CONVERT(NVARCHAR(2), c.MonthNo), 2),
       CalendarQuarter    = c.Qtr,
       CalendarQuarterName= CONVERT(NVARCHAR(4), c.Yr) + N'-Q' + CONVERT(NVARCHAR(1), c.Qtr),
       CalendarSemester   = CASE WHEN c.Qtr <= 2 THEN 1 ELSE 2 END,
       CalendarYear       = c.Yr,
       IsWeekend          = CASE WHEN c.IsoDow >= 6 THEN 1 ELSE 0 END,
       IsLastDayOfMonth   = CASE WHEN c.FullDate = EOMONTH(c.FullDate) THEN 1 ELSE 0 END
FROM   Calc AS c
WHERE  NOT EXISTS (SELECT 1 FROM [dbo].[DimDate] AS dd WHERE dd.FullDate = c.FullDate)
ORDER BY c.FullDate;
GO
