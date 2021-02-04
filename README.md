# Gravity Sync Docker

These are the files required to build a Docker image running [Gravity Sync](https://github.com/vmstan/gravity-sync).

#### Before Running!
You need to run the pre-launch scripts which will configure your remote host. Naturally, I reccomend you follow all reccomendations. Otherwise, you may have to do some manual configuration, or run with potentially less than desirable security configuration.<br />
To run this is quite simple. Firstly, we must have a directory in place to map to the .ssh directory within the container.<br />
`mkdir /path/to/.ssh`<br />
Then, simply run the container in interactive mode, mounting this directory and entering at the pre-flight script file.<br />
`docker run -t -i -v "/path/to/.ssh:/root/.ssh:rw" --rm docker_gravitysync /usr/local/bin/prelaunch.sh`

#### Manual pre-launch
Pre-generate your SSH keys and mount them into the container. Follow the instructions in the [SSH Keys section](#ssh-keys). I also recommend you create a user on the remote machine for the purpose of receiving the SSH connection. I personally created the user gravitysync. See the sections [SSH Keys](#ssh-keys) and [User Creation Recommendation](#user-creation-recommendation) below.

#### Configuration of the container
For instructions on how to configure the Gravity Sync service, please see https://github.com/vmstan/gravity-sync<br />
It is important to note that in the interests of making configuration values more sensical to the layman, not all setting names in this "Docker Image" are identical to those in "Vanialla Gravity Sync". You can see these changes marked yellow in the table below. Simply, the defined Environmental variables are mapped to the settings name upon the container's first run (install run) when the container builds the configuration file. Please do not try to mount your own configuration file as this will cause failure of the container.

|| Vanilla GS | Docker Image |
| ------ | ------ | ------ |
|🟩|REMOTE_HOST|REMOTE_HOST|
|🟩|REMOTE_USER|REMOTE_USER|
|🟨|PH_IN_TYPE|LOCAL_HOST_TYPE|
|🟨|RH_IN_TYPE|REMOTE_HOST_TYPE|
|🟨|PIHOLE_DIR|LOCAL_PIHOLE_DIR|
|🟨|RIHOLE_DIR|REMOTE_PIHOLE_DIR|
|🟨|PIHOLE_BIN|LOCAL_PIHOLE_BIN|
|🟨|RIHOLE_BIN|REMOTE_PIHOLE_BIN|
|🟨|DOCKER_BIN|LOCAL_DOCKER_BIN|
|🟨|ROCKER_BIN|REMOTE_DOCKER_BIN|
|🟨|FILE_OWNER|LOCAL_FILE_OWNER|
|🟨|RILE_OWNER|REMOTE_FILE_OWNER|
|🟨|DOCKER_CON|LOCAL_DOCKER_CON|
|🟨|ROCKER_CON|REMOTE_DOCKER_CON|
|🟩|GRAVITY_FI|GRAVITY_FI|
|🟩|CUSTOM_DNS|CUSTOM_DNS|
|🟩|VERIFY_PASS|VERIFY_PASS|
|🟩|SKIP_CUSTOM|SKIP_CUSTOM|
|🟩|DATE_OUTPUT|DATE_OUTPUT|
|🟩|PING_AVOID|PING_AVOID|
|🟩|ROOT_CHECK_AVOID|ROOT_CHECK_AVOID|
|🟩|BACKUP_RETAIN|BACKUP_RETAIN|
|🟩|SSH_PKIF|SSH_PKIF|

#### Docker Compose example:
```
gravitysync:
  build:
    context: /docker/gravity-sync/build/
    dockerfile: /docker/gravity-sync/build/gravitysync.dockerfile
  container_name: "gravitysync"
  restart: "unless-stopped"
  environment:
    TZ: "ETC/UTC"
    REMOTE_HOST: "192.168.0.1"
    REMOTE_USER: "gravitysync"
    LOCAL_INSTALL_TYPE: "docker"
    REMOTE_INSTALL_TYPE: "docker"
    LOCAL_PIHOLE_DIR: "/etc/pihole/"
    REMOTE_PIHOLE_DIR: "/docker/pihole/config/pihole/"
    LOCAL_FILE_OWNER: "root:root"
    REMOTE_FILE_OWNER: "root:root"
    SYNC_FREQUENCY: "30"
    BACKUP_HOUR: "4"
    DEBUG: "true"
  volumes:
    - "/docker/gravity-sync/logs/gravity-sync.log:/root/gravity-sync/gravity-sync.log:rw"
    - "/docker/gravity-sync/logs/gravity-sync.cron:/root/gravity-sync/gravity-sync.cron:rw"
    - "/docker/gravity-sync/data/backup:/root/gravity-sync/backup/:rw"
    - "/docker/pihole/config/pihole:/etc/pihole/:rw"
    - "/var/run/docker.sock:/var/run/docker.sock:rw"
```

#### Mount Points
The following are the mount points within the container. You can map them to wherever you like on your host.

###### Docker Socket
`/var/run/docker.sock - READ ONLY`<br />
This is required to allow the container to interact with the Docker process on the host, to pass along commands to your PiHole container.<br />
It is located at `/var/run/docker.sock` and should be mounted at `/var/run/docker.sock` and only requires read access.

###### Secondary PiHole Configuration Directory
`/etc/pihole/ - READ / WRITE`<br />
This is where your gravity database sits. On a standard PiHole install, it would sit at `/etc/pihole`. Ensure that wherever you mount this in the Gravity Sync container, you configure the ***LOCAL_PIHOLE_DIR*** to the same value (directory within the container). I personally prefer to mount it at `/etc/pihole/`.

###### Gravity Sync Backups
`/root/gravity-sync/data/backup/ - READ / WRITE`<br />
Gravity Sync performs a backup on every successful sync run, and also daily depending on to the automated backup setting. Backups are held for 7 days, depending on the retention policy specified with ***BACKUP_RETAIN***. If you do not mount this directory, then backups will be lost with every container update. This directory can be found at `/root/gravity-sync/data/backup/` within the container.

###### Gravity Sync Log Files
`/root/gravity-sync/gravity-sync.log - READ / WRITE`<br />
`/root/gravity-sync/gravity-sync.cron - READ / WRITE`<br />
Gravity Sync keeps a log file of it's most recent Cron run and also records of previous runs. You may find it useful to mount these from the host for easy viewing and also, if you wish to persist your logs between container rebuilds.

###### SSH Keys Directory
`/root/.ssh/ - READ ONLY*`<br />
SSH Keys must be configured and in place before the container is run for the first time. Without this, the initial run will try to generate keys. Without persisting this directory, the container continue to generate new keys with each run and so will be unable to connect to the remote host. Review the [SSH Keys section](#ssh-keys) below.

#### User Creation Recommendation
**If you ran the pre-launch scripts, then you were presented the option to have this done for you**<br />
I created the user gravitysync on my remote machine, as I have SSH for the root account disabled. Also, since this is a service account, I did not want it using my personal system administration account. This account requires passwordless sudo, and also must have root access in order to have read / write access to the PiHole configuration on the remote system. Here is how I achieved that on an Ubuntu host.<br />
```
sudo adduser gravitysync
sudo echo "gravitysync ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/gravitysync
sudo usermod -a -G sudo gravitysync
sudo usermod -a -G docker gravitysync
```

#### SSH KEYS
**If you ran the pre-launch scripts, then this will have been done for you**<br />
In order to communicate with the remote host, SSH keys are required. An easy way to generate them is using the OpenSSH client. Using the following single liner, we can be sure on being able to generate these keys on any system.<br />
`docker run -t -i --rm alpine:latest apk --update add openssh-client && ssh-keygen -t rsa -f /tmp/id_rsa`<br />
Alternatively, if you have OpenSSH on your system already, you can use that. You then need to copy the key to the remote system. An easy way to do this is using ssh-copy-id like so:<br />
`ssh-copy-id -i /tmp/id_rsa.pub gravitysync@192.168.0.1`.<br />
This assumes that the key generated is indeed located at `/tmp/id_rsa.pub`, that the remote username is `gravitysync` and that the remote system is located at `192.168.0.1`.

#### TO DO
 - Persist MD5 files when upgrading containers<br />
 - Integrate a health check<br />
 - Integrate more error detection during configuration<br />
 - Write a shell script to test the built container
