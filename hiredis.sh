#!/bin/bash

cd /root 
wget https://github.com/redis/hiredis/archive/master.zip
mv ./master.zip ./hiredis.zip
unzip ./hiredis.zip 
cd ./hiredis-master 
make && make install

cd /root
wget https://github.com/nrk/phpiredis/archive/master.zip 
mv ./master.zip ./phpiredis.zip 
unzip ./phpiredis.zip 
cd ./phpiredis-master
phpize 
./configure --enable-phpiredis --with-hiredis-dir=/usr/local
make && make install
echo "extension=phpiredis.so" > /etc/php5/mods-available/redis.ini
