#!/bin/sh
mysql_install_db --user=mysql > /dev/null

MYSQL_ROOT_PASSWORD=$(pwgen -c -n -s -B 15 1)
printf "\e[32m[!!!] MySQL 'root' password is: %s\e[0m\n" ${MYSQL_ROOT_PASSWORD}

MYSQL_DATABASE="mutillidae"
MYSQL_USER="mutillidae"
MYSQL_PASSWORD=$(pwgen -c -n -s -B 15 1)
printf "\e[32m[!!!] MySQL '%s' password is: %s\e[0m\n" ${MYSQL_USER} ${MYSQL_PASSWORD}

tfile=$(mktemp)
cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' identified by '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("${MYSQL_ROOT_PASSWORD}") WHERE user='root' AND host='localhost';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL ON ${MYSQL_DATABASE}.* to '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
FLUSH PRIVILEGES;
EOF

cat << EOF > /usr/share/nginx/html/mutillidae/includes/database-config.php
<?php
define('DB_HOST', 'localhost');
define('DB_USERNAME', '${MYSQL_USER}');
define('DB_PASSWORD', '${MYSQL_PASSWORD}');
define('DB_NAME', '${MYSQL_DATABASE}');
?>
EOF

/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < $tfile
rm -f $tfile
