#!/bin/bash

: <<'title'
Log Analyzer and Report Generator
title

# Function to display usage
function display_usage {
    echo "Usage: $0 <path to log file>"
}

# Ensure exactly one argument is passed
if [[ $# -ne 1 ]]; then
    display_usage
    exit 1
fi

LOG_FILE="$1"

# Log file existence check
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Log file does not exist."
    exit 1
fi

# Variables
ERROR_KEYWORD="error"
CRITICAL_KEYWORD="critical"
DATE=$(date +"%Y-%m-%d")
SUMMARY_REPORT="SUMMARY_REPORT_$DATE.txt"
ARCHIVE_DIR="processed_logs"

# Create a Summary Report
{
    echo "Date of analysis: $DATE"
    echo "Log file name: $LOG_FILE"
} > "$SUMMARY_REPORT"

# Total Lines Processed
TOTAL_LINES=$(wc -l < "$LOG_FILE")
echo "Total Processed Lines: $TOTAL_LINES" >> "$SUMMARY_REPORT"

# Count Number of Error Messages
ERROR_COUNT=$(grep -ci "$ERROR_KEYWORD" "$LOG_FILE")
echo "Total Error Count: $ERROR_COUNT" >> "$SUMMARY_REPORT"

# List of Critical Events with Line Numbers
echo "List of Critical Events with Line Numbers:" >> "$SUMMARY_REPORT"
grep -ni "$CRITICAL_KEYWORD" "$LOG_FILE" >> "$SUMMARY_REPORT"

# Identify the Top 5 Most Common Error Messages
declare -A error_messages

while IFS= read -r line; do
    if [[ "$line" == *"$ERROR_KEYWORD"* ]]; then
        message=$(echo "$line" | awk -F "$ERROR_KEYWORD" '{print $3}' | xargs)
        ((error_messages["$message"]++))
    fi
done < "$LOG_FILE"

# Sort and Display Top 5 Error Messages
echo "Top 5 Error Messages with Their Occurrence Count:" >> "$SUMMARY_REPORT"

for message in "${!error_messages[@]}"; do
    echo "${error_messages["$message"]} : $message"
done | sort -rn | head -n 5 >> "$SUMMARY_REPORT"


# Archive or Move Processed Log Files
if [[ ! -d "$ARCHIVE_DIR" ]]; then
    mkdir -p "$ARCHIVE_DIR"
fi
mv "$LOG_FILE" "$ARCHIVE_DIR/"

# Print the Summary Report
cat "$SUMMARY_REPORT"
