FROM mongo:7.0.17

# Install curl for downloading data
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy initialization script
COPY --chmod=755 docker/init_mongo.sh /docker-entrypoint-initdb.d/01-init-mongo.sh
