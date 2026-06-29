FROM composer:2 AS vendor

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --no-progress --prefer-dist --no-scripts --optimize-autoloader
FROM php:8.5-cli AS assets

WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libicu-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-install bcmath intl mbstring pdo_mysql zip \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY --from=vendor /app/vendor /app/vendor
COPY . /app
RUN npm ci && npm run build
FROM nginx:1.27-alpine

COPY docker/production/nginx/nginx.conf /etc/nginx/nginx.conf
COPY public /var/www/public
COPY --from=assets /app/public/build /var/www/public/build

RUN rm -f /var/www/public/hot \
    && chown -R nginx:nginx /var/www/public

EXPOSE 80