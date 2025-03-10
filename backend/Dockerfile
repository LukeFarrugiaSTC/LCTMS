FROM php:8.1-apache

# Copy the PHP source code into the container
COPY . /var/www/html/

# Install any necessary PHP extensions (example: mysqli and pdo_mysql)
RUN docker-php-ext-install mysqli pdo pdo_mysql

RUN pecl install redis && docker-php-ext-enable redis

# Enable Apache mod_rewrite if needed
RUN a2enmod rewrite