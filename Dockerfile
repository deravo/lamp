FROM ubuntu:vivid
MAINTAINER Alvin Jin <jin@aliuda.cn>

ENV DEBIAN_FRONTEND noninteractive

# Change Source
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
ADD sources.list /etc/apt/sources.list

# Install Runtime deps
RUN apt-get update && apt-get install -y perl ca-certificates curl libpcre3 librecode0 libsqlite3-0 libxml2 zip pwgen --no-install-recommends

# Install phpize deps
RUN apt-get install -y autoconf file g++ gcc libc-dev make pkg-config re2c --no-install-recommends

# Install MySQL
RUN apt-get -yq install mysql-server-5.6 && \
    rm /etc/mysql/conf.d/mysqld_safe_syslog.cnf && \
    if [ ! -f /usr/share/mysql/my-default.cnf ] ; then cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf; fi

# Install Apache & PHP5 packages
RUN apt-get -y install supervisor git subversion apache2 libapache2-mod-php5 php5-mysql php-apc php5-mcrypt php5-apcu php5-gd php5-mcrypt php5-memcached php5-sqlite php5-common php5-dev && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN  rm -r /var/lib/apt/lists/*

# Add image configuration and scripts

ADD hiredis.sh /hiredis.sh
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh

RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN mkdir dir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M


# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql", "/app" ]

EXPOSE 22 80 3306

CMD ["/run.sh"]
