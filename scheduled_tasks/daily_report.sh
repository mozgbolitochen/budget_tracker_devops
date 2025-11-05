#!/bin/bash

LOG_DIR="/tmp/scheduled_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/daily_report.log"

echo ":D Daily Report Run: $(date) :D" >> "$LOG_FILE"
echo "Active processes count:" >> "$LOG_FILE"
ps aux | wc -l >> "$LOG_FILE"
echo ":D:D:D:D:D:D:D:D:D:D:D:D:D:D:D:D:D:D:D:D" >> "$LOG_FILE"
