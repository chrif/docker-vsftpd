FROM centos:7
MAINTAINER Brian Rak <brak@vmware.com>
LABEL Description="vsftpd Docker image based on Centos 7. Supports passive mode and virtual users." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST PORT NUMBER]:21 -v [HOST FTP HOME]:/home/vsftpd brakthehack/vsftpd" \
	Version="1.0"

RUN yum -y update && yum clean all
RUN yum -y install httpd && yum clean all
RUN yum install -y \
	vsftpd \
	db4-utils \
	db4 \
        iproute

ENV PASV_ADDRESS **IPv4**
ENV PASV_MIN_PORT 21100
ENV PASV_MAX_PORT 21110
ENV LOG_STDOUT true

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd.sh

RUN mkdir -p /var/log/vsftpd # Logs

RUN chown root /etc/vsftpd/vsftpd.conf

EXPOSE 20 21

CMD ["/usr/sbin/run-vsftpd.sh"]
