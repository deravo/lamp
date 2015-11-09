#!/bin/bash

if [ ! -f /.hiredis ]; then
    /hiredis.sh
fi

source /etc/apache2/envvars
tail -F /var/log/apache2/* &
exec apache2 -D FOREGROUND


