FROM ubuntu:vivid
MAINTAINER Alvin Jin <jin@aliuda.cn>

ENV DEBIAN_FRONTEND noninteractive

# change apt source
ADD sources.list /etc/apt/sources.list

# Install packages
RUN apt-get update && apt-get -y install openssh-server pwgen vim net-tools apt-utils dialog
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Install Runtime deps
RUN apt-get install -y perl ca-certificates curl libpcre3 librecode0 libsqlite3-0 libxml2 zip unzip autoconf file g++ gcc libc-dev make pkg-config re2c --no-install-recommends

# Install MySQL 5.6
RUN apt-get -yq install mysql-server-5.6 mysql-client-5.6

# Install Apache & PHP5 packages
RUN apt-get -y install supervisor git subversion apache2 mysql-client libapache2-mod-php5 php5-mysql php-apc php5-apcu php5-curl php5-redis php5-mcrypt php5-apcu php5-gd php5-mcrypt php5-memcached php5-sqlite php5-common php5-dev && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# ADD scripts
ADD hiredis.sh /hiredis.sh

ADD set_root_pw.sh /set_root_pw.sh
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh

ADD run.sh /run.sh

ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

ADD my.cnf /etc/mysql/conf.d/my.cnf

ADD apache_default /etc/apache2/sites-available/000-default.conf

ADD hiredis.zip /root/hiredis.zip
ADD phpiredis.zip /root/phpiredis.zip

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

RUN chmod +x /*.sh

RUN a2enmod rewrite

# Configure /app folder with sample app
RUN git clone https://github.com/fermayo/hello-world-lamp.git /app/welcome
RUN mkdir dir -p /app && rm -fr /var/www && ln -s /app /var/www

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
ENV AUTHORIZED_KEYS **None**

# ADD Volumes
VOLUME ["/etc/mysql","/var/lib/mysql","/app"]

EXPOSE 22 80 3306

CMD ["/run.sh"]
