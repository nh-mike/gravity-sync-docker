#!/bin/bash

mustexit=0

check3_0_0()
{
    if [[ -f /root/gravity-sync/gravity-sync.log ]];
    then
        mustexit=1
        echo "Please change the mount point of your log file as below:"
        echo "From:"
        echo "  /root/gravitysync/gravity-sync.log"
        echo "To:"
        echo "  /root/gravitysync/logs/gravity-sync.log"
        exit 1
    fi

    if [[ -f /root/gravity-sync/gravity-sync.cron ]];
    then
        mustexit=1
        echo "Please change the mount point of your cron log file as below:"
        echo "From:"
        echo "  /root/gravitysync/gravity-sync.cron"
        echo "To:"
        echo "  /root/gravitysync/logs/gravity-sync.cron"
        exit 1
    fi
}

check3_0_0

if [[ "${mustexit}"  != "0" ]];
then
    exit 1
fi
