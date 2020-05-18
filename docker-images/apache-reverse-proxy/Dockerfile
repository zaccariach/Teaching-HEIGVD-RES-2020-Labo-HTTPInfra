FROM php:7.2-apache

RUN apt-get update && apt-get install -y vim && apt-get install dos2unix

COPY templates /var/apache2/templates
COPY conf/ /etc/apache2

COPY apache2-foreground /usr/local/bin/
RUN cd /usr/local/bin/ && dos2unix apache2-foreground

RUN a2enmod proxy proxy_http
RUN a2ensite 000-* 001-*
