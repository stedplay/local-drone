#!/bin/sh
#
# Send mail.
# Usage:
#   send_mail.sh ${TO} "${SUBJECT}" "${BODY}"

TO=$1
SUBJECT=$2
BODY=$3

{
  echo "To: ${TO}"
  echo "Subject: ${SUBJECT}"
  echo ""
  echo "${BODY}"
  echo "."
} | /usr/sbin/sendmail -v ${TO}
