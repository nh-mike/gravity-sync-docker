#!/bin/bash

if [ "${DEBUG}" = "true" ];
then
        set -x
        set -v
else
        set +x
        set +v
fi

/usr/local/bin/upgradeCompatibilityChecks.sh

if [[ "$?" != "0" ]];
then
	echo "Failed the upgrade compatibility check"
	exit 1
fi

/root/gravity-sync/gravity-sync.sh compare

if [[ "$?" != "0" ]];
then
	echo "Failed to perform a comparison between pihole instances"
	exit 1
fi

filemoddate=`stat -c %Y /root/gravity-sync/logs/gravity-sync.cron`
tolerance=$(( ${SYNC_FREQUENCY}*60 * 11/10 ))
nextfilemoddate=$(( ${filemoddate} + ${tolerance} ))
now=`date +%s`

if [[ ${nextfilemoddate} -lt ${now} ]]; then
	echo "Failed to verify that GravitySync has run in the last ${SYNC_FREQUENCE} minutes"
	exit 1
fi

if [ "${DEBUG}" = "true" ]; then
	echo "Mission Report all clear";
fi

exit 0
