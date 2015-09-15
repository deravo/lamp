#!/bin/bash

if [ ! -f /.hiredis ]; then
    /hiredis.sh
fi

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

if [ ! -f /.root_pw_set ]; then
    /set_root_pw.sh
fi

rm -fr /var/lib/apt/lists/*

echo "Starting SSH daemon"
/usr/sbin/sshd -D
echo "SSH daemon is running."
echo ""

echo "restarting MySQL"
/etc/init.d/mysql restart
echo "MySQL is running"
echo ""

echo "restarting apache2"
/etc/init.d/apache2 restart

echo "Have a nice day"