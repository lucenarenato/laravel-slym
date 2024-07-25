FROM php:7.4-fpm-alpine

# ARG user=renato
# ARG uid=1000
ENV COMPOSER_ALLOW_SUPERUSER=1
ARG APP_STAGE
ENV APP_STAGE $APP_STAGE
ARG APP_ENV
ENV APP_ENV $APP_ENV
ENV TZ=America/Sao_Paulo

RUN apk add --no-cache $PHPIZE_DEPS \
    zlib-dev \
    oniguruma-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libxml2-dev \
    libzip-dev \
    linux-headers \
    supervisor \
    icu-dev \
    openssl-dev \
    git \
    tzdata \
    curl \
    freetype \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets zip \
    && docker-php-ext-install soap simplexml intl dom opcache \
    && rm -rf /var/cache/apk/*
# \
# && pecl install xdebug \
# && docker-php-ext-enable xdebug

RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

RUN pecl install -f apcu \
    && echo 'extension=apcu.so' > /usr/local/etc/php/conf.d/30_apcu.ini

RUN chmod -R 755 /usr/local/lib/php/extensions/

RUN pecl install timezonedb \
    docker-php-ext-enable timezonedb

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN if [ "$APP_STAGE" == "dev" ]; then \
    apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=coverage" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=LINFE" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    fi

# RUN adduser -G www-data -D -u $uid $user \
#     && mkdir -p /home/$user/.composer \
#     && chown -R $user:www-data /home/$user

RUN composer --version
RUN composer self-update --snapshot && composer self-update 2.0.14

WORKDIR /var/www/html

RUN chmod -R 775 /var/www/html

# Copy the project files
COPY . /var/www/html

# INSTALL YOUR DEPENDENCIES
RUN echo pwd: `pwd` && echo ls: `ls`
# outputs:
# pwd: /var/www/html
# ls:
RUN composer install --no-scripts --no-autoloader --ansi --no-interaction
RUN chown -R $(whoami) /var/www/html

RUN composer dump-autoload -o \
    && chown -R :www-data /var/www/html \
    && chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache

# USER $user
