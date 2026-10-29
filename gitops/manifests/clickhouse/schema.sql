CREATE DATABASE IF NOT EXISTS observability ON CLUSTER obs;

CREATE TABLE IF NOT EXISTS observability.inference_events_local ON CLUSTER obs
(
    timestamp        DateTime64(3, 'UTC'),
    cluster          LowCardinality(String),
    team             LowCardinality(String),
    service          LowCardinality(String),
    model            LowCardinality(String),
    gpu_node         LowCardinality(String),
    status           LowCardinality(String),
    input_tokens     UInt32,
    output_tokens    UInt32,
    ttft_ms          Float32,
    latency_ms       Float32,
    trace_id         String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/inference_events', '{replica}')
PARTITION BY toDate(timestamp)
ORDER BY (team, model, timestamp)
TTL toDateTime(timestamp) + INTERVAL 180 DAY DELETE;

CREATE TABLE IF NOT EXISTS observability.inference_events ON CLUSTER obs
AS observability.inference_events_local
ENGINE = Distributed(obs, observability, inference_events_local, cityHash64(trace_id));
