-- Таблица для чтения из обработанного Flink'ом топика Kafka
CREATE TABLE default.events_queue (
    `event_type` String,
    `event_timestamp` DateTime,
    `user_id` String,
    `details` String
) ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'processed_events',
    kafka_group_name = 'clickhouse_flink_group',
    kafka_format = 'JSONEachRow';

-- Финальная таблица для хранения
CREATE TABLE default.events_processed (
    `event_type` String,
    `event_timestamp` DateTime,
    `user_id` String,
    `details` String
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(event_timestamp)
ORDER BY (event_timestamp, user_id);

-- Материализованное представление для переноса данных
CREATE MATERIALIZED VIEW default.events_mv TO default.events_processed AS
SELECT * FROM default.events_queue;