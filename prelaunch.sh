#!/bin/bash

readYesNo()
{
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^y" ;then
        true
    else
        false
    fi
}

remote_user="root"

echo "What is the hostname / IP of the remote host?"
read remote_host;

echo "Is the remote SSH server on port 22?"
if readYesNo; then
    remote_port="22"
else
    echo "What is the port of your remote SSH server?"
    read remote_port;
fi

echo "We recomend creating a gravitysync user on the remote system - would you like to do this?"
if readYesNo; then
    #Connect and create user
    remote_user="gravitysync"
    echo "Please provide a management user with sudo privileges"
    echo "We will use this user to create the gravitysync user only"
    echo "ssh -P${remote_port} USER@${remote_host}"
    read username;
    ssh -t -o "StrictHostKeyChecking no" ${username}@${remote_host} ' \
        sudo adduser gravitysync && \
        sudo usermod -a -G sudo gravitysync && \
        sudo usermod -a -G docker gravitysync && \
        umask u=r,g=r,o= && \
        echo "gravitysync ALL=(ALL) NOPASSWD:ALL" | \
        sudo tee /etc/sudoers.d/gravitysync > /dev/null'
    echo "The remote system is configured as recomended"
else
    echo "Would you like to use the root account? NOT RECOMENDED!"
    if !readYesNo; then
        echo "What user would you like to connect to on the remote system?"
        echo "Please note that this user must be part of the sudo and docker groups, and must have passwordless sudo"
        read remote_user;
    fi
fi

#Next, we generate SSH keys if they do not exist
ssh-keygen -t rsa

echo "We will now copy the SSH Key to the remote system. Please provide a password."
ssh-copy-id ${remote_user}@${remote_host}

if [ $remote_user == "gravitysync" ]; then
    echo "Disabling password login for gravitysync user"
    ssh ${remote_user}@${remote_host} sudo passwd -d gravitysync
fi

echo "Installing dependencies rsync, sqlite3, git and verifying system"
ssh -o BatchMode=yes -p${remote_port} ${remote_user}@${remote_host} '\
    sudo apt install -y rsync sqlite3 git && \
    sudo curl -sSL https://gravity.vmstan.com | sudo GS_INSTALL=primary bash'
