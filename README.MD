

# Real-Time Data Pipeline: Kafka ➔ Flink ➔ ClickHouse

Этот проект демонстрирует полноценный, отказоустойчивый конвейер для потоковой обработки данных. События генерируются, поступают в Apache Kafka, трансформируются в реальном времени с помощью Apache Flink и сохраняются в аналитическую базу данных ClickHouse.

## Архитектура и поток данных

Система реализует классический ETL-процесс (Extract, Transform, Load) в потоковом режиме.

`[Event Emitter]` ➔ `[Kafka (сырые топики)]` ➔ `[Flink]` ➔ `[Kafka (чистый топик)]` ➔ `[ClickHouse]`

1.  **Event Emitter**: Генерирует "сырые" события в три разных топика Kafka.
2.  **Apache Flink**: Выполняет **одно** ETL-задание — читает данные из трех "сырых" топиков, объединяет их в единый формат и отправляет в один "чистый" топик `processed_events`.
3.  **ClickHouse**: Использует свой надежный, встроенный `Kafka Engine` для чтения данных из финального топика `processed_events` и сохранения их в таблицу.

-----

## Ключевые особенности

  * **Потоковый ETL**: Демонстрация трансформации данных в реальном времени с помощью Flink SQL.
  * **Отказоустойчивость**: Настроенный механизм чекпоинтинга во Flink для восстановления после сбоев.
  * **Полная автоматизация**: Кастомный образ Flink автоматически скачивает все зависимости при сборке.
  * **Гибкая конфигурация**: Ключевые параметры вынесены в `docker-compose.yml`.

-----

## Структура проекта

```
.
├── docker-compose.yml      # Главный файл, описывающий все сервисы
├── kafka-entrypoint.sh     # Скрипт для авто-генерации CLUSTER_ID для Kafka            
│
├── clickhouse_init/
│   └── init.sql          # SQL-схема для ClickHouse
│
├── emitter/                # Компоненты генератора событий
│   ├── Dockerfile
│   ├── emitter.py
│   └── requirements.txt
│
└── flink/
    ├── Dockerfile          # Dockerfile для сборки кастомного образа Flink
    └── sql/
        └── job.sql       # SQL-скрипт для Flink

```

-----

## Как запустить

1.  Склонируйте репозиторий:
    ```bash
    git clone https://github.com/TheLastManSleeping/kafka-flink-clickhouse-demo.git
    ```
2.  Запустите все сервисы:
    
    ```bash
    docker compose up -d --build
    ```

  
    Сборка кастомного образа Flink в первый раз может занять несколько минут.


-----

## Проверка работоспособности

1.  **Статус контейнеров**: Убедитесь, что все сервисы запущены.

    ```bash
    docker compose ps
    ```

2.  **Flink Web UI**: Откройте **[http://localhost:8081](https://www.google.com/search?q=http://localhost:8081)**. Перейдите в Running Jobs -> нажмите на таск -> выберите Metrics -> создайте метрику numRecordsOut. Если данные изменяются со временем - всё работает

3.  **Данные в ClickHouse**: Подключитесь к ClickHouse и проверьте, что данные поступают.

    ```bash
    docker compose exec clickhouse-server clickhouse-client
    ```

    Внутри клиента выполните запрос (сделайте это несколько раз, чтобы увидеть рост):

    ```sql
    SELECT count() FROM events_processed;
    ```

-----


## Остановка проекта

  * Для остановки всех сервисов и удаления контейнеров:
    ```bash
    docker compose down
    ```
