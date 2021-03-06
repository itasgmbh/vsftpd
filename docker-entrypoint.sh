#!/bin/sh
# create given user if doesn't exist
if ! id -u ${FTP_USER} > /dev/null 2>&1; then
 adduser -h /home/./${FTP_USER} -s /bin/false -D ${FTP_USER} ${FTP_USER}
fi
if [[ -z ${FTP_PASSWORD} ]]; then
  FTP_PASSWORD=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-16};echo;)
  echo "Generated password for user 'files': ${FTP_PASSWORD}"
fi
# set ftp user password
echo "${FTP_USER}:${FTP_PASSWORD}" | /usr/sbin/chpasswd

chown ${FTP_USER}:${FTP_USER} /home/${FTP_USER}/ -R

# generate key ssl if not exists
if [[ ! -f /etc/vsftpd/vsftpd.key ]]; then
 openssl req -x509 -nodes -days 365 -newkey rsa:4096 -subj "/C=DE/ST=BW/L=Karlsruhe/O=IT/CN=www.itas-gmbh.de" -keyout /etc/vsftpd/vsftpd.key -out /etc/vsftpd/vsftpd.crt
fi


# logs redirect
/bin/ln -sf /proc/1/fd/1  `grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

if [[ -z $1 ]]; then
   /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
else
  $@
fi
