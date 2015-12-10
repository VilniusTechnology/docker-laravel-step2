# Bazinis atvaizdas (Linux Debian versija Jessie).
FROM debian:jessie

# Kas atsakingas už konteinerio prieziura.
MAINTAINER "Vardenis Pavardenis" <meilas@gmail.com>

# Sudiegiame Nginx.
RUN apt-get update -y && apt-get install -y nginx

# Pridedame Nginx konfiguracijos faila i konteineri.
ADD config/laravel /etc/nginx/sites-available/laravel

# Ijungiame vhosto konfiguracija.
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

# Diegiame PHP5 ir Laravel5 reikalingus extensionus.
RUN apt-get update \
  && apt-get install -y -qq \
      php5-fpm \
      php5-mcrypt \
      php5-cli \
      php5-curl \
      php5-mysqlnd \
      php5-common

# Jei turite dideliu specifiniu poreikiu.
# Idekite savo php.ini i isorine config direktorija.
# Ir atkomentuokite, tuomet php naudos sita config'a.
#ADD config/php.ini     /etc/php5/fpm/php.ini

# Taciau, jei reikia pakoreguoti viena ar kelias eilutes, patogiau yra taip:
RUN sed -i "s/;date.timezone =.*/date.timezone = Europe\/Vilnius/" /etc/php5/fpm/php.ini

# Laraveliui reikia composer
# Tam reikia CURL
RUN apt-get install -y nginx

# Diegiame composer
RUN curl -sS https://getcomposer.org/installer | php

# Diegiame supervisor, jis paleis ir priziures nginx ir php
RUN apt-get install -y supervisor
ADD supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Atveriame portus isorei.
EXPOSE 80

# Pleidzime supervisor, kuris paleis likusius procesus.
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
