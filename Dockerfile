FROM            alpine:3 as baseenvironment

LABEL           maintainer Michael Thompson <25192401+nh-mike@users.noreply.github.com>

ENV             GS_INSTALL="secondary" \
                GS_VERSION="3.6.2" \
                GENERATE_SSH_CERTS="true" \
                TINI_VERSION="0.19.0" \
                DEBUG="false" \
                SYNC_FREQUENCY="30" \
                REMOTE_HOST="127.0.0.1" \
                SSH_PORT="22" \
                REMOTE_USER="root" \
                LOCAL_HOST_TYPE="docker" \
                REMOTE_HOST_TYPE="docker" \
                LOCAL_PIHOLE_DIR="/etc/pihole/" \
                REMOTE_PIHOLE_DIR="/etc/pihole/" \
                LOCAL_PIHOLE_BIN="" \
                REMOTE_PIHOLE_BIN="" \
                LOCAL_PH_INSTALL_TYPE="default" \
                LOCAL_RH_INSTALL_TYPE="default" \
                LOCAL_DOCKER_BIN="" \
                REMOTE_DOCKER_BIN="" \
                LOCAL_FILE_OWNER="root:root" \
                REMOTE_FILE_OWNER="root:root" \
                LOCAL_DOCKER_CON="" \
                REMOTE_DOCKER_CON="" \
                GRAVITY_FI="" \
                CUSTOM_DNS="" \
                VERIFY_PASS="" \
                SKIP_CUSTOM="" \
                DATE_OUTPUT="" \
                PING_AVOID="" \
                ROOT_CHECK_AVOID="" \
                SSH_PKIF=".ssh/id_rsa"

COPY            ./container_scripts/install_tini.sh /usr/local/bin/install_tini.sh

RUN             chmod +x /usr/local/bin/install_tini.sh && \
                apk --update add openssh sudo bash coreutils && \
                /usr/local/bin/install_tini.sh

FROM            baseenvironment as buildenvironment

                # apk --update add less rsync sqlite
RUN             apk --update add curl && \
                rm -rf /var/lib/apt/lists/* && \
                rm /var/cache/apk/* && \
                cd /tmp/ && \
                wget https://github.com/vmstan/gravity-sync/archive/v$GS_VERSION.zip && \
                mkdir /tmp/gravity-sync/ && \
                unzip v$GS_VERSION.zip -d /tmp/gravity-sync/ && \
                mv /tmp/gravity-sync/gravity-sync-$GS_VERSION /root/gravity-sync


FROM            baseenvironment as prodbuildenvironment

#COPY            configure.sh /usr/local/bin/configure.sh
#COPY            missionreport.sh /usr/local/bin/missionreport.sh
#COPY            prelaunch.sh /usr/local/bin/prelaunch.sh
#COPY            startup.sh /usr/local/bin/startup.sh
#COPY            upgradeCompatibilityChecks.sh /usr/local/bin/upgradeCompatibilityChecks.sh
COPY            container_scripts/* /usr/local/bin/
COPY            --from=buildenvironment /root/gravity-sync/ /root/gravity-sync/

WORKDIR         /root/gravity-sync/

RUN             apk --update add rsync sqlite docker-cli util-linux && \
                rm -rf /var/lib/apt/lists/* && \
                rm /var/cache/apk/* && \
                echo 'echo "Git is not required"' > /usr/local/bin/git && \
                chmod +x /usr/local/bin/git && \
                chmod +x /usr/local/bin/configure.sh && \
                chmod +x /usr/local/bin/missionreport.sh && \
                chmod +x /usr/local/bin/prelaunch.sh && \
                chmod +x /usr/local/bin/startup.sh && \
                chmod +x /usr/local/bin/upgradeCompatibilityChecks.sh

HEALTHCHECK     --interval=5m --timeout=60s --start-period=10s \
                CMD /usr/local/bin/missionreport.sh

ENTRYPOINT      ["/tini", "--"]
CMD             ["/usr/local/bin/startup.sh"]
