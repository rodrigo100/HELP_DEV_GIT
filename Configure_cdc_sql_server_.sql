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
select name,type,type_desc,is_tracked_by_cdc
from sys.tables;



