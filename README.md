# brakthehack/vsftpd

Fork of fauria/vsftpd. Offers some better usage in multiuser virtual environments.

This Docker container implements a vsftpd server, with the following features:

 * Centos 7 base image.
 * vsftpd 3.0
 * Virtual users
 * Passive mode
 * Logging to a file or STDOUT.

### Installation from [Docker registry hub](https://registry.hub.docker.com/u/brakthehack/vsftpd/).

You can download the image with the following command:

```bash
docker pull brakthehack/vsftpd
```

Environment variables
----

* Variable name: `PASV_ADDRESS`
* Default value: Docker host IP.
* Accepted values: Any IPv4 address.
* Description: If you don't specify an IP address to be used in passive mode, the routed IP address of the Docker host will be used. Bear in mind that this could be a local address.

----

* Variable name: `PASV_MIN_PORT`
* Default value: 21100.
* Accepted values: Any valid port number.
* Description: This will be used as the lower bound of the passive mode port range. Remember to publish your ports with `docker -p` parameter.

----

* Variable name: `PASV_MAX_PORT`
* Default value: 21110.
* Accepted values: Any valid port number.
* Description: This will be used as the upper bound of the passive mode port range. It will take longer to start a container with a high number of published ports.

----

* Variable name: LOG_STDOUT
* Default value: Empty string.
* Accepted values: Any string to enable, empty string or not defined to disable.
* Description: Output vsftpd log through STDOUT, so that it can be accessed through the [container logs](https://docs.docker.com/reference/commandline/logs/).

----

Exposed ports and volumes
----

The image exposes ports `20` and `21`. Also, exports two volumes: `/home/vsftpd`, which contains users home directories, and `/var/log/vsftpd`, used to store logs.

When sharing a homes directory between the host and the container (`/home/vsftpd`) the owner user id and group id should be 14 and 80 respectively. This correspond ftp user and ftp group on the container, but may match something else on the host.

----

Multiuser
----

The main enhancement over fauria is the easy of user in supporting multiuser environments. This image loads a local directory which allows you to specify users in a config-file
based approach. Place a file called `user` in a directory of your choosing and execute the following to load
the config into the image:

```
docker run -it -v /tmp/custom_dir:/home/custom_dir \
               -v ~/Code/docker-vsftpd/users:/etc/vsftpd/virtual_users \
               -p 20000:20 -p 21000:21 -p 21100-21110:21100-21110 \
               -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 -e PASV_ADDRESS=127.0.0.1 \
               $1
```

The users file takes the form:

```
ftpuser
my_password
ftpuser2
my_password2
```

Use cases
----

1) Create a temporary container for testing purposes:

```bash
  docker run --rm brakthehack/vsftp
```

2) Create a container in active mode using the default user account, with a binded data directory:

```bash
docker run -d -p 21:21 -v /my/data/directory:/home/vsftpd --name vsftpd brakthehack/vsftpd
# see logs for credentials:
docker logs vsftpd
```

3) Create a **production container** with a custom user account, binding a data directory and enabling both active and passive mode:

```bash
docker run -d -v /my/data/directory:/home/vsftpd \
-p 20:20 -p 21:21 -p 21100-21110:21100-21110 \
-e FTP_USER=myuser -e FTP_PASS=mypass \
-e PASV_ADDRESS=127.0.0.1 -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
--name vsftpd --restart=always brakthehack/lap
```

4) Manually add a new FTP user to an existing container:
```bash
docker exec -i -t vsftpd bash
mkdir /home/vsftpd/myuser
echo -e "myuser\nmypass" >> /etc/vsftpd/virtual_users.txt
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db
exit
docker restart vsftpd
```
