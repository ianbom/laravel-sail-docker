FROM php:8.5-cli

ARG UID=1000
ARG GID=1000
ARG NODE_VERSION=22

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    default-mysql-client \
    git \
    libicu-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-install bcmath intl pdo_mysql zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -g "$GID" app \
    && useradd -m -u "$UID" -g app -s /bin/bash app

WORKDIR /var/www
USER app
CMD ["bash"]