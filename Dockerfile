FROM php:7.3-fpm-alpine

ENV SWOOLE_VERSION=4.5.1
ENV PHP_REDIS=5.2.2

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk update
RUN apk add wget git zip unzip vim lsof tcpdump htop gcc g++ autoconf make \
    openssl openssl-dev \
    librdkafka librdkafka-dev \
    libmcrypt libmcrypt-dev \
    libxml2 libxml2-dev \
    icu icu-dev \
    libpq postgresql-dev \
    libzip libzip-dev \
    rabbitmq-c rabbitmq-c-dev

# Extensions
RUN docker-php-ext-install bcmath intl opcache mysqli pgsql pdo pdo_mysql pdo_pgsql soap sockets zip

# Composer
RUN wget https://mirrors.cloud.tencent.com/composer/composer.phar \
    && mv composer.phar  /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# Amqp
RUN pecl install amqp && docker-php-ext-enable amqp

# Mcrypt
RUN pecl install mcrypt && docker-php-ext-enable mcrypt

# Mongodb extension
RUN pecl install mongodb && docker-php-ext-enable mongodb

# Kafka
RUN pecl install rdkafka && docker-php-ext-enable rdkafka

#Yaf
RUN pecl install yaf && docker-php-ext-enable yaf

# Redis extension
RUN wget http://pecl.php.net/get/redis-${PHP_REDIS}.tgz -O /tmp/redis.tar.tgz \
    && pecl install /tmp/redis.tar.tgz \
    && rm -rf /tmp/redis.tar.tgz \
    && docker-php-ext-enable redis

## Swoole extension
RUN wget http://pecl.php.net/get/swoole-${SWOOLE_VERSION}.tgz -O swoole.tar.gz \
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

RUN php -m

EXPOSE 9500 9501 9502 9503 9504
