#!/bin/bash

# Set root password
if [ "${AUTHORIZED_KEYS}" != "**None**" ]; then
    echo "=> Found authorized keys"
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    IFS=$'\n'
    arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")
    for x in $arr
    do
        x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
        cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "=> Adding public key to /root/.ssh/authorized_keys: $x"
            echo "$x" >> /root/.ssh/authorized_keys
        fi
    done
fi

if [ ! -f /.hiredis ]; then
    /hiredis.sh
fi

if [ ! -f /.root_pw_set ]; then
    /set_root_pw.sh
fi


if [ ! -f /.mysql_setup ]; then
    /setup_mysql.sh
fi

# source /etc/apache2/envvars
# exec apache2 -D FOREGROUND
# exec apache2ctl start
# exec mysqld_safe

/usr/sbin/sshd -D
exec supervisord -n