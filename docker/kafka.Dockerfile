FROM apache/kafka:3.9.0

# Copy configuration and initialization script
COPY docker/kafka.server.properties /opt/kafka/config/kafka.server.properties
COPY --chmod=755 docker/init_kafka.sh /opt/kafka/init_kafka.sh

# Use the initialization script as entrypoint
ENTRYPOINT ["/opt/kafka/init_kafka.sh"]
