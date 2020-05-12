FROM php:7.3-fpm-alpine

ENV SWOOLE_VERSION=4.5.1
ENV PHP_REDIS=5.2.2

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk update \
    && apk add \
    curl wget git zip unzip vim procps lsof tcpdump htop openssl openssl-dev gcc g++ autoconf make \
    php7-bcmath \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-iconv \
    php7-intl \
    php7-json \
    php7-openssl \
    php7-opcache \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqlnd \
    php7-mysqli \
    php7-pgsql \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pdo_sqlite \
    php7-phar \
    php7-phpdbg \
    php7-posix \
    php7-session \
    php7-soap \
    php7-sockets \
    php7-xml \
    php7-xmlreader \
    php7-zip \
    php7-zlib

# Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update --clean-backups \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# Redis extension
RUN wget http://pecl.php.net/get/redis-${PHP_REDIS}.tgz -O /tmp/redis.tar.tgz \
    && pecl install /tmp/redis.tar.tgz \
    && rm -rf /tmp/redis.tar.tgz \
    && docker-php-ext-enable redis

## Swoole extension
RUN wget http://pecl.php.net/get/swoole-${PHP_REDIS}.tgz -O /tmp/swoole.tar.tgz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
    cd swoole \
        && phpize \
        && ./configure --enable-async-redis --enable-mysqlnd --enable-openssl --enable-http2 \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r swoole \
    && docker-php-ext-enable swoole

EXPOSE 9500 9501 9502 9503 9504