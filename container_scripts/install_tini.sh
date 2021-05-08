#!/bin/bash

ARCH="$(uname -m)"

if [ ${ARCH} = "x86_64" ];
then
    wget https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static -O /tini
elif [ ${ARCH} = "aarch64" ];
then
    wget https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-arm64 -O /tini
elif [ ${ARCH} = "armv7l" ];
then
    wget https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-armhf -O /tini
else
    echo "The architecture ${ARCH} is not supported"
    exit 1
fi

chmod +x /tini
