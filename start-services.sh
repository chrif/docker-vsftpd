#!/bin/bash

if [ "$USE_SFTP" != "**Boolean**" ]; then
    echo "Starting SSH"
    /usr/sbin/run-sshd.sh
fi

echo "Starting VSFTPD"
/usr/sbin/run-vsftpd.sh
