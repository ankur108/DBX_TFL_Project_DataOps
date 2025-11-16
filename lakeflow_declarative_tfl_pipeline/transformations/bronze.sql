CREATE LIVE TABLE bronze_crowd_data
COMMENT "Raw ADLS Delta source"
AS SELECT * FROM delta.`abfss://bronze@tflopendatalogs.dfs.core.windows.net/Crowding_JSON_Logs`;