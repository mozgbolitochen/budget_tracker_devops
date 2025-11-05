#!/bin/bash

# varssss

REPO_PATH=$(pwd)
DOCKER_USER="mozgbolitochen"
IMAGE_TAG="$DOCKER_USER/budget-tracker:1.0"
SERVICE_NAME="budget-tracker.service"
UNIT_FILE="/etc/systemd/system/$SERVICE_NAME"
LOGS_DIR="/tmp/scheduled_logs"

echo "START :D"
echo "root dir: $REPO_PATH"

if [ "$EUID" -ne 0 ]; then
  echo "[ERROR D:]: please, use 'sudo'."
  exit 1
fi

echo "1. С $IMAGE_TAG..."

cd "$REPO_PATH/budget_tracker_container"

# Imagee building
docker build -t "$IMAGE_TAG" .
if [ $? -ne 0 ]; then
    echo "[ERROR D:] of building Docker image. check Dockerfile."
    # docker login/push
    exit 1
fi

cd "$REPO_PATH"

# Systemd Unit

echo "2. creating Unit-file $SERVICE_NAME..."

# Создание Unit-файла в /etc/systemd/system/
cat > "$UNIT_FILE" << EOF
[Unit]
Description=Budget Tracker Docker Container Service
Requires=docker.service
After=docker.service network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/docker run --name budget_tracker_app --rm $IMAGE_TAG
ExecStop=/usr/bin/docker stop budget_tracker_app
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "Dima's reoading and starting..."
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl start "$SERVICE_NAME"

echo "check of status:"
systemctl status "$SERVICE_NAME" | grep "Active:"

---
# (Cron)

echo "3. Cron..."

mkdir -p "$LOGS_DIR"
chmod 777 "$LOGS_DIR"

chmod +x "$REPO_PATH/scheduled_tasks/daily_report.sh"
chmod +x "$REPO_PATH/scheduled_tasks/hour_cleaning_service.sh"


DAILY_SCRIPT="$REPO_PATH/scheduled_tasks/daily_report.sh"
HOURLY_SCRIPT="$REPO_PATH/scheduled_tasks/hour_cleaning_service.sh"

(crontab -l 2>/dev/null; echo "15 * * * * $HOURLY_SCRIPT") | crontab -
(crontab -l 2>/dev/null; echo "0 23 * * * $DAILY_SCRIPT") | crontab -

echo "Cron cron crom. CRON list:"
crontab -l


echo "END   :D"
