#!/usr/bin/bash

# UPDATED MAY 24, 2024

### Variables ###
BACKUP_FOLDER="/root/backups/crm"
BACKUP_TARGET="/Root/Backups"
#### Functions ####

backup ()
{ # Backup to Mega

  echo -e "Backing up $1"

  filename=$(basename "$1")

  if  megals --reload | grep $filename >/dev/null 2>&1
  then
    		echo "Backup was already found in MEGA"
  else
    		echo "Backup was not found in MEGA"
    		megaput --path ${BACKUP_TARGET}/${filename} ${1}
    		echo "Backed up ${filename} to MEGA"
  fi

  if [ $? -ne 0 ]; then
 		echo -e "ERROR: Couldn't upload $filename to Mega" "failure"
  fi
 	echo " "
}
###################

echo -e "Starting MEGA Cloud Backup\n"

for f in $(find ${BACKUP_FOLDER} -name '*.gz'); do backup $f; done

echo -e "Ending MEGA Cloud Backup"

exit 0