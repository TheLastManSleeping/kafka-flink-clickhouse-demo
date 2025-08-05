#!/bin/bash
set -e

# 1. Запускаем основной процесс JobManager в фоновом режиме
echo "Starting JobManager in background..."
/opt/flink/bin/jobmanager.sh start-foreground &
JOBMANAGER_PID=$!

# 2. Ожидаем, пока сам JobManager запустится и откроет свой порт
echo "Waiting for JobManager UI (localhost:8081)..."
while ! timeout 1 bash -c "true &>/dev/null </dev/tcp/localhost/8081"; do
    echo -n "."
    sleep 1
done
echo -e "\nJobManager is up and running."

# 3. Ожидаем Kafka и ClickHouse, как и раньше
echo "Waiting for Kafka (kafka:9092)..."
while ! timeout 1 bash -c "true &>/dev/null </dev/tcp/kafka/9092"; do
    echo -n "."
    sleep 1
done
echo -e "\nKafka is up."

echo "Waiting for ClickHouse (clickhouse-server:8123)..."
while ! timeout 1 bash -c "true &>/dev/null </dev/tcp/clickhouse-server/8123"; do
    echo -n "."
    sleep 1
done
echo -e "\nClickHouse is up."

# 4. Отправляем наше SQL-задание, когда все готово
echo "Services are ready, submitting Flink SQL Job..."
/opt/flink/bin/sql-client.sh \
--jar /opt/flink/connectors/flink-sql-connector-kafka-3.1.0-1.18.jar \
--jar /opt/flink/connectors/flink-connector-jdbc-3.1.2-1.18.jar \
--jar /opt/flink/connectors/clickhouse-jdbc-0.3.1-patch.jar \
-f /opt/flink/sql/job.sql

echo "SQL Job submitted."

# 5. Ожидаем завершения фонового процесса JobManager, чтобы контейнер не останавливался
wait $JOBMANAGER_PID