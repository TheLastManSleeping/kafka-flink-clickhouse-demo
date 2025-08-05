-- Определяем источник, читающий все "сырые" события из Kafka
CREATE TABLE `raw_events_source` (
  `timestamp` STRING,
  `user_id` STRING,
  `ip_address` STRING,
  `url` STRING,
  `element_id` STRING,
  `duration_seconds` BIGINT,
  `order_id` STRING,
  `amount` DOUBLE,
  `topic` STRING METADATA VIRTUAL
) WITH (
  'connector' = 'kafka',
  'topic-pattern' = 'user_clicks|page_views|orders',
  'properties.bootstrap.servers' = 'kafka:9092',
  'properties.group.id' = 'flink-sql-group-raw',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'json'
);

-- Определяем приемник, который пишет обработанные события в один новый топик
CREATE TABLE `processed_events_sink` (
  `event_type` STRING,
  `event_timestamp` TIMESTAMP(3),
  `user_id` STRING,
  `details` STRING
) WITH (
  'connector' = 'kafka',
  'topic' = 'processed_events',
  'properties.bootstrap.servers' = 'kafka:9092',
  'format' = 'json'
);

-- Запускаем задание по трансформации и перекладке данных
INSERT INTO `processed_events_sink`
SELECT
    -- Пример трансформации: берем тип события из имени топика
    UPPER(REPLACE(`topic`, 'user_', '')), 
    -- Преобразуем дату
    TO_TIMESTAMP(`timestamp`),
    `user_id`,
    -- Пример трансформации: объединяем детали в одну строку
    CONCAT_WS(' | ', `url`, `element_id`, CAST(`order_id` AS STRING), CAST(`amount` AS STRING))
FROM `raw_events_source`;