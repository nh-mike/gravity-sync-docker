#!/bin/sh

if [ ! -f "/root/gravity-sync/gravity-sync.conf" ];
then
    /usr/local/bin/configure.sh || exit 1
fi

/usr/sbin/crond -f -l 8
