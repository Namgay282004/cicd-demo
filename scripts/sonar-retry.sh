#!/bin/bash

# Script to retry SonarCloud analysis with better error handling
set -e

echo "Starting SonarCloud analysis with retry mechanism..."

MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "Attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES"
    
    if mvn sonar:sonar \
        -Dsonar.projectKey=Namgay282004_cicd-demo \
        -Dsonar.organization=${SONAR_ORGANIZATION} \
        -Dsonar.host.url=https://sonarcloud.io \
        -Dsonar.verbose=true \
        -Dsonar.log.level=DEBUG; then
        echo "SonarCloud analysis completed successfully!"
        exit 0
    else
        echo "Attempt $((RETRY_COUNT + 1)) failed"
        RETRY_COUNT=$((RETRY_COUNT + 1))
        
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "Waiting 30 seconds before retry..."
            sleep 30
            
            # Clean up any potentially corrupted cache
            rm -rf ~/.sonar/cache/*
            echo "Cleared SonarCloud cache"
        fi
    fi
done

echo "All retry attempts failed"
exit 1
