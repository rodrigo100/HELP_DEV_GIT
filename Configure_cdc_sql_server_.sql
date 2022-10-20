/*Configuuration CDC in SQL SERVER 2019 DEV */

/*enable dababase to CDC cdc_enable_db*/
Use SOURCE;
EXEC sys.sp_cdc_enable_db
GO;
/*VIEW DATABASES ACTIVES WTH CDC*/
SELECT [name], database_id, is_cdc_enabled FROM sys.databases;

/*enable table to CDC cdc_enable_db*/
EXEC sys.sp_cdc_enable_table
@source_schema = 'dbo',
@source_name = 'friends',
@role_name = null,
@supports_net_changes = 1;

/*VIEW TABLES ACTIVES WTH CDC*/
select name,type,type_desc,is_tracked_by_cdc from sys.tables;





/*------------------------------------------------
Enable CDC on Set of Tables
( To Enable CDC on Table , CDC Should be enabled on Database level)
--------------------------------------------------*/

DECLARE @TableName VARCHAR(100)
DECLARE @TableSchema VARCHAR(100)
DECLARE CDC_Cursor CURSOR FOR
  SELECT *
  FROM   (
         
        /* SELECT 'T' AS TableName,'dbo' AS TableSchema
          UNION ALL
          SELECT 'T2' AS TableName,'dbo' AS TableSchema*/
           --IF want to Enable CDC on All Table, then use
         SELECT Name,SCHEMA_NAME(schema_id) AS TableSchema
         FROM   sys.objects
         WHERE  type = 'u'
               AND is_ms_shipped <> 1
         ) CDC

OPEN CDC_Cursor

FETCH NEXT FROM CDC_Cursor INTO @TableName,@TableSchema

WHILE @@FETCH_STATUS = 0
  BEGIN
      DECLARE @SQL NVARCHAR(1000)
      DECLARE @CDC_Status TINYINT

      SET @CDC_Status=(SELECT COUNT(*)
          FROM   cdc.change_tables
          WHERE  Source_object_id = OBJECT_ID(@TableSchema+'.'+@TableName))

      --IF CDC Already Enabled on Table , Print Message
      IF @CDC_Status = 1
        PRINT 'CDC is already enabled on ' +@TableSchema+'.'+@TableName
              + ' Table'

      --IF CDC is not enabled on Table, Enable CDC and Print Message
      IF @CDC_Status <> 1
        BEGIN
            SET @SQL='EXEC sys.sp_cdc_enable_table
      @source_schema = '''+@TableSchema+''',
      @source_name   = ''' + @TableName
                     + ''',
      @role_name     = null;'

            EXEC sp_executesql @SQL

            PRINT 'CDC  enabled on ' +@TableSchema+'.'+ @TableName
                  + ' Table successfully'
        END

      FETCH NEXT FROM CDC_Cursor INTO @TableName,@TableSchema
  END

CLOSE CDC_Cursor

DEALLOCATE CDC_Cursor
