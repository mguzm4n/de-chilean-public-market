#!/bin/bash

FLAG_FILE="/opt/.first_boot_completed"

if [ ! -f "$FLAG_FILE" ]; then
    echo "First boot detected. Installing Docker and dependencies..."
    
    apt-get update
    apt-get install -y ca-certificates curl gnupg git
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
      
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    touch "$FLAG_FILE"
else
    echo "Subsequent boot detected. Skipping heavy installations."
fi

cd /opt

# Handle Git safely
if [ ! -d "de-chilean-public-market" ]; then
    echo "Repository not found. Cloning..."
    git clone https://github.com/mguzm4n/de-chilean-public-market
else
    echo "Repository found. Pulling latest changes..."
    cd de-chilean-public-market
    # Stash any local accidental changes, then pull
    git stash
    git pull
    cd ..
fi

cd /opt/de-chilean-public-market/ingest/airflow


gcloud storage cp gs://${BUCKET_NAME}/config/ingest/airflow/.env .env

if ! grep -q "^AIRFLOW_UID=" .env; then
    echo -e "\nAIRFLOW_UID=$(id -u)" >> .env
fi

docker compose up -d > /var/log/my-docker-compose.log 2>&1