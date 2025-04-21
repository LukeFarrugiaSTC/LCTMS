FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install and enable Redis extension via PECL
RUN pecl install redis && docker-php-ext-enable redis

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy composer files first (leveraging Docker layer caching)
COPY --chown=www-data:www-data composer.json composer.lock ./

# Create tmp directory (optional, depending on app)
RUN mkdir -p /var/www/html/tmp

# Run Composer install as www-data
USER www-data
RUN composer install --no-dev --optimize-autoloader

# Switch back to root for next steps
USER root

# Copy the rest of the application AFTER composer install (to preserve layer cache)
COPY --chown=www-data:www-data . .

# Ensure Apache runs as www-data
RUN sed -i 's/^export APACHE_RUN_USER=www-data$/export APACHE_RUN_USER=www-data/' /etc/apache2/envvars \
    && sed -i 's/^export APACHE_RUN_GROUP=www-data$/export APACHE_RUN_GROUP=www-data/' /etc/apache2/envvars

# Final switch to non-root user
USER www-data