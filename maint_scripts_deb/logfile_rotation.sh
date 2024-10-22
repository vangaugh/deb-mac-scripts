#!/usr/bin/env bash

# CUSTOM VARIABLES
LOG_FILE="/var/log/logfile.log"
MAX_SIZE=10485760 # 10 MB
CURRENT_SIZE=$(wc -c <"${LOG_FILE}")

# EXECUTE SCRIPT
if [ "${CURRENT_SIZE}" -gt "${MAX_SIZE}" ]; then
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    mv "${LOG_FILE}" "${LOG_FILE}_${TIMESTAMP}"
    touch "${LOG_FILE}"
fi

echo "...Logfile rotation complete. Summary located at '${LOG_FILE}_${TIMESTAMP}'"
