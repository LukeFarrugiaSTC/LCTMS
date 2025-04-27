FROM php:8.2-apache

# Copy the PHP source code into the container
COPY . /var/www/html/

# Install system dependencies for Composer and PHP extensions
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP extensions (example: mysqli and pdo_mysql)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install and enable Redis extension via PECL
RUN pecl install redis && docker-php-ext-enable redis

RUN composer update 
RUN composer install

# Enable Apache mod_rewrite if needed
RUN a2enmod rewrite