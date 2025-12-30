FROM apache/kafka:3.9.0
COPY docker/kafka.server.properties /opt/kafka/config/kafka.server.properties
ENTRYPOINT ["/bin/bash","-c", "\
set -e; \
/opt/kafka/bin/kafka-storage.sh format --ignore-formatted \
  --cluster-id \"$(/opt/kafka/bin/kafka-storage.sh random-uuid)\" \
  --config /opt/kafka/config/kafka.server.properties; \
exec /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kafka.server.properties"]
