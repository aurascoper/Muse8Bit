#!/bin/bash

RETRY_COUNT=3
URL=$1
DESTINATION=$2

for i in $(seq $RETRY_COUNT); do
    git clone $URL $DESTINATION && break || {
        echo "Failed to clone. Retrying..."
        sleep 5  # Adjust sleep duration as needed
    }
done
