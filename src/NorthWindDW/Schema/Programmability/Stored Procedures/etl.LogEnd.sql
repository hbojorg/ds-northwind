-- Cierra un registro de la bitacora del ETL con los contadores y el estado final.
CREATE PROCEDURE [etl].[LogEnd]
(
    @LogID         INT,
    @RowsExtracted INT,
    @RowsInserted  INT,
    @RowsUpdated   INT,
    @RowsExpired   INT,
    @Status        VARCHAR(20),
    @ErrorMessage  NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [etl].[ETLLog]
    SET    EndTime       = SYSDATETIME(),
           RowsExtracted = @RowsExtracted,
           RowsInserted  = @RowsInserted,
           RowsUpdated   = @RowsUpdated,
           RowsExpired   = @RowsExpired,
           Status        = @Status,
           ErrorMessage  = @ErrorMessage
    WHERE  LogID = @LogID;
END
GO
