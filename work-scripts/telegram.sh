#!/bin/bash
export LC_ALL="C"
export LANG="en_US.UTF-8"
#------------------------------------------------------------------------------
 
BOT_AUTH_TOKEN="787739070:AAGNekViDzdit2gClvoLieNbQr1pGOfezJc"
LOG_FILE="/var/log/zabbix/telegram.log"
 
DATETIME=$(date '+%Y/%m/%d %H:%M:%S')
CHAT_ID="$1"
TEXT=$(echo "$2" | grep -v '.UNKNOWN. = .UNKNOWN.' | sed 's/\"//g')
 
#------------------------------------------------------------------------------

if [[ "${CHAT_ID}" == "getid" ]]; then
    RESULT=$(curl -sS -i --max-time 30 "https://api.telegram.org/bot${BOT_AUTH_TOKEN}/getUpdates" 2>&1)
    RC=$?
    if [ ${RC} -ne 0 ]; then
        echo "${RESULT}"
        exit 1
    elif ! echo "${RESULT}" | grep -iq '"ok":true'; then
        echo "${RESULT}"
        exit 1
    fi
    echo "${RESULT}" | awk -F'"chat":' '{print $2}' | awk -F'"date":' '{print $1}' | sort -u | grep -E "\-?[0-9]{7,}"
    exit 0
elif [[ "${CHAT_ID}" =~ ^-?[0-9]+$ && -n "${TEXT}" ]]; then
    echo "[${DATETIME}] CHAT_ID:\"${CHAT_ID}\" TEXT=\"${TEXT}\"" >> "${LOG_FILE}"
    RESULT=$(curl -sS -i --max-time 30 \
        --header 'Content-Type: application/json' \
        --request 'POST' \
        --data '{"chat_id": "'"${CHAT_ID}"'", "text": "'"${TEXT}"'"}' \
        "https://api.telegram.org/bot${BOT_AUTH_TOKEN}/sendMessage" 2>&1)
    RC=$?
    if [ ${RC} -ne 0 ]; then
        echo "${RESULT}" | tee -a "${LOG_FILE}"
        echo '' >> "${LOG_FILE}"
        exit 1
    elif ! echo "${RESULT}" | grep -iq '"ok":true'; then
        echo "${RESULT}" | tee -a "${LOG_FILE}"
        echo '' >> "${LOG_FILE}"
        exit 1
    fi
    echo "${RESULT}" >> "${LOG_FILE}"
    echo '' >> "${LOG_FILE}"
    echo "[OK] Message was sent"
    exit 0
else
    echo "[${DATETIME}] CHAT_ID:\"${CHAT_ID}\" TEXT=\"${TEXT}\"" >> "${LOG_FILE}"
    echo "[EE] Invalid arguments" | tee -a "${LOG_FILE}"
    echo '' >> "${LOG_FILE}"
    exit 1
fi
 
exit 0
