FROM ubuntu:14.04
MAINTAINER Pau Ferrer <pau@moodle.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade

# Basic Requirements
RUN apt-get install -y pwgen python-setuptools curl git unzip texlive ghostscript imagemagick wget supervisor vim postfix

# SSH
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd

# MYSQL
RUN apt-get install -y mysql-server mysql-client

# PHP
RUN apt-get install -y apache2 php5 php5-curl php5-tidy php5-gd php5-xmlrpc php5-intl php5-mcrypt php5-cli php5-dev php5-ldap libapache2-mod-php5 php5-mysql

RUN easy_install supervisor
ADD ./install.sh /install.sh
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf

RUN chmod 755 /start.sh /etc/apache2/foreground.sh /install.sh

RUN /install.sh $VERSION

EXPOSE 22 80
CMD ["/bin/bash", "/start.sh"]

