-- =============================================================================
-- DimDate: dimension de tiempo (role-playing: fecha de pedido, requerida y envio).
-- DateKey = AAAAMMDD. La fila -1 representa "fecha desconocida" (p. ej. pedidos
-- aun no enviados), lo que permite que las FK del hecho sean NOT NULL.
-- Mejoras vs. referencia: nombres en ingles y espanol, semana ISO, bandera de
-- fin de semana, atributos AnioMes / AnioTrimestre listos para ordenar en BI.
-- =============================================================================
CREATE TABLE [dbo].[DimDate]
(
    [DateKey]             [int]          NOT NULL CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED,
    [FullDate]            [date]         NOT NULL,
    [DayNumberOfWeek]     [tinyint]      NOT NULL,   -- ISO: 1 = lunes ... 7 = domingo
    [DayNameOfWeek]       [nvarchar](10) NOT NULL,
    [DayNameOfWeekES]     [nvarchar](12) NOT NULL,
    [DayNumberOfMonth]    [tinyint]      NOT NULL,
    [DayNumberOfYear]     [smallint]     NOT NULL,
    [WeekNumberOfYear]    [tinyint]      NOT NULL,   -- semana ISO 8601
    [MonthName]           [nvarchar](10) NOT NULL,
    [MonthNameES]         [nvarchar](12) NOT NULL,
    [MonthNumberOfYear]   [tinyint]      NOT NULL,
    [YearMonth]           [int]          NOT NULL,   -- AAAAMM (para ordenar)
    [YearMonthName]       [nvarchar](8)  NOT NULL,   -- '1997-07'
    [CalendarQuarter]     [tinyint]      NOT NULL,
    [CalendarQuarterName] [nvarchar](8)  NOT NULL,   -- '1997-Q3'
    [CalendarSemester]    [tinyint]      NOT NULL,
    [CalendarYear]        [smallint]     NOT NULL,
    [IsWeekend]           [bit]          NOT NULL,
    [IsLastDayOfMonth]    [bit]          NOT NULL
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_DimDate_FullDate] ON [dbo].[DimDate] ([FullDate] ASC);
GO
