#!/bin/sh

if [ "${DEBUG}" = "true" ];
then
    set -x
    set -v
else
    set +x
    set +v
fi

setLocalTimezone()
{
    apk --update add tzdata
    cp /usr/share/zoneinfo/${TZ} /etc/localtime
    echo "${TZ}" > /etc/timezone
    apk del tzdata
    rm -rf /var/cache/apk/*
    rm -rf /usr/share/zoneinfo
}

connectSsh()
{
    SSH_OUTPUT="$(ssh -o BatchMode=yes -i ${KEY_PATH} -p${SSH_PORT} ${REMOTE_USER}@${REMOTE_HOST} 'exit 0' 2>&1)"
    if [ $? -eq 0 ];
    then
        if contains "${SSH_OUTPUT}" "Permission denied";
        then
            echo false
        else
            echo true
        fi
    else
        echo true
    fi
}

checkSshKeys()
{
    if [ -z $SSH_PKIF ];
    then
        KEY_PATH="/root/.ssh/id_rsa"
    else
        KEY_PATH=$SSH_PKIF
    fi

    if [ ! -f "${KEY_PATH}" ];
    then
        echo "ERROR - SSH Keys do not exist"
        exit 1
    elif [ ! connectSsh  ];
    then
        echo "Unable to initiate SSH connection - Permission Denied"
    fi
}

contains()
{
    IN="${1}"
    PATTERN="${2}"
    echo "${1}" | grep -q "${PATTERN}"
}

createConfigFile()
{
    rm -rf /root/gravity-sync/gravity-sync.conf
    addToConfigFile "REMOTE_HOST" ${REMOTE_HOST}
    addToConfigFile "SSH_PORT" ${REMOTE_SSH_PORT}
    addToConfigFile "REMOTE_USER" ${REMOTE_USER}
    addToConfigFile "PH_IN_TYPE" ${LOCAL_HOST_TYPE}
    addToConfigFile "RH_IN_TYPE" ${REMOTE_HOST_TYPE}
    addToConfigFile "PIHOLE_DIR" ${LOCAL_PIHOLE_DIR}
    addToConfigFile "RIHOLE_DIR" ${REMOTE_PIHOLE_DIR}
    addToConfigFile "DNSMAQ_DIR" ${LOCAL_DNSMASQ_DIR}
    addToConfigFile "RNSMAQ_DIR" ${REMOTE_DNSMASQ_DIR}
    addToConfigFile "PIHOLE_BIN" ${LOCAL_PIHOLE_BIN}
    addToConfigFile "RIHOLE_BIN" ${REMOTE_PIHOLE_BIN}
    addToConfigFile "DOCKER_BIN" ${LOCAL_DOCKER_BIN}
    addToConfigFile "ROCKER_BIN" ${REMOTE_DOCKER_BIN}
    addToConfigFile "FILE_OWNER" ${LOCAL_FILE_OWNER}
    addToConfigFile "RILE_OWNER" ${REMOTE_FILE_OWNER}
    addToConfigFile "DOCKER_CON" ${LOCAL_DOCKER_CON}
    addToConfigFile "ROCKER_CON" ${REMOTE_DOCKER_CON}
    addToConfigFile "GRAVITY_FI" ${GRAVITY_FI}
    addToConfigFile "CUSTOM_DNS" ${CUSTOM_DNS}
    addToConfigFile "VERIFY_PASS" ${VERIFY_PASS}
    addToConfigFile "SKIP_CUSTOM" ${SKIP_CUSTOM}
    addToConfigFile "INCLUDE_CNAME" ${INCLUDE_CNAME}
    addToConfigFile "DATE_OUTPUT" ${DATE_OUTPUT}
    addToConfigFile "PING_AVOID" ${PING_AVOID}
    addToConfigFile "ROOT_CHECK_AVOID" ${ROOT_CHECK_AVOID}
    addToConfigFile "BACKUP_RETAIN" ${BACKUP_RETAIN}
    addToConfigFile "SSH_PKIF" ${SSH_PKIF}
}

addToConfigFile()
{
    SETTING=$1
    VALUE=$2
    if [ ! -z $VALUE ];
    then
        echo "${SETTING}='${VALUE}'" >> /root/gravity-sync/gravity-sync.conf;
    fi
}

setLocalTimezone

/usr/local/bin/upgradeCompatibilityChecks.sh

if [[ "$?" != "0" ]];
then
    echo "Failed the upgrade compatibility check"
    exit 1;
fi

checkSshKeys
createConfigFile
/root/gravity-sync/gravity-sync.sh automate ${SYNC_FREQUENCY} ${BACKUP_HOUR}

echo 'Finished Configuration'
