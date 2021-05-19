# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: rcabezas <rcabezas@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/02/11 18:53:36 by rcabezas          #+#    #+#              #
#    Updated: 2021/05/19 18:22:30 by rcabezas         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

MAINTAINER Raul Cabezas Gonzalez <rcabezas@student.42madrid.com>

RUN apt update && \
    apt install -y nginx \
    mariadb-server \
    wget \
    openssl \
    php-mysql \
    php-fpm \
    php-mbstring

COPY srcs/init.sql /tmp/
COPY srcs/wp-config.php /var/www/localhost/wordpress/
COPY srcs/config.inc.php /tmp/
COPY srcs/config_nginx /etc/nginx/sites-available/

RUN wget http://wordpress.org/latest.tar.gz && tar -xzvf latest.tar.gz && \	
	rm latest.tar.gz && \
	mv wordpress/* /var/www/localhost/

RUN cd && \
    rm -rf /var/www/html/index.* && \
    mkdir -p /var/www/localhost && \
    rm -rf /etc/nginx/sites-available/default && \
    rm -rf /etc/nginx/sites-enabled/default && \
    ln -sf /etc/nginx/sites-available/config_nginx /etc/nginx/sites-enabled/ && \
    chown -R www-data:www-data /var/www/* && \
    chmod -R 755 /var/www/*

RUN service mysql start && \
    mysql -u root --password= < /tmp/init.sql

RUN chmod 700 /etc/ssl/certs && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 -subj "/C=SP/ST=Spain/L=Madrid/O=42/CN=localhost" \
    -out /etc/ssl/certs/nginx-selfsigned.pem \
    -keyout /etc/ssl/certs/nginx-selfsigned.key

RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz && \
    mkdir /var/www/localhost/phpmyadmin && \
    tar xzf phpMyAdmin-4.9.0.1-all-languages.tar.gz --strip-components=1 -C /var/www/localhost/phpmyadmin && \
    cp /tmp/config.inc.php /var/www/localhost/phpmyadmin/

EXPOSE 80 443

CMD service nginx start && \
    service mysql start && \
    service php7.3-fpm start && \
    sleep infinity
