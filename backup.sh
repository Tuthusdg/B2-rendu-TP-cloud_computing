#!/bin/bash
STORAGE_ACCOUNT="storagecloudtp2"
CONTAINER_NAME="tp2"
DB_NAME="--all-databases"

DATE_FORMAT=$(date "+%Y-%m-%d_%Hh%Mm")
BACKUP_FILENAME="backup-${DATE_FORMAT}.sql.gz"
LOCAL_FILE_PATH="/tmp/${BACKUP_FILENAME}"
mysqldump "${DB_NAME}" | gzip > "${LOCAL_FILE_PATH}">/dev/null


az login --identity > /dev/null
az storage blob upload \
    --account-name "${STORAGE_ACCOUNT}" \
    --container-name "${CONTAINER_NAME}" \
    --file "${LOCAL_FILE_PATH}" \
    --name "${BACKUP_FILENAME}" \
    --auth-mode login >/dev/null

rm "${LOCAL_FILE_PATH}"