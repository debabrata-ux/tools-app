FROM php:8.2-apache

RUN apt-get update && apt-get install -y git unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev libicu-dev && docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install pdo_mysql mbstring zip gd intl bcmath exif opcache && a2enmod rewrite && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer update --no-dev --optimize-autoloader --no-interaction --no-scripts
RUN composer dump-autoload --optimize --no-scripts

RUN mkdir -p storage bootstrap/cache && chown -R www-data:www-data storage bootstrap/cache

RUN a2enmod rewrite
RUN sed -ri 's!^/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

EXPOSE 80
RUN echo "===== ENABLED MPM MODULES =====" && \
    ls -la /etc/apache2/mods-enabled/mpm_* || true && \
    echo "===== APACHE MPM QUERY =====" && \
    a2query -M || true

CMD ["apache2-foreground"]
