#!/bin/bash

cd /root
unzip ./hiredis.zip
cd ./hiredis-master
make && make install


cd /root
unzip ./phpiredis.zip
cd ./phpiredis-master
phpize
./configure --enable-phpiredis --with-hiredis-dir=/usr/local
make && make install

echo "extension=phpiredis.so" > /etc/php5/mods-available/iredis.ini
php5enmod iredis

apache2ctl restart

rm -fr /root/*

touch /.hiredis
