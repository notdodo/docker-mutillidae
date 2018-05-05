FROM alpine:latest
LABEL version 1.0
LABEL description "Mutillidae Container with NGINX"
MAINTAINER Edoardo Rosa <edoardo [dot] rosa90 [at] gmail [dot] com> (edoz90)

# == BASIC SOFTWARE ============================================================

RUN sed -i -e 's/v[[:digit:]]\.[[:digit:]]/edge/g' /etc/apk/repositories
RUN apk update && apk upgrade

RUN apk add logrotate rsyslog supervisor goaccess \
            nginx php mariadb mariadb-client pwgen php-fpm \
            vim bash-completion nginx-vim tmux wget unzip

RUN apk add php-mysqli php-mbstring php-session php-simplexml

# == NGINX CONFIGURATION ========================================================

RUN adduser -H -D -g http http
RUN mkdir -p /usr/share/nginx/html
RUN mkdir -p /run/nginx
RUN chown -R http:http /usr/share/nginx/html

# == MYSQL CONFIGURATION =========================================================

RUN chown -R mysql:mysql /var/lib/mysql
RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /run/mysqld
RUN chmod 777 /var/tmp/
ADD dist/install_db.sh /tmp/install_db.sh

# == INSTALLATION ================================================================

RUN wget -q https://sourceforge.net/projects/mutillidae/files/latest/download -O mutillidae.zip
RUN unzip -q mutillidae.zip -d /usr/share/nginx/html/
RUN bash /tmp/install_db.sh
RUN rm /tmp/install_db.sh

ADD dist/nginx.conf /etc/nginx/nginx.conf
ADD dist/mutillidae.conf /etc/nginx/sites-enabled/

# == TOOLS (useful when inspecting the container) ==============================

ADD dist/goaccess.conf /etc/goaccess.conf
ADD dist/logrotate.conf /etc/logrotate.d/nginx
ADD dist/rsyslog.conf /etc/rsyslog.d/90.nginx.conf
ADD dist/supervisord.ini /etc/supervisor.d/supervisord.ini

# == ENTRYPOINT ================================================================

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
