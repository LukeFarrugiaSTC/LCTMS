#!/bin/bash
set -e

mkdir -p ./frontend/assets/certs

# Step 1: Update the API configuration file using your update script.
echo "Updating API configuration..."
./ip-entrypoint.sh

# Step 3: Build and run Docker containers.
echo "Building and starting Docker containers..."
docker compose up --build -d

echo "Containers are up and running."