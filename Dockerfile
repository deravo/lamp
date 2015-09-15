FROM ubuntu:vivid
MAINTAINER Alvin Jin <jin@aliuda.cn>

ENV DEBIAN_FRONTEND noninteractive

# change apt source
ADD sources.list /etc/apt/sources.list

# Install packages
RUN apt-get update && apt-get -y install openssh-server pwgen vim net-tools
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# copy set root password script
ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh

# prepare env  for generating a random root password
ENV AUTHORIZED_KEYS **None**


# Install Runtime deps
RUN apt-get install -y perl ca-certificates curl libpcre3 librecode0 libsqlite3-0 libxml2 zip unzip autoconf file g++ gcc libc-dev make pkg-config re2c --no-install-recommends

# Install MySQL
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD mysqld_charset.cnf /etc/mysql/conf.d/mysqld_charset.cnf

# Add MySQL scripts

ADD import_sql.sh /import_sql.sh

ENV MYSQL_USER=admin \
    MYSQL_PASS=**Random** \
    ON_CREATE_DB=**False** \
    REPLICATION_MASTER=**False** \
    REPLICATION_SLAVE=**False** \
    REPLICATION_USER=replica \
    REPLICATION_PASS=replica

Add setup_mysql.sh /setup_mysql.sh

# Install MySQL 5.6
RUN apt-get -yq install mysql-server-5.6 mysql-client-5.6 && \
    rm -f /etc/mysql/conf.d/mysqld_safe_syslog.cnf && \
    if [ ! -f /usr/share/mysql/my-default.cnf ] ; then cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf; fi && \
    mysql_install_db > /dev/null 2>&1 && \
    touch /var/lib/mysql/.EMPTY_DB



# Install Apache & PHP5 packages
RUN apt-get -y install supervisor git subversion apache2 mysql-client libapache2-mod-php5 php5-mysql php-apc php5-redis php5-mcrypt php5-apcu php5-gd php5-mcrypt php5-memcached php5-sqlite php5-common php5-dev && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install phpiredis Extension
ADD hiredis.sh /hiredis.sh

RUN chmod 755 /*.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN mkdir dir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M


# Add volumes 
VOLUME  ["/etc/mysql", "/var/lib/mysql", "/app" ]

EXPOSE 22 80 3306

CMD ["/run.sh"]
