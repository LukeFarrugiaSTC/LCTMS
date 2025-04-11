FROM php:8.2-apache

# Install system dependencies in single layer, clean up afterward
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install and enable Redis extension via PECL, clean up after
RUN pecl install redis && docker-php-ext-enable redis

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Copy only necessary files (use .dockerignore for excluding files)
COPY --chown=www-data:www-data composer.json composer.lock /var/www/html/
WORKDIR /var/www/html

# Make sure the directory exists
RUN mkdir -p /var/www/html/tmp

# Run Composer as www-data
USER www-data
RUN composer install --no-dev --optimize-autoloader
USER root

# Copy application code after dependencies are installed
COPY --chown=www-data:www-data . /var/www/html/

# Configure Apache to run as www-data (non-root)
RUN sed -i 's/^export APACHE_RUN_USER=www-data$/export APACHE_RUN_USER=www-data/' /etc/apache2/envvars \
    && sed -i 's/^export APACHE_RUN_GROUP=www-data$/export APACHE_RUN_GROUP=www-data/' /etc/apache2/envvars

# Switch to non-root user for runtime
USER www-data