FROM centos:7
MAINTAINER Christian Koehler <ckoehler99.io@gmail.com>
LABEL Description="vsftpd Docker image based on Centos 7. Supports passive mode, virtual users and sftp." \
	License="Apache License 2.0" \
	Usage="See the github repo for examples." \
	Version="1.0"
USER root

RUN yum -y update && yum clean all
RUN yum -y install httpd && yum clean all
RUN yum install -y \
	vsftpd \
	db4-utils \
	db4 \
        iproute \
        openssh-server \
        passwd

ENV PASV_ADDRESS **IPv4**
ENV PASV_MIN_PORT 21100
ENV PASV_MAX_PORT 21110
ENV USE_SFTP **Boolean**

COPY vsftpd.conf /etc/vsftpd/
COPY sshd_config /etc/ssh/
COPY vsftpd_virtual /etc/pam.d/

COPY run-vsftpd.sh /usr/sbin/
COPY run-sshd.sh /usr/sbin/
COPY start-services.sh /usr/sbin/

COPY tail /usr/bin/tail-wait

RUN chmod +x /usr/sbin/run-vsftpd.sh
RUN chmod +x /usr/sbin/run-sshd.sh
RUN chmod +x /usr/sbin/start-services.sh

RUN mkdir -p /var/log/ # Logs
RUN chmod u+x /usr/bin/tail-wait

EXPOSE 20 21 22

USER 1000

ENTRYPOINT ["/usr/sbin/start-services.sh"]
