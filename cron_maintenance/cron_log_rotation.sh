#!/usr/bin/env bash

# ROTATE CRON LOGS

# Define variables
log_file="/var/log/system_maintenance.log"
log_path="/var/log"

# Create a log file if it doesn't exist
touch $log_file

# Check system disk space usage and append the result to the log file
df -h >> $log_file

# Remove old log files
find $log_path -type f -name "*.log*" -mtime +2 -delete >> $log_file
