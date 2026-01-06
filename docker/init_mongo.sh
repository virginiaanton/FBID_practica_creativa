#!/bin/bash
set -e

echo "================================================"
echo "MongoDB Initialization Script"
echo "Downloading data and importing to MongoDB"
echo "================================================"

# Create data directory
DATA_DIR="/tmp/mongo-init-data"
mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

echo ""
echo "Step 1: Downloading all required data files..."
echo "----------------------------------------------"

# Download simple flight delay features for training
echo "  - Downloading simple_flight_delay_features.jsonl.bz2..."
curl -Lko simple_flight_delay_features.jsonl.bz2 http://s3.amazonaws.com/agile_data_science/simple_flight_delay_features.jsonl.bz2

# Download the distances between pairs of airports
echo "  - Downloading origin_dest_distances.jsonl..."
curl -Lko origin_dest_distances.jsonl http://s3.amazonaws.com/agile_data_science/origin_dest_distances.jsonl

# Download sklearn models (for web predictions)
echo "  - Downloading sklearn_vectorizer.pkl..."
curl -Lko sklearn_vectorizer.pkl http://s3.amazonaws.com/agile_data_science/sklearn_vectorizer.pkl

echo "  - Downloading sklearn_regressor.pkl..."
curl -Lko sklearn_regressor.pkl http://s3.amazonaws.com/agile_data_science/sklearn_regressor.pkl

echo ""
echo "Step 2: Waiting for MongoDB to be ready..."
echo "----------------------------------------------"
until mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; do
  echo "  Waiting for MongoDB..."
  sleep 2
done
echo "  MongoDB is ready!"

echo ""
echo "Step 3: Importing distance data into MongoDB..."
echo "----------------------------------------------"
mongoimport --db agile_data_science \
            --collection origin_dest_distances \
            --file "$DATA_DIR/origin_dest_distances.jsonl"

echo ""
echo "Step 4: Creating index on Origin and Dest fields..."
echo "----------------------------------------------"
mongosh agile_data_science --quiet --eval 'db.origin_dest_distances.createIndex({Origin: 1, Dest: 1})'

# Verify import
TOTAL_DOCS=$(mongosh agile_data_science --quiet --eval 'db.origin_dest_distances.countDocuments()')

echo ""
echo "================================================"
echo "Import completed successfully!"
echo "Total documents imported: $TOTAL_DOCS"
echo "================================================"
echo ""
echo "Downloaded files are available in: $DATA_DIR"
echo "  - simple_flight_delay_features.jsonl.bz2"
echo "  - origin_dest_distances.jsonl"
echo "  - sklearn_vectorizer.pkl"
echo "  - sklearn_regressor.pkl"
echo ""
echo "Note: These files will be cleaned up after initialization"
echo "      unless you mount $DATA_DIR as a volume."
echo ""

# Cleanup temporary files (comment this out if you want to preserve them)
echo "Cleaning up temporary files..."
cd /  # Return to root before deleting the directory
rm -rf "$DATA_DIR"

echo "MongoDB initialization complete!"
