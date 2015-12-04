# Bazinis img
FROM debian:jessie

# Kas atsakingas
MAINTAINER "Vardenis Pavardenis" <meilas@gmail.com>

# Sudiegiame Nginx
RUN apt-get update -y && apt-get install -y nginx

# Sukuriame Nginx configuration
# ADD config/nginx.conf /opt/etc/nginx.conf
ADD config/laravel /etc/nginx/sites-available/laravel
RUN ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel && \
    rm /etc/nginx/sites-enabled/default

# Sukuriame nginx vhost'o direktorija
RUN mkdir /data
RUN mkdir /data/www

RUN chmod -R 775 /data
RUN chown -R www-data:www-data /data

# Paruosiame vietas failines sistemos prijungimui
VOLUME ["/var/log", "/data"]
# /var/log - prijungsime log'u direktorija, kad galetume patogiai stebeti ka veikia serveris
# /data - nginx virtualaus host'o direktorija

# Paruosiame nginx, kad veiktu foreground'e (konteineris nesustos, vos tik paleidus nginx).
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Apsivalome
RUN apt-get update
RUN apt-get autoremove
RUN apt-get dist-upgrade -y -qq

# Diegiame PHP5
RUN apt-get update \
  && apt-get install -y -qq \
      php5-fpm \
      php5-mcrypt \
      php5-cli \
      php5-curl \
      php5-mysqlnd \
      php5-common

# Jei turite dideliu specifiniu poreikiu
# Idekite savo php.ini ir atkomentuokite, tuomet php naudos sita config'a
#ADD config/php.ini     /etc/php5/fpm/php.ini 

# Jei reikia pakoreguoti viena ar kelias eilutes, patogiau yra taip:
RUN sed -i "s/;date.timezone =.*/date.timezone = Europe\/Vilnius/" /etc/php5/fpm/php.ini 

# Laraveliui reikia composer
# Tam reikia CURL
RUN apt-get install -y nginx

# Diegiame composer
RUN curl -sS https://getcomposer.org/installer | php

# Siuo atveju nebutina, bet ateiti gali prireikti
# Komunikacija su PHP
EXPOSE 9000

# Installing supervisord
RUN apt-get install -y supervisor
ADD supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

#RUN apt-get install -y net-tools
#RUN netstat

# PORTS
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
