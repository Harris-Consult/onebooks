FROM php:8.2-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
    intl \
    zip \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . /var/www/html

# Set working directory
WORKDIR /var/www/html

# Install PHP dependencies (ignore platform requirements temporarily)
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=ext-intl

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage \
    && chmod -R 775 /var/www/html/storage

# Apache configuration
RUN a2enmod rewrite