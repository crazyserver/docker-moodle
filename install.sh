#!/bin/bash

PASSWORD='test'
HOST='moodle.domain.com'
MOODLE_VERSION=$1
echo 'MOODLE_VERSION'
echo $MOODLE_VERSION

if [ ! -f /var/www/html/moodle/config.php ]; then

    # MySQL
    sudo sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
    sudo sed -i 's/\[mysqld\]/\[mysqld\]\nwait_timeout = 100\nmax_connections=500/g' /etc/mysql/my.cnf
    sudo service mysql restart

    sudo mysqladmin -u root password $PASSWORD
    sudo mysql -uroot -p$PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
    sudo mysql -uroot -p$PASSWORD -e "CREATE DATABASE moodle default character set UTF8 collate UTF8_bin; GRANT ALL PRIVILEGES ON moodle.* TO 'moodle'@'localhost' IDENTIFIED BY '$PASSWORD'; FLUSH PRIVILEGES;"

    # SSH
    sed -i 's/PermitRootLogin without-password/PermitRootLogin Yes/' /etc/ssh/sshd_config

    # Moodle
    sudo mkdir /var/www/html
    cd /var/www/html
    sudo git clone git://github.com/moodle/moodle

    cd /var/www/html/moodle
    sudo git checkout $MOODLE_VERSION

    sudo sed -e "s/pgsql/mysqli/
    s/username/moodle/
    s/password/$PASSWORD/
    s/example.com/$HOST/
    s/\/home\/example\/moodledata/\/var\/moodledata/" /var/www/html/moodle/config-dist.php > /var/www/html/moodle/config.php

    sudo mkdir /var/moodledata
    sudo chown -R www-data:www-data /var/moodledata
    sudo chmod 777 /var/moodledata
    sudo chown -R www-data:www-data /var/www/html/moodle
fi
