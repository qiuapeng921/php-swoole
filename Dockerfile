FROM php:7.3-fpm-alpine

ENV SWOOLE_VERSION=4.5.3
ENV PHP_REDIS=5.3.1

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN echo "Asia/Shanghai" > /etc/timezone

# update
RUN set -ex \
    && apk update \
    && apk add --no-cache libstdc++ wget openssl  bash \
    && apk add --no-cache --virtual .build-deps \
    autoconf automake make g++ gcc dpkg-dev dpkg file pkgconf file re2c libtool \
    libmcrypt-dev libxml2-dev icu-dev libzip-dev libpng-dev libc-dev zlib-dev \
    libaio-dev openssl-dev \
    pcre-dev php7-dev php7-pear

# Extensions
RUN docker-php-ext-install gd bcmath opcache mysqli pdo pdo_mysql sockets zip

# Composer
RUN wget https://mirrors.cloud.tencent.com/composer/composer.phar \
    && mv composer.phar  /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# Extension redis bcmath mongodb
RUN pecl install redis mcrypt mongodb && docker-php-ext-enable redis mcrypt mongodb

# Swoole extension
RUN wget http://pecl.php.net/get/swoole-${SWOOLE_VERSION}.tgz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
        cd swoole \
        && phpize \
        && ./configure --enable-mysqlnd --enable-openssl \
        && make -s -j$(nproc) && make install \
    ) \
    && rm -r swoole \
    && docker-php-ext-enable swoole

RUN apk del .build-deps && rm -rf /var/cache/apk/* /tmp/* /usr/share/man

RUN php -m

EXPOSE 9500 9501 9502 9503 9504