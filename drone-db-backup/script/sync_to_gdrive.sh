#!/bin/sh
#
# Upload directory to google drive.
# Usage:
#   sync_to_gdrive.sh ${GDRIVE_BIN_PATH} ${GDRIVE_ACCOUNT} ${SYNC_SRC_DIR_IN_LOCAL} ${SYNC_DST_DIR_IN_GDRIVE} ${MAIL_BODY_TAG_NAME}

# Arguments.
GDRIVE_BIN_PATH=$1
GDRIVE_ACCOUNT=$2
SYNC_SRC_DIR=$3
SYNC_DST_DIR=$4
MAIL_BODY_TAG_NAME=$5

echo "[Begin $(basename $0)]"
# cd script directory.
cd $(dirname $0)
# Delete leading slash.
SYNC_DST_DIR=${SYNC_DST_DIR#/}
# Delete trailing slash.
SYNC_DST_DIR=${SYNC_DST_DIR%/}

# Print arguments.
echo 'pwd='$(pwd)
echo 'GDRIVE_BIN_PATH='${GDRIVE_BIN_PATH}
echo 'GDRIVE_ACCOUNT='${GDRIVE_ACCOUNT}
echo 'SYNC_SRC_DIR='${SYNC_SRC_DIR}
echo 'SYNC_DST_DIR='${SYNC_DST_DIR}
echo 'MAIL_BODY_TAG_NAME='${MAIL_BODY_TAG_NAME}

# Check state of authentication to google drive.
echo '[Check google drive authentication] ---------------------------'
if [ $(echo 'dummy_str' | ${GDRIVE_BIN_PATH} about | grep 'User:.*'${GDRIVE_ACCOUNT} | grep -c ^) -eq 0 ]; then
  echo -e "\nError: Authentication needed. Execute '${GDRIVE_BIN_PATH} about'"
  exit 1
fi
echo 'Authentication OK.'

# Get name of each hierarchy in destination directory.
SYNC_DST_DIR_SPLITED=$(echo ${SYNC_DST_DIR} | tr -s '/' ' ')
echo "SYNC_DST_DIR_SPLITED='${SYNC_DST_DIR_SPLITED}'"

# Check destination directory in google drive.
parent_dir_id=root
GET_DIR_ID_CMD="${GDRIVE_BIN_PATH} list --query \"'\${parent_dir_id}' in parents\" --max 0 | grep \"\${dir} *dir\" | cut -d' ' -f1"
echo '[Check SYNC_DST_DIR] ------------------------------------------'
for dir in ${SYNC_DST_DIR_SPLITED}; do
  echo 'Checking...'
  echo 'dir='${dir}
  # Get directory ID.
  dir_id=$(eval ${GET_DIR_ID_CMD})
  dir_id_cnt=$(echo -n "${dir_id}" | grep -c ^)
  echo 'dir_id_cnt='${dir_id_cnt}
  # Check the count of directories that exist.
  if [ ${dir_id_cnt} -ge 2 ]; then
    echo 'Error: There are directories with the same name. SYNC_DST_DIR='${SYNC_DST_DIR}
    exit 1
  elif [ ${dir_id_cnt} -eq 0 ]; then
    # If not found, make directory.
    echo 'mkdir '${dir}
    ${GDRIVE_BIN_PATH} mkdir --parent ${parent_dir_id} ${dir}
    # Get directory ID.
    dir_id=$(eval ${GET_DIR_ID_CMD})
  fi
  echo 'dir_id='${dir_id}
  # Save parend directory ID.
  parent_dir_id=${dir_id}
done

# Get destination directory ID.
SYNC_DST_DIR_ID=${dir_id}
echo '-> SYNC_DST_DIR_ID='${SYNC_DST_DIR_ID}

# Print contents of source directory.
echo '[List SYNC_SRC_DIR] -------------------------------------------'
ls -laR ${SYNC_SRC_DIR}

# Print contents of destination directory before synchronizing.
GET_DST_DIR_CONTENT_CMD=${GDRIVE_BIN_PATH}' list --absolute --name-width 0 --max 0 | grep -o '${SYNC_DST_DIR}'.*$ | sort'
echo ${GET_DST_DIR_CONTENT_CMD}
echo '[List SYNC_DST_DIR before synchronizing] ----------------------'
eval ${GET_DST_DIR_CONTENT_CMD}

# Between <${MAIL_BODY_TAG_NAME}> and </${MAIL_BODY_TAG_NAME}> is mail text.
echo "<${MAIL_BODY_TAG_NAME}>"
# Synchronize(Copy) directory (source directory in local -> destination directory in google drive).
echo '[Synchronizing...] --------------------------------------------'
OUTPUT=$(${GDRIVE_BIN_PATH} sync upload --delete-extraneous ${SYNC_SRC_DIR} ${SYNC_DST_DIR_ID})
echo "${OUTPUT}"

echo '[List SYNC_DST_DIR after synchronizing] -----------------------'
# Print contents of destination directory after synchronizing.
eval ${GET_DST_DIR_CONTENT_CMD}

echo '[Result of synchronizing] -------------------------------------'
# Check result of synchronizing.
if [ $(echo ${OUTPUT} | grep -c 'Sync finished') -eq 0 ]; then
  echo 'Error: Failed to synchronizing.'
  exit 1
fi
echo 'Succeeded to synchronizing.'
echo "[End $(basename $0)]"
echo "</${MAIL_BODY_TAG_NAME}>"
exit 0
