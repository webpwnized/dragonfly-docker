#webpwnized/dragonfly:www

# Start with recent version of PHP with Apache 
# https://hub.docker.com/_/php?tab=tags&page=1&ordering=last_updated&name=apache
FROM php:apache

# ######################### #
# Install software packages #
# ######################### #

# Update software packages
# Install PHP requirements: if any
# Install git
# Copy the application project to Apache web files directory
# uninstall git
# Patch the container
# Remove the apt-get lists after installation
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y git && \
    git clone https://github.com/webpwnized/dragonfly.git /var/www/dragonfly && \
    apt-get remove -y git && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ######################## #
# Configure the web server #
# ######################## #

# Change the document root
ENV APACHE_DOCUMENT_ROOT /var/www/dragonfly/

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Open ports 80 in the container firewall
# This exposes HTTP
EXPOSE 80
