CREATE OR REFRESH MATERIALIZED VIEW tfl_crowding_analysis_we.bronze.crowd_raw_BRONZE
(CONSTRAINT valid_percentage EXPECT(percentageOfBaseline > 10))
COMMENT "Raw data from REST API"
AS SELECT * FROM tfl_crowding_analysis_we.bronze.raw_crowding_logs;

CREATE OR REFRESH MATERIALIZED VIEW tfl_crowding_analysis_we.bronze.naptan_raw_BRONZE
COMMENT "Raw naptan CSV from volume"
AS
SELECT *
FROM read_files(
  '/Volumes/tfl_crowding_analysis_we/default/naptancodes/naptan.csv',
  format => 'csv',
  header => true
);

CREATE OR REFRESH MATERIALIZED VIEW tfl_crowding_analysis_we.bronze.crowd_napton_join
COMMENT "Joining naptan"
AS
(SELECT C.naptonId,
        N.commonName,
        C.timeLocal,
        C.percentageOfBaseline
FROM tfl_crowding_analysis_we.bronze.naptan_raw_BRONZE N
JOIN tfl_crowding_analysis_we.bronze.crowd_raw_BRONZE C
  ON N.naptanID = C.naptonId);

CREATE OR REFRESH MATERIALIZED VIEW tfl_crowding_analysis_we.silver.crowd_napton_SILVER
(CONSTRAINT valid_percentage EXPECT(percentageOfBaseline > 10) ON VIOLATION DROP ROW)
COMMENT "Aggregating"
AS
  (
    SELECT
          naptonId,
          commonName,
          percentageOfBaseline,
          timeLocal,
          DAY(timeLocal) AS day
    FROM tfl_crowding_analysis_we.bronze.crowd_napton_join
  );

CREATE OR REFRESH MATERIALIZED VIEW tfl_crowding_analysis_we.gold.crowd_napton_GOLD
COMMENT "Gold Layer"
AS
  (
    SELECT
          naptonId,
          commonName,
          percentageOfBaseline * 100 AS percentageOfBaseline,
          timeLocal,
          day
    FROM tfl_crowding_analysis_we.silver.crowd_napton_SILVER
  );








