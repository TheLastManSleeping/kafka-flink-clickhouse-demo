# Берем за основу официальный образ Flink
FROM flink:1.18-scala_2.12

# Переключаемся на пользователя root, чтобы установить wget
USER root
RUN apt-get update && apt-get install -y --no-install-recommends wget && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /opt/flink/checkpoints && \
    chown -R flink:flink /opt/flink/checkpoints

# Скачиваем коннектор для Kafka
RUN wget -O /opt/flink/lib/flink-sql-connector-kafka.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.1.0-1.18/flink-sql-connector-kafka-3.1.0-1.18.jar

# Возвращаемся к стандартному пользователю flink
USER flink