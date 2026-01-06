#!/bin/bash
set -e

echo "Formatting Kafka storage..."
# Use KAFKA_CLUSTER_ID from environment, or generate a random one if not set
CLUSTER_ID=${KAFKA_CLUSTER_ID:-$(/opt/kafka/bin/kafka-storage.sh random-uuid)}
/opt/kafka/bin/kafka-storage.sh format --ignore-formatted \
  --cluster-id "$CLUSTER_ID" \
  --config /opt/kafka/config/kafka.server.properties

echo "Starting Kafka server in background..."
/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kafka.server.properties &
KAFKA_PID=$!

echo "Waiting for Kafka to be ready..."
for i in {1..60}; do
  if /opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092 &>/dev/null; then
    echo "Kafka is ready!"
    break
  fi
  if [ $i -eq 60 ]; then
    echo "Kafka failed to start within 60 seconds"
    exit 1
  fi
  echo "Waiting for Kafka... ($i/60)"
  sleep 1
done

echo "Creating topic: flight-delay-ml-request"
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 1 \
  --topic flight-delay-ml-request \
  --if-not-exists

echo "Creating topic: flight-delay-ml-predictions"
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 1 \
  --topic flight-delay-ml-predictions \
  --if-not-exists

echo "Listing all topics:"
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092

echo "Kafka setup complete. Waiting for Kafka process..."
wait $KAFKA_PID
