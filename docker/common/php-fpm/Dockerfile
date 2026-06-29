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
FROM php:8.5-fpm AS base

ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    default-mysql-client \
    libicu-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-install bcmath intl pdo_mysql zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN if [ "$UID" != "33" ]; then usermod -u "$UID" www-data; fi \
    && if [ "$GID" != "33" ]; then groupmod -g "$GID" www-data; fi

WORKDIR /var/www

FROM base AS development

ARG XDEBUG_ENABLED=false
ARG XDEBUG_MODE=develop,coverage,debug
ARG XDEBUG_HOST=host.docker.internal
ARG XDEBUG_IDE_KEY=DOCKER

RUN if [ "$XDEBUG_ENABLED" = "true" ]; then \
    pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && { \
      echo "xdebug.mode=$XDEBUG_MODE"; \
      echo "xdebug.client_host=$XDEBUG_HOST"; \
      echo "xdebug.idekey=$XDEBUG_IDE_KEY"; \
      echo "xdebug.start_with_request=yes"; \
    } > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
  fi

COPY docker/development/php-fpm/entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

USER www-data
EXPOSE 9000
ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]

FROM base AS production

COPY --chown=www-data:www-data . /var/www
COPY --from=vendor --chown=www-data:www-data /app/vendor /var/www/vendor
COPY --from=assets --chown=www-data:www-data /app/public/build /var/www/public/build
COPY docker/production/php-fpm/entrypoint.sh /usr/local/bin/docker-entrypoint

RUN chmod +x /usr/local/bin/docker-entrypoint \
    && chown -R www-data:www-data storage bootstrap/cache

USER www-data
EXPOSE 9000
ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]