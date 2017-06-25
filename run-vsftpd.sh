#!/bin/bash

# Do not log to STDOUT by default:
if [ "$LOG_STDOUT" = "**Boolean**" ]; then
    export LOG_STDOUT=''
else
    export LOG_STDOUT='Yes.'
fi

# Update vsftpd user db:
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users /etc/vsftpd/virtual_users.db

# Set passive mode parameters:
if [ "$PASV_ADDRESS" = "**IPv4**" ]; then
    export PASV_ADDRESS=$(/sbin/ip route|awk '/default/ { print $3 }')
fi

echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=${PASV_MAX_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=${PASV_MIN_PORT}" >> /etc/vsftpd/vsftpd.conf

mkdir -p /home/vsftpd
chown -R ftp:ftp /home/vsftpd

mkdir -p /var/log/vsftpd

count=0
while read -r user
do
  if (( $count % 2 == 0 )); then
    mkdir -p /home/vsftpd/$user
    chown -R ftp:ftp /home/vsftpd/$user
  fi
  let count++
done < <(cat /etc/vsftpd/virtual_users)

# stdout server info:
if [ ! $LOG_STDOUT ]; then
cat << EOB
        ******************************************************
        *                                                    *
        *    Docker image: brakthehack/vsftd                 *
        *    https://github.com/brakthehack/docker-vsftpd    *
        *                                                    *
        ******************************************************

        SERVER SETTINGS
        ---------------
        · Log file: $VSFTPD_LOG
        · Redirect vsftpd log to STDOUT: No.
EOB
else
  # VSFTPD creates log files on demand (when a user logs in),
  # so it may overwrite symlinked files to stdout. The script below
  # will wait for a file to appear and tail it to stdout.
  /usr/bin/tail-wait /var/log/vsftpd.log &
  /usr/bin/tail-wait /var/log/xferlog &
fi

# Run vsftpd:
&>/dev/null /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
