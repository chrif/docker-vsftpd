# Creates some users for ssh that happen to map to the vsftpd
# equivalents.

mkdir /var/run/sshd
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

count=0
prev=
while read -r user
do
  if (( $count % 2 == 0 )); then
    useradd $user -d /home/vsftpd/$user -G ftp
    prev=$user
  else
    echo $user | passwd --stdin $prev
  fi
  let count++
done < <(cat /etc/vsftpd/virtual_users)
&>/dev/null /usr/sbin/sshd -D &
