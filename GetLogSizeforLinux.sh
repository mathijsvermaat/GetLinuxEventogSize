#!/bin/bash

# === CONFIGURATION ===
LOG_FILES=("/var/log/syslog" "/var/log/auth.log" "/var/log/audit/audit.log")  # Customize as needed
TMP_DIR="/tmp/log_analysis"
mkdir -p "$TMP_DIR"

# === TIME RANGE ===
# Get the last full month (e.g., if today is July, analyze June)
LAST_MONTH=$(date -d "$(date +%Y-%m-15) -1 month" +%Y-%m)
START_DATE="${LAST_MONTH}-01"
END_DATE=$(date -d "$START_DATE +1 month -1 day" +%Y-%m-%d)
DAYS_IN_MONTH=$(date -d "$END_DATE" +%d)

# === AGGREGATE LOGS FOR THE MONTH ===
echo "Analyzing logs from $START_DATE to $END_DATE..."

MATCHED_LOG="$TMP_DIR/filtered.log"
> "$MATCHED_LOG"

# Use journalctl if available, or fallback to plain text logs
if command -v journalctl &>/dev/null; then
    echo "Using journalctl for log extraction..."
    journalctl --since "$START_DATE" --until "$END_DATE 23:59:59" > "$MATCHED_LOG"
else
    echo "Using grep over plain-text log files..."
    for file in "${LOG_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            grep -hE "^$(date -d "$START_DATE" '+%b')|^$(date -d "$END_DATE" '+%b')" "$file" >> "$MATCHED_LOG"
        fi
    done
fi

# === CALCULATE METRICS ===
total_events=$(wc -l < "$MATCHED_LOG")
total_bytes=$(wc -c < "$MATCHED_LOG")

# EPS = events per second = total events / seconds in the month
total_seconds=$((DAYS_IN_MONTH * 86400))
EPS=$(echo "scale=2; $total_events / $total_seconds" | bc)

# GB per day
total_gb=$(echo "scale=2; $total_bytes / (1024 * 1024 * 1024)" | bc)
gb_per_day=$(echo "scale=2; $total_gb / $DAYS_IN_MONTH" | bc)

# === OUTPUT ===
echo "--------------------------------------------------"
echo "Analyzed month: $LAST_MONTH"
echo "Total events: $total_events"
echo "Total bytes: $total_bytes"
echo "Average EPS: $EPS events/sec"
echo "Average GB/day: $gb_per_day GB"
echo "Total ingest (month): $total_gb GB"
echo "--------------------------------------------------"

# Optional cleanup
# rm -f "$MATCHED_LOG"