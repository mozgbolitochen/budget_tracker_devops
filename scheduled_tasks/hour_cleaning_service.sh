#!/bin/bash

LOG_DIR="/tmp/scheduled_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/hourly_cleanup.log"

echo "Cleanup executed at: $(date) :D" >> "$LOG_FILE"

# find /tmp/old_data -type f -mtime +7 -delete
