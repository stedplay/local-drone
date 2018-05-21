#!/bin/sh
#
# Backup database.
# Usage:
#   backup.sh
# Required environment variable:
#   MYSQL_HOST, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD,
#   GDRIVE_ACCOUNT, GDRIVE_SYNC_DST_DIR

# Send mail to ${MAIL_ADDRESS}.
# Usage:
#   send_mail ${RESULT} "${MAIL_BODY}"
function send_mail() {
  ./send_mail.sh ${MAIL_ADDRESS} "[$1] drone-db-backup ${DATE}" "$2"
}

# IF command occur error, send error mail and exit.
# Usage:
#   check_error "${COMMAND}"
function check_error() {
  OUTPUT=$(eval "$@")
  RET=$?
  echo -e "begin '$@'\n${OUTPUT}\nend '$@'"
  echo 'RET='${RET}
  if [ ${RET} -ne 0 ]; then
    # Abnormal end.
    send_mail 'ERROR' "${OUTPUT}"
    exit 1
  fi
}

# Print date.
DATE=$(date +"%Y%m%d_%H%M%S")
echo 'DATE='${DATE}

# cd script directory.
cd $(dirname $0)

# Initialize.
LOGROTATE_CONF_PATH='./logrotate.conf'
DUMP_PATH=$(head -n 1 ${LOGROTATE_CONF_PATH} | tr -d '{')
GDRIVE_SYNC_SRC_DIR=$(dirname ${DUMP_PATH})/
MAIL_ADDRESS=${GDRIVE_ACCOUNT}
MAIL_BODY_TAG_NAME=mail_body

# Dump database.
mkdir -p ${GDRIVE_SYNC_SRC_DIR}
check_error "mysqldump --skip-extended-insert --order-by-primary --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --result-file=${DUMP_PATH} ${MYSQL_DATABASE} 2>&1"
ls -l ${GDRIVE_SYNC_SRC_DIR}

# Rotate dump file.
check_error "DATE=${DATE} logrotate -v ${LOGROTATE_CONF_PATH} 2>&1"
ls -l ${GDRIVE_SYNC_SRC_DIR}

# Send dump file to remote.
check_error "./sync_to_gdrive.sh ${GDRIVE_BIN_PATH} ${GDRIVE_ACCOUNT} ${GDRIVE_SYNC_SRC_DIR} ${GDRIVE_SYNC_DST_DIR} ${MAIL_BODY_TAG_NAME} 2>&1"

# Normal end.
MAIL_BODY=$(echo "${OUTPUT}" | awk "/<${MAIL_BODY_TAG_NAME}>/,/<\/${MAIL_BODY_TAG_NAME}>/" | grep -v ${MAIL_BODY_TAG_NAME})
send_mail 'SUCCESS' "${MAIL_BODY}"
exit 0
