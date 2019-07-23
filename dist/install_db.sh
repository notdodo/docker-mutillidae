#!/bin/sh
DATA_PATH="/var/lib/mysql"
/usr/bin/mysql_install_db --user=root --datadir="${DATA_PATH}" > /dev/null

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
GRANT ALL ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'::1' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'127.0.0.1' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;
GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;
GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'::1' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;
DELETE FROM mysql.user WHERE User='';
UPDATE user set plugin='' where User='root';
UPDATE user set plugin='' where User='${MYSQL_USER}';
DROP DATABASE test;
FLUSH PRIVILEGES;
EOF

cat << EOF > /usr/share/nginx/html/mutillidae/includes/database-config.inc
<?php
define('DB_HOST', 'localhost');
define('DB_USERNAME', '${MYSQL_USER}');
define('DB_PASSWORD', '${MYSQL_PASSWORD}');
define('DB_NAME', '${MYSQL_DATABASE}');
?>
EOF

# Disable unix sockets and start mysql_safe with root user
cat << EOF > /etc/my.cnf
[client]
port		= 3306

[mysqld]
user 		= root
port		= 3306

binlog_format=mixed
symbolic-links=0
!includedir /etc/my.cnf.d
EOF

/usr/bin/mysqld --datadir="${DATA_PATH}" --user=root --bootstrap --verbose=1 < $tfile
rm -f $tfile
